/*
 * Copyright (c) 2007-2011 Madhav Vaidyanathan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */

#import <Foundation/NSString.h>
#import "AccidSymbol.h"
#import "Array.h"
#import "BarSymbol.h"
#import "BlankSymbol.h"
#import "ChordSymbol.h"
#import "ClefMeasures.h"
#import "ClefSymbol.h"
#import "KeySignature.h"
#import "LyricSymbol.h"
#import "MidiFile.h"
#import "MusicSymbol.h"
#import "RestSymbol.h"
#import "Staff.h"
#import "Stem.h"
#import "SymbolWidths.h"
#import "TimeSignature.h"
#import "TimeSigSymbol.h"
#import "WhiteNote.h"
#import "SheetMusic.h"


#define max(x,y) ((x) > (y) ? (x) : (y))




/* Measurements used when drawing.  All measurements are in pixels.
 * The values depend on whether the menu 'Large Notes' or 'Small Notes' is selected.
 */
int LineWidth;    /** The width of a line, in pixels */
int LeftMargin;   /** The left margin, in pixels */
int LineSpace;    /** The space between lines in the staff, in pixels */
int StaffHeight;  /** The height between the 5 horizontal lines of the staff */
int NoteHeight;   /** The height of a whole note */
int NoteWidth;    /** The width of a whole note */
int TitleHeight = 14; /** The height for the title on the first page */


/** A helper function to cast to a MusicSymbol */
id<MusicSymbol> getSymbol(Array *symbols, int index) {
    id<MusicSymbol> result = [symbols get:index];
    return result;
}

/** @class SheetMusic
 * The SheetMusic NSView is the main class for displaying the sheet music.
 * The SheetMusic class has the following public methods:
 *
 * SheetMusic()
 *   Create a new SheetMusic control from the given midi file and options.
 *
 * SetZoom()
 *   Set the zoom level to display the sheet music at.
 *
 * knownPageRange()
 * rectForPage()
 *   Methods called by NSPrintOperation to print the SheetMusic
 *
 * drawRect()
 *   Method called by Cocoa to draw the SheetMusic
 *
 * These public methods are called from the MidiSheetMusic Controller.
 *
 */

@implementation SheetMusic

@synthesize scrollView;

/** Create a new SheetMusic control.
 * MidiFile is the parsed midi file to display.
 * SheetMusic Options are the menu options that were selected.
 *
 * - Apply all the Menu Options to the MidiFile tracks.
 * - Calculate the key signature
 * - For each track, create a list of MusicSymbols (notes, rests, bars, etc)
 * - Vertically align the music symbols in all the tracks
 * - Partition the music notes into horizontal staffs
 */
- (id)initWithFile:(MidiFile*)file andOptions:(MidiOptions*)options {
    CGRect bounds = CGRectMake(0, 0, PageWidth, PageHeight);
    self = [super initWithFrame:bounds];
    
    zoom = 1.0f;
    filename = [[file filename] retain];
    [self setColors:options->colors andShade:options->shadeColor andShade2:options->shade2Color];
    Array* tracks = [file changeMidiNotes:options];
    [SheetMusic setNoteSize:options->largeNoteSize];
    scrollVert = options->scrollVert;
    showNoteLetters = options->showNoteLetters;
    TimeSignature *time = [file time];
    /** delete by sunlie start */
    //    if (options->time != nil) {
    //        time = options->time;
    //    }
    /** delete by sunlie end */
    if (options->key == -1) {
        mainkey = [self getKeySignature:tracks];
    }
    else {
        mainkey = [[KeySignature alloc] initWithNotescale:options->key];
    }
    numtracks = [tracks count];
    
    int lastStarttime = [file endTime] + options->shifttime;
    
    /* Create all the music symbols (notes, rests, vertical bars, and
     * clef changes).  The symbols variable contains a list of music
     * symbols for each track.  The list does not include the left-side
     * Clef and key signature symbols.  Those can only be calculated
     * when we create the staffs.
     */
    
    /* symbols = Array of MusicSymbol[] */
    Array *symbols = [Array new:numtracks];
    NSLog(@"ssssssssss =[%d]", numtracks);
    /* add by sunlie start */
    beatarray = [file beatarray];
    tonearray = [file tonearray];
    /* add by sunlie end */
    
    for (int tracknum = 0; tracknum < numtracks; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        /** modify by sunlie start */
        if ([[track notes] count] > 0) {
            [track createControlNotes:time];
            [track createSplitednotes:time andBeatarray:beatarray];
        }
        ClefMeasures *clefs = [[ClefMeasures alloc] initWithNotes:[track notes] andTime:time andBeats:beatarray andControl:[track controlList] andTotal:[track totalpulses]];
        /* chords = Array of ChordSymbol */
        Array *chords = [self createChords:[track splitednotes] withKey:mainkey
                                   andTime:time andClefs:clefs andCList2:[track controlList2] andCList3:[track controlList3] andCList4:[track controlList4] andCList5:[track controlList5] andCList6:[track controlList6] andCList7:[track controlList7]];
        Array *sym = [self createSymbols:chords withClefs:clefs andTime:time andLastTime:lastStarttime andBeatarray:beatarray];
        [symbols add:sym];
        /** modify by sunlie end */
        [clefs release];
        [chords release];
        [sym release];
    }
    
    Array *lyrics = nil;
    if (options->showLyrics) {
        lyrics = [self getLyrics:tracks];
    }
    
    /* Vertically align the music symbols */
    SymbolWidths *widths = [[SymbolWidths alloc] initWithSymbols:symbols andLyrics:lyrics];
    [self alignSymbols:symbols withWidths:widths];
    
    staffs = [self createStaffs:symbols withKey:mainkey andOptions:options andMeasure:[time measure]];
    
    [self createAllBeamedChords:symbols withTime:time];
    
    //add by yizhq start
    [self CreateConnectNodes:symbols andTime:time];
    //add by yizhq end
    
    //add by sunlie start
    [self CreateConLineNodes:symbols andTime:time];
    [self CreateEightNodes:symbols andTime:time];
    //add by sunlie end
    
    if (lyrics != nil) {
        [self addLyrics:lyrics toStaffs:staffs];
    }
    [lyrics release];
    
    /* After making chord pairs, the stem directions can change,
     * which affects the staff height.  Re-calculate the staff height.
     */
    for (int i = 0; i < [staffs count]; i++) {
        Staff* staff = [staffs get:i];
        [staff calculateHeight];
        /** add by sunlie start */
        for (int j = 0; j < [[staff symbols] count]; j++) {
            if ([[[staff symbols] get:j] isKindOfClass:[ChordSymbol class]]) {
                [[[staff symbols] get:j] setBelongStaffHeight:[staff height]];
            }
        }
        /** add by sunlie end */
    }
    
    [self setZoom:1.0f];
    
    [tracks release];
    [symbols release];
    [widths release];

    
    shadePrevPulseTime = -1;
    shadeCurrentPulseTime = -1;
    
    return self;
}



/** Get the best key signature given the midi notes in all the tracks. */
- (KeySignature*)getKeySignature:(Array*)tracks {
    int initsize = 1;
    if ([tracks count] > 0) {
        initsize = [[ (MidiTrack*)[tracks get:0] notes] count];
        initsize = initsize * [tracks count];
    }
    IntArray* notenums = [IntArray new:initsize];
    int i, j;
    
    for (i = 0; i < [tracks count]; i++) {
        MidiTrack *track = [tracks get:i];
        for (j = 0; j < [[track notes] count]; j++) {
            MidiNote *note = [[track notes] get:j];
            [notenums add:[note number]];
        }
    }
    KeySignature* result = [KeySignature guess:notenums];
    [notenums release];
    return result;
}


/** Create the chord symbols for a single track.
 * @param midinotes  The Midinotes in the track.
 * @param key        The Key Signature, for determining sharps/flats.
 * @param time       The Time Signature, for determining the measures.
 * @param clefs      The clefs to use for each measure.
 * @ret An array of ChordSymbols
 */
- (Array*) createChords:(Array*)midinotes withKey:(KeySignature*)key
                andTime:(TimeSignature*)time andClefs:(ClefMeasures*)clefs andCList2:(Array *)list andCList3:(Array *)list3
                andCList4:(Array *)list4 andCList5:(Array *)list5 andCList6:(Array *)list6 andCList7:(Array *)list7{
    
    int i = 0;
    int len = [midinotes count];
    Array* chords = [Array new:len/4];
    Array* notegroup = [Array new:12];
    /** add by sunlie start */
    ControlData *cd2, *cd3, *cd4, *cd5, *cd7;
    int flag = 0;
    int flag4 = 0;
    int flag5 = 0;
    int flag7 = 0;
    int cdcount2 = 0;
    int cdcount3 = 0;
    int cdcount4 = 0;
    int cdcount5 = 0;
    int cdcount7 = 0;
    if (cdcount2 < [list count]) {
        cd2 = [list get:cdcount2];
    }
    if (cdcount3 < [list3 count]) {
        cd3 = [list3 get:cdcount3];
    }
    if (cdcount4 < [list4 count]) {
        cd4 = [list4 get:cdcount4];
    }
    if (cdcount5 < [list5 count]) {
        cd5 = [list5 get:cdcount5];
    }
    if (cdcount7 < [list7 count]) {
        cd7 = [list7 get:cdcount7];
    }
    /** add by sunlie end */
    
    while (i < len) {
        int starttime = [(MidiNote*)[midinotes get:i] startTime];
        int clef = [clefs getClef:starttime];
        
        /* Group all the midi notes with the same start time
         * into the notes list.
         */
        [notegroup clear];
        [notegroup add:[midinotes get:i]];
        i++;
        while (i < len && [(MidiNote*)[midinotes get:i] startTime] == starttime) {
            [notegroup add:[midinotes get:i]];
            i++;
        }
        
        /* add by sunlie start */
        if (i < len) {
            int count = 0;
            int j;
            MidiNote *mn;
            for (j=0; j<[notegroup count]; j++) {
                mn = [notegroup get:j];
                if ([mn endTime] <= [[midinotes get:i] startTime]+[time quarter]/16) {
                    break;
                }
                count++;
            }
            
            if (count == [notegroup count]) {
                MidiNote *n = [[MidiNote alloc]init];
                mn = [notegroup get:0];
                [n setStarttime:[mn startTime]];
                [n setChannel:[mn channel]];
                [n setNumber:[mn number]];
                [n setDuration:[[midinotes get:i] startTime]-[mn startTime]];
                [n setAddflag:1];
                [notegroup add:n];
                [notegroup sort:sortbynote];
            }
        }
        /* add by sunlie end */
        
        /* Create a single chord from the group of midi notes with
         * the same start time.
         */
        ChordSymbol *chord = [[ChordSymbol alloc] initWithNotes:notegroup andKey:key
                                                        andTime:time andClef:clef andSheet:self];
        
        /* add by sunlie start */
        
        if (cdcount2 < [list count]) {
            if (abs([chord startTime]-[cd2 starttime]) < [time quarter]/8  && flag == 0) {
                [chord setConLine:cdcount2+1];
                flag = 1;
            }
            if (abs([chord startTime]-[cd2 endtime]) < [time quarter]/8 && flag == 1) {
                [chord setConLine:cdcount2+1];
                cdcount2++;
                if (cdcount2 < [list count]) {
                    cd2 = [list get:cdcount2];
                    flag = 0;
                }
            }
        }
        
        if (cdcount3 < [list3 count]) {
            if ([chord startTime] >= [cd3 starttime] && [chord startTime] <= [cd3 endtime]) {
                if ([cd3 cvalue] <= 64) {
                    [chord setJumpedFlag:1];
                } else if ([cd3 cvalue] > 64) {
                    [chord setJumpedFlag:2];
                }
            } else if ([chord startTime] > [cd3 endtime]) {
                cdcount3++;
                if (cdcount3 < [list3 count]) {
                    cd3 = [list3 get:cdcount3];
                }
            }
        }
        
        if (cdcount4 < [list4 count]) {
            if ([chord startTime] <= [cd4 starttime] && flag4 == 0) {
                if ([chord endTime] >= [cd4 endtime] ) {
                    if ([cd4 cvalue] <= 64) {
                        [chord setEightFlag:-200];
                    } else if ([cd4 cvalue] > 64) {
                        [chord setEightFlag:200];
                    }
                } else if ([cd4 cvalue] <= 64 && [chord endTime] > [cd4 starttime]) {//modify by sunlie
                    [chord setEightFlag:-cdcount4-2];
                    flag4 = -1;
                } else if ([cd4 cvalue] > 64 && [chord endTime] > [cd4 starttime] ) {//modify by sunlie
                    [chord setEightFlag:cdcount4+2];
                    flag4 = 1;
                }
            }   else if ([chord endTime] >= [cd4 endtime] && (flag4 == 1 || flag4 == -1)) {
                if ([cd4 cvalue] <= 64) {
                    [chord setEightFlag:-cdcount4-2];
                } else if ([cd4 cvalue] > 64) {
                    [chord setEightFlag:cdcount4+2];
                }
                flag4 = 0;
                cdcount4++;
                if (cdcount4 < [list4 count]) {
                    cd4 = [list4 get:cdcount4];
                }
            } else  {
                [chord setEightFlag:flag4];
            }
            
            if ([chord eightFlag] > 0) {
                for (int k = 0; k < [chord notedata_len]; k++) {
                    [chord notedata][k].number = [chord notedata][k].number-12;
                    [chord notedata][k].whitenote = [key getWhiteNote:[chord notedata][k].number];
                }
            } else if ([chord eightFlag] < 0) {
                for (int k = 0; k < [chord notedata_len]; k++) {
                    [chord notedata][k].number = [chord notedata][k].number+12;
                    [chord notedata][k].whitenote = [key getWhiteNote:[chord notedata][k].number];
                }
            }
        }
        
        if (cdcount5 < [list5 count]) {
            if (abs([chord startTime]-[cd5 starttime]) < [time quarter]/8 && flag5 == 0) {
                [chord setPedalFlag:1];
                flag5 = 1;
            } else if (abs([chord endTime]-[cd4 endtime]) < [time quarter]/8 && flag5 == 1) {
                flag5 = 0;
                cdcount5++;
                if (cdcount5 < [list5 count]) {
                    cd5 = [list5 get:cdcount5];
                }
            }
        }
        
        [chord setChordInfo];
        /* add by sunlie end */
        
        [chords add:chord];
        [chord release];
    }
    
    [notegroup release];
    return chords;
}

/* Given the chord symbols for a track, create a new symbol list
 * that contains the chord symbols, vertical bars, rests, and clef changes.
 * Return a list of symbols (ChordSymbol, BarSymbol, RestSymbol, ClefSymbol)
 */
- (Array*) createSymbols:(Array*) chords withClefs:(ClefMeasures*)clefs
                 andTime:(TimeSignature*)time andLastTime:(int)lastStartTime andBeatarray:(Array *)barray {
    
    Array* symbols;
    id old;
    
    symbols = [self addBars:chords withTime:time andLastTime:lastStartTime andBeatarray:barray];
    old = symbols;
    symbols = [self addRests:symbols withTime:time andBeatarray:barray];
    [old release];
    old = symbols;
    symbols = [self addClefChanges:symbols withClefs:clefs andTime:time];
    [old release];
    
    return symbols;
}

/** Add in the vertical bars delimiting measures.
 *  Also, add the time signature.
 */
- (Array*)addBars:(Array*)chords withTime:(TimeSignature*)time andLastTime:(int)lastStartTime andBeatarray:(Array *)barray {
    Array* symbols = [Array new:[chords count]];
    BarSymbol *bar;
    int j = 1;
    int starttime = 0;
    int size = [barray count];
    BeatSignature *beat = [barray get:0];
    
    TimeSigSymbol* timesymbol = [[TimeSigSymbol alloc]
                                 initWithNumer:[beat numerator] andDenom:[beat denominator] andStartTime:0];
    [time setNumerator:[beat numerator]];
    [time setDenominator:[beat denominator]];
    [time setMeasure];
    
    [symbols add:timesymbol];
    [timesymbol release];
    if (size > 1) {
        starttime = [[beatarray get:j] starttime];
    }
    
    /* The starttime of the beginning of the measure */
    int measuretime = [time measure];
    
    int i = 0;
    while (i < [chords count]) {
        if (measuretime <= [getSymbol(chords, i) startTime]) {
            bar = [[BarSymbol alloc] initWithTime:measuretime];
            [symbols add:bar];
            [bar release];
            
            /* add by sunlie start */
            if (starttime!=0 && [[chords get:i] startTime] >= starttime) {
                BeatSignature *b = [barray get:j];
                TimeSigSymbol* ts = [[TimeSigSymbol alloc]
                                     initWithNumer:[b numerator] andDenom:[b denominator] andStartTime:[b starttime]];
                bar = [[BarSymbol alloc] initWithTime:measuretime];
                [symbols add:bar];
                [symbols add:ts];
                [time setNumerator:[b numerator]];
                [time setDenominator:[b denominator]];
                [time measure];
                j++;
                if (j<size) {
                    starttime = [[beatarray get:j] starttime];
                } else {
                    starttime = 0;
                }
                [bar release];
                [b release];
                [ts release];
            }
            /* add by sunlie end */
            
            measuretime += [time measure];
        }
        else {
            [symbols add:[chords get:i] ];
            i++;
        }
    }
    
    /* Keep adding bars until the last StartTime (the end of the song) */
    while (measuretime < lastStartTime) {
        
        /* add by sunlie start */
        if (starttime!=0 && measuretime >= starttime) {
            BeatSignature *b = [barray get:j];
            TimeSigSymbol* ts = [[TimeSigSymbol alloc]
                                 initWithNumer:[b numerator] andDenom:[b denominator] andStartTime:[b starttime]];
            bar = [[BarSymbol alloc] initWithTime:measuretime];
            [symbols add:bar];
            [symbols add:ts];
            [time setNumerator:[b numerator]];
            [time setDenominator:[b denominator]];
            [time measure];
            j++;
            if (j<size) {
                starttime = [[beatarray get:j] starttime];
            } else {
                starttime = 0;
            }
            [bar release];
            [b release];
            [ts release];
        }
        /* add by sunlie end */
        
        bar = [[BarSymbol alloc] initWithTime:measuretime];
        [symbols add:bar];
        [bar release];
        measuretime += [time measure];
    }
    
    /* Add the final vertical bar to the last measure */
    bar = [[BarSymbol alloc] initWithTime:measuretime];
    [symbols add:bar];
    [bar release];
    return symbols;
}

/** Add rest symbols between notes.  All times below are
 * measured in pulses.
 */
- (Array*) addRests:(Array*)symbols withTime:(TimeSignature*)time andBeatarray:(Array *)barray {
    int prevtime = 0;
    
    Array* result = [Array new:[symbols count]];
    
    int i;
    for (i = 0; i < [symbols count]; i++) {
        id <MusicSymbol> symbol = [symbols get:i];
        int starttime = [symbol startTime];
        Array* rests = [self getRests:time fromStart:prevtime toEnd:starttime andBeatarray:barray];
        if (rests != nil) {
            for (int j = 0; j < [rests count]; j++) {
                /* modify by sunlie start */
                RestSymbol *r = [rests get:j];
                NoteDuration d = [r duration];
                if (d != Empty) {
                    [result add:r];
                }
//                [result add:[rests get:j]];
                /* modify by sunlie end */

            }
            [rests release];
        }
        [result add:symbol];
        
        /* Set prevtime to the end time of the last note/symbol. */
        if ([symbol isKindOfClass:[ChordSymbol class]]) {
            ChordSymbol *chord = (ChordSymbol*)symbol;
            prevtime = max( [chord endTime], prevtime );
        }
        else {
            prevtime = max(starttime, prevtime);
        }
    }
    return result;
}

/** Return the rest symbols needed to fill the time interval between
 * start and end.  If no rests are needed, return null.
 */
- (Array*) getRests:(TimeSignature*)time fromStart:(int)start toEnd:(int)end andBeatarray:(Array *)barray {
    Array* result = [Array new:10];
    RestSymbol *r1, *r2;
    
    if (end - start <= 0) {
        [result release];
        return nil;
    }
    
    if ([barray count] > 1) {
        [time setNumerator:[[barray get:0] numerator]];
        [time setDenominator:[[barray get:0] denominator]];
        [time setMeasure];
// needed modiby by sunlie
//        int j = 0;
//        BeatSignature *beat1;
//        BeatSignature *beat2;
//        for (j=0; j<[barray count]-1; j++) {
//            beat1 = [barray get:j];
//            beat2 = [barray get:j+1];
//            if (start >= [beat1 starttime] && start <[beat2 starttime]) {
//                break;
//            }
//        }
//        [time setNumerator:[beat1 numerator]];
//        [time setDenominator:[beat1 denominator]];
//        [time setMeasure];
//        [beat1 release];
//        [beat2 release];
    }
    
    /** modify by sunlie start */
    if (start/[time measure] < (end-[time quarter]/16)/[time measure]) {
        do {
            NoteDuration nd = [time getNoteDuration:[time measure]-start%[time measure]];
            switch (nd) {
                case Whole:
                case Half:
                case Quarter:
                case Eighth:
                    r1 = [[RestSymbol alloc] initWithTime:start andDuration:nd];
                    [result add:r1];
                    [r1 release];
                    break;
                    
                case DottedHalf:
                    r1 = [[RestSymbol alloc] initWithTime:start andDuration:Half];
                    r2 = [[RestSymbol alloc] initWithTime:(start + [time quarter]*2)
                                              andDuration:Quarter];
                    [result add:r1]; [result add:r2];
                    [r1 release]; [r2 release];
                    break;
                    
                case DottedQuarter:
                    r1 = [[RestSymbol alloc] initWithTime:start andDuration:Quarter];
                    r2 = [[RestSymbol alloc] initWithTime:(start + [time quarter])
                                              andDuration:Eighth];
                    [result add:r1]; [result add:r2];
                    [r1 release]; [r2 release];
                    break;
                    
                case DottedEighth:
                    r1 = [[RestSymbol alloc] initWithTime:start andDuration:Eighth];
                    r2 = [[RestSymbol alloc] initWithTime:(start + [time quarter]/2)
                                              andDuration:Sixteenth];
                    [result add:r1]; [result add:r2];
                    [r1 release]; [r2 release];
                    break;
                    
                case Empty:
                    r1 = [[RestSymbol alloc] initWithTime:start andDuration:Empty];
                    [result add:r1];
                    [r1 release];
                    break;
                    
                default: ;
            }
            r1 = [[RestSymbol alloc] initWithTime:start andDuration:Empty];
            [result add:r1];
            [r1 release];
            start = start + [time measure] - start%[time measure];
            if ([barray count]>1) {
                [time setNumerator:[[barray get:0] numerator]];
                [time setDenominator:[[barray get:0] denominator]];
                [time setMeasure];
// needed modiby by sunlie
//                int j = 0;
//                BeatSignature *beat1;
//                BeatSignature *beat2;
//                for (j= 0; j< [barray count]-1; j++) {
//                    beat1 = [barray get:j];
//                    beat2 = [barray get:j+1];
//                    if(start>=[beat1 starttime] && start<[beat2 starttime]) {
//                        break;
//                    }
//                }
//                [time setNumerator:[beat1 numerator]];
//                [time setDenominator:[beat1 denominator]];
//                [time setMeasure];
//                [beat1 release];
//                [beat2 release];
            }
        } while (start/[time measure] < (end-[time quarter]/16)/[time measure]);
    }
    
    NoteDuration dur = [time getNoteDuration:(end - start)];
    switch (dur) {
        case Whole:
        case Half:
        case Quarter:
        case Eighth:
            r1 = [[RestSymbol alloc] initWithTime:start andDuration:dur];
            [result add:r1];
            [r1 release];
            break;
            
        case DottedHalf:
            r1 = [[RestSymbol alloc] initWithTime:start andDuration:Half];
            r2 = [[RestSymbol alloc] initWithTime:(start + [time quarter]*2)
                                      andDuration:Quarter];
            [result add:r1]; [result add:r2];
            [r1 release]; [r2 release];
            break;
            
        case DottedQuarter:
            r1 = [[RestSymbol alloc] initWithTime:start andDuration:Quarter];
            r2 = [[RestSymbol alloc] initWithTime:(start + [time quarter])
                                      andDuration:Eighth];
            [result add:r1]; [result add:r2];
            [r1 release]; [r2 release];
            break;
            
        case DottedEighth:
            r1 = [[RestSymbol alloc] initWithTime:start andDuration:Eighth];
            r2 = [[RestSymbol alloc] initWithTime:(start + [time quarter]/2)
                                      andDuration:Sixteenth];
            [result add:r1]; [result add:r2];
            [r1 release]; [r2 release];
            break;
            
        case Empty:
            r1 = [[RestSymbol alloc] initWithTime:start andDuration:Empty];
            [result add:r1];
            [r1 release];
            break;
            
        default: ;
    }
    
    if ([result count]<=0) {
        [result release];
        return nil;
    }
    else {
        return result;
    }
    /** modify by sunlie start */
}


/** The current clef is always shown at the beginning of the staff, on
 * the left side.  However, the clef can also change from measure to
 * measure. When it does, a Clef symbol must be shown to indicate the
 * change in clef.  This function adds these Clef change symbols.
 * This function does not add the main Clef Symbol that begins each
 * staff.  That is done in the Staff() contructor.
 */
- (Array*) addClefChanges:(Array*)symbols withClefs:(ClefMeasures*)clefs
                  andTime:(TimeSignature*)time {
    
    Array* result = [Array new:[symbols count]];
    int prevclef = [clefs getClef:0];
    int i;
    for (i = 0; i < [symbols count]; i++) {
        id <MusicSymbol> symbol = [symbols get:i];
        /* A BarSymbol indicates a new measure */
        if ([symbol isKindOfClass:[BarSymbol class]]) {
            int clef = [clefs getClef:[symbol startTime]];
            if (clef != prevclef) {
                ClefSymbol *clefsym = [[ClefSymbol alloc]
                                       initWithClef:clef andTime:[symbol startTime]-1 isSmall:YES];
                [result add:clefsym];
                [clefsym release];
            }
            prevclef = clef;
        }
        [result add:symbol];
    }
    return result;
}

/** Notes with the same start times in different staffs should be
 * vertically aligned.  The SymbolWidths class is used to help
 * vertically align symbols.
 *
 * First, each track should have a symbol for every starttime that
 * appears in the Midi File.  If a track doesn't have a symbol for a
 * particular starttime, then add a "blank" symbol for that time.
 *
 * Next, make sure the symbols for each start time all have the same
 * width, across all tracks.  The SymbolWidths class stores
 * - The symbol width for each starttime, for each track
 * - The maximum symbol width for a given starttime, across all tracks.
 *
 * The method SymbolWidths.GetExtraWidth() returns the extra width
 * needed for a track to match the maximum symbol width for a given
 * starttime.
 */
- (void)alignSymbols:(Array*)allsymbols withWidths:(SymbolWidths*)widths {
    for (int track = 0; track < [allsymbols count]; track++) {
        Array *symbols = [allsymbols get:track];
        Array *result = [Array new:[symbols count]];
        
        int i = 0;
        
        /* If a track doesn't have a symbol for a starttime,
         * add a blank symbol.
         */
        IntArray *starttimes = [widths startTimes];
        int startTimesCount = [starttimes count];
        for (int w = 0; w < startTimesCount; w++) {
            int start = [starttimes get:w];
            
            /* BarSymbols are not included in the SymbolWidths calculations */
            while (i < [symbols count] &&
                   ([getSymbol(symbols, i) isKindOfClass:[BarSymbol class]]) &&
                   ([getSymbol(symbols, i) startTime] <= start)) {
                
                [result add:[symbols get:i]];
                i++;
            }
            
            if (i < [symbols count] && [getSymbol(symbols,i) startTime] == start) {
                
                while (i < [symbols count] &&
                       [getSymbol(symbols,i) startTime] == start) {
                    
                    [result add:[symbols get:i]];
                    i++;
                }
            }
            else {
                BlankSymbol *blank = [[BlankSymbol alloc] initWithTime:start andWidth:0];
                [result add:blank];
                [blank release];
            }
        }
        
        /* For each starttime, increase the symbol width by
         * SymbolWidths.GetExtraWidth().
         */
        i = 0;
        while (i < [result count]) {
            id <MusicSymbol> symbol = [result get:i];
            if ([symbol isKindOfClass:[BarSymbol class]]) {
                i++;
                continue;
            }
            int start = [symbol startTime];
            int extra = [widths getExtraWidth:track  forTime:start];
            int orig_width = [symbol width];
            assert(orig_width >= 0);
            [symbol setWidth:(orig_width + extra)];
            
            /* Skip all remaining symbols with the same starttime. */
            while (i < [result count] && [getSymbol(result, i) startTime] == start) {
                i++;
            }
        }
        symbols = nil;
        [allsymbols set:result index:track];
        [result release];
    }
}


static BOOL isChord(id x) {
    return [x isKindOfClass:[ChordSymbol class]];
}

static BOOL isBlank(id x) {
    return [x isKindOfClass:[BlankSymbol class]];
}

/** Find 2, 3, 4, or 6 chord symbols that occur consecutively (without any
 *  rests or bars in between).  There can be BlankSymbols in between.
 *
 *  The startIndex is the index in the symbols to start looking from.
 *
 *  Store the indexes of the consecutive chords in chordIndexes.
 *  Store the horizontal distance (pixels) between the first and last chord.
 *  If we failed to find consecutive chords, return false.
 */
+(BOOL)findConsecutiveChords:(Array*)symbols andTime:(TimeSignature*) time
                    andStart:(int)startIndex andIndexes:(int*) chordIndexes
                andNumChords:(int)numChords andHorizDistance:(int*)dist {
    int i = startIndex;
    while (true) {
        int horizDistance = 0;
        
        /* Find the starting chord */
        while (i < [symbols count] - numChords) {
            if (isChord([symbols get:i])) {
                ChordSymbol* c = (ChordSymbol*) [symbols get:i];
                if ([c stem] != nil) {
                    break;
                }
            }
            i++;
        }
        if (i >= [symbols count] - numChords) {
            return NO;
        }
        chordIndexes[0] = i;
        BOOL foundChords = YES;
        for (int chordIndex = 1; chordIndex < numChords; chordIndex++) {
            i++;
            int remaining = numChords - 1 - chordIndex;
            while ((i < [symbols count] - remaining) && (isBlank([symbols get:i])) ) {
                horizDistance += [getSymbol(symbols, i) width];
                i++;
            }
            if (i >= [symbols count] - remaining) {
                return NO;
            }
            if (!isChord([symbols get:i])) {
                foundChords = NO;
                break;
            }
            chordIndexes[chordIndex] = i;
            horizDistance += [getSymbol(symbols, i) width];
        }
        if (foundChords) {
            *dist = horizDistance;
            return YES;
        }
        
        /* Else, start searching again from index i */
    }
}


/** Connect chords of the same duration with a horizontal beam.
 *  numChords is the number of chords per beam (2, 3, 4, or 6).
 *  if startBeat is true, the first chord must start on a quarter note beat.
 */
-(void)createBeamedChords:(Array*)allsymbols withTime:(TimeSignature*)time
             andNumChords:(int)numChords onBeat:(BOOL)startBeat {
    int chordIndexes[6];
    Array* chords = [Array new:numChords];
    
    for (int track = 0; track < [allsymbols count]; track++) {
        Array* symbols = [allsymbols get:track];
        int startIndex = 0;
        while (1) {
            int horizDistance = 0;
            BOOL found = [SheetMusic findConsecutiveChords:symbols
                                                   andTime:time
                                                  andStart:startIndex
                                                andIndexes:chordIndexes
                                              andNumChords:numChords
                                          andHorizDistance: &horizDistance];
            
            if (!found) {
                break;
            }
            [chords clear];
            for (int i = 0; i < numChords; i++) {
                [chords add: [symbols get:(chordIndexes[i])] ];
            }
            
            if ([ChordSymbol canCreateBeams:chords withTime:time onBeat:startBeat]) {
                [ChordSymbol createBeam:chords withSpacing:horizDistance];
                startIndex = chordIndexes[numChords-1] + 1;
            }
            else {
                startIndex = chordIndexes[0] + 1;
            }
            
            /* What is the value of startIndex here?
             * If we created a beam, we start after the last chord.
             * If we failed to create a beam, we start after the first chord.
             */
        }
    }
    [chords clear];
    [chords release];
}


/** Connect chords of the same duration with a horizontal beam.
 *
 *  We create beams in the following order:
 *  - 6 connected 8th note chords, in 3/4, 6/8, or 6/4 time
 *  - Triplets that start on quarter note beats
 *  - 3 connected chords that start on quarter note beats (12/8 time only)
 *  - 4 connected chords that start on quarter note beats (4/4 or 2/4 time only)
 *  - 2 connected chords that start on quarter note beats
 *  - 2 connected chords that start on any beat
 */
-(void)createAllBeamedChords:(Array*)allsymbols withTime:(TimeSignature*)time {
    /** delete by sunlie start */
    //    if (([time numerator] == 3 && [time denominator] == 4) ||
    //        ([time numerator] == 6 && [time denominator] == 8) ||
    //        ([time numerator] == 6 && [time denominator] == 4) ) {
    //
    //        [self createBeamedChords:allsymbols withTime:time
    //              andNumChords:6 onBeat:YES];
    //    }
    /** delete by sunlie end */
    /** modify by sunlie start */
    [self createBeamedChords:allsymbols withTime:time
                andNumChords:4 onBeat:YES];
    [self createBeamedChords:allsymbols withTime:time
                andNumChords:3 onBeat:YES];
    [self createBeamedChords:allsymbols withTime:time
                andNumChords:3 onBeat:NO];
    [self createBeamedChords:allsymbols withTime:time
                andNumChords:2 onBeat:YES];
    [self createBeamedChords:allsymbols withTime:time
                andNumChords:2 onBeat:NO];
    /** modify by sunlie end */
}

/** Get the width (in pixels) needed to display the key signature */
+(int)keySignatureWidth:(KeySignature*)key {
    ClefSymbol *clefsym = [[ClefSymbol alloc] initWithClef:Clef_Treble andTime:0 isSmall:NO];
    int result = [clefsym minWidth];
    [clefsym release];
    Array *keys = [key getSymbols:Clef_Treble];
    for (int i = 0; i < [keys count]; i++) {
        AccidSymbol *symbol = [keys get:i];
        result += [symbol minWidth];
    }
    return result + LeftMargin + 5;
}

/** Given MusicSymbols for a track, create the staffs for that track.
 *  Each Staff has a maxmimum width of PageWidth (800 pixels).
 *  Also, measures should not span multiple Staffs.
 */
- (Array*) createStaffsForTrack:(Array*)symbols withKey:(KeySignature*)key
                     andMeasure:(int) measurelen andOptions:(MidiOptions*)options
                       andTrack:(int)track andTotalTracks:(int)totaltracks {
    
    Array *thestaffs = [Array new:10];
    int startindex = 0;
    int keysigWidth = [SheetMusic keySignatureWidth:key];
    int idx = 0;
    
    while (startindex < [symbols count]) {
        /* startindex is the index of the first symbol in the staff.
         * endindex is the index of the last symbol in the staff.
         */
        int endindex = startindex;
        int width = keysigWidth;
        int maxwidth;
        
        /* If we're scrolling vertically, the maximum width is PageWidth. */
        if (scrollVert) {
            maxwidth = PageWidth;
        }
        else {
            maxwidth = 2000000;
        }
        
        while (endindex < [symbols count] &&
               width + [getSymbol(symbols, endindex) width] < maxwidth) {
            
            width += [getSymbol(symbols, endindex) width];
            
            endindex++;
        }
        endindex--;
        
        /* There's 3 possibilities at this point:
         * 1. We have all the symbols in the track.
         *    The endindex stays the same.
         *
         * 2. We have symbols for less than one measure.
         *    The endindex stays the same.
         *
         * 3. We have symbols for 1 or more measures.
         *    Since measures cannot span multiple staffs, we must
         *    make sure endindex does not occur in the middle of a
         *    measure.  We count backwards until we come to the end
         *    of a measure.
         */
        
        if (endindex == [symbols count] - 1) {
            /* endindex stays the same */
        }
        else if ([getSymbol(symbols, startindex) startTime] / measurelen ==
                 [getSymbol(symbols, endindex) startTime] / measurelen) {
            /* endindex stays the same */
        }
        else {
            int endmeasure = [getSymbol(symbols, endindex+1) startTime]/measurelen;
            while ([getSymbol(symbols, endindex) startTime] / measurelen == endmeasure) {
                endindex--;
            }
        }
        Array *staffsymbols = [symbols range:startindex end:endindex+1];
        if (scrollVert) {
            width = PageWidth;
        }
        
        /** add by yizhq start */
        for (int i = startindex; i <= endindex; i++) {
            NSString *staffNo = [[NSString alloc]initWithFormat:@"%i-%i",track, idx];
            if ([[symbols get:i] isKindOfClass:[ChordSymbol class]]) {
                [[symbols get:i] setStaffNo:staffNo];
            }
        }
        /** add by yizhq end */
        Staff *staff = [[Staff alloc] initWithSymbols:staffsymbols
                                               andKey:key andOptions:options
                                             andTrack:track andTotalTracks:totaltracks];
        
        [staffsymbols release];
        [thestaffs add:staff];
        [staff release];
        startindex = endindex + 1;
        /** add by yizhq start */
        idx++;
        /** add by yizhq end */
    }
    return thestaffs;
}



/** Given all the MusicSymbols for every track, create the staffs
 * for the sheet music.  There are two parts to this:
 *
 * - Get the list of staffs for each track.
 *   The staffs will be stored in trackstaffs as:
 *
 *   trackstaffs[0] = { Staff0, Staff1, Staff2, ... } for track 0
 *   trackstaffs[1] = { Staff0, Staff1, Staff2, ... } for track 1
 *   trackstaffs[2] = { Staff0, Staff1, Staff2, ... } for track 2
 *
 * - Store the Staffs in the staffs list, but interleave the
 *   tracks as follows:
 *
 *   staffs = { Staff0 for track 0, Staff0 for track1, Staff0 for track2,
 *              Staff1 for track 0, Staff1 for track1, Staff1 for track2,
 *              Staff2 for track 0, Staff2 for track1, Staff2 for track2,
 *              ... }
 */
- (Array*) createStaffs:(Array*) allsymbols withKey:(KeySignature*)key
             andOptions:(MidiOptions*)options andMeasure:(int)measurelen  {
    
    Array *trackstaffs = [Array new:[allsymbols count]];
    int totaltracks = [allsymbols count];
    
    for (int track = 0; track < totaltracks; track++) {
        Array* symbols = [allsymbols get:track];
        Array *trackstaff = [self createStaffsForTrack:symbols withKey:key
                                            andMeasure:measurelen andOptions:options
                                              andTrack:track andTotalTracks:totaltracks];
        [trackstaffs add:trackstaff];
        [trackstaff release];
    }
    
    /* Update the endTime of each Staff. The endTime is used during shading */
    for (int track = 0; track < [trackstaffs count]; track++) {
        Array *thestaffs = (Array*)[trackstaffs get:track];
        for (int i = 0; i < [thestaffs count]-1; i++) {
            Staff *staff = [thestaffs get:i];
            [staff setEndTime: [[thestaffs get:i+1] startTime]];
        }
    }
    
    /* Interleave the staffs of each track into the result array */
    int maxstaffs = 0;
    for (int i = 0; i < [trackstaffs count]; i++) {
        if (maxstaffs < [(Array*)[trackstaffs get:i] count]) {
            maxstaffs = [(Array*)[trackstaffs get:i] count];
        }
    }
    Array *result = [Array new:(maxstaffs * [trackstaffs count]) ];
    for (int i = 0; i < maxstaffs; i++) {
        for (int track = 0; track < [trackstaffs count]; track++) {
            Array *list = [trackstaffs get:track];
            if (i < [list count]) {
                Staff *s = [list get:i];
                [result add:s];
            }
        }
    }
    
    [trackstaffs release];
    
    return result;
}

/** Set the note colors to use */
- (void)setColors:(Array*)newcolors andShade:(UIColor*)s andShade2:(UIColor*)s2  {
    if (newcolors != nil) {
        for (int i = 0; i < 12; i++) {
            NoteColors[i] = [newcolors get:i];
        }
    }
    else {
        for (int i = 0; i < 12; i++) {
            NoteColors[i] = [UIColor blackColor];
        }
    }
    
    shadeColor = s;
    shade2Color = s2;
}

/** Retrieve the color for a given note number */
- (UIColor*)noteColor:(int)number {
    return NoteColors[ notescale_from_number(number) ];
}

/** Retrieve the shade color */
- (UIColor*)shadeColor {
    return shadeColor;
}

/** Retrieve the shade2 color */
- (UIColor*)shade2Color {
    return shade2Color;
}

/** Get the lyrics for each track */
-(Array*)getLyrics:(Array*)tracks {
    BOOL hasLyrics = NO;
    Array *result = [Array new:[tracks count]];
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        Array *lyrics = [Array new:5];
        [result add:lyrics];
        MidiTrack *track = [tracks get:tracknum];
        if ([track lyrics] == nil) {
            [lyrics release];
            continue;
        }
        hasLyrics = YES;
        for (int i = 0; i < [[track lyrics] count]; i++) {
            MidiEvent *ev = [[track lyrics] get:i];
            NSString *text = [[NSString alloc] initWithBytes:[ev metavalue] length:[ev metalength] encoding:NSUTF8StringEncoding];
            LyricSymbol *sym = [[LyricSymbol alloc] init];
            [sym setStarttime:[ev startTime]];
            [sym setText:text];
            [text release];
            [lyrics add:sym];
        }
        [lyrics release];
    }
    if (!hasLyrics) {
        [result release];
        return nil;
    }
    else {
        return result;
    }
}

/** Add the lyric symbols to the corresponding staffs */
-(void)addLyrics:(Array*)tracklyrics toStaffs:(Array*)thestaffs {
    for (int i = 0; i < [thestaffs count]; i++) {
        Staff *staff = [thestaffs get:i];
        Array *lyrics = [tracklyrics get:[staff tracknum]];
        [staff addLyrics:lyrics];
    }
}


/* Set the zoom level to display at (1.0 == 100%).
 * Recalculate the SheetMusic width and height based on the
 * zoom level.  Then redraw the SheetMusic.
 */
- (void)setZoom:(float)value {
    zoom = value;
    CGRect rect = [self frame];
    CGSize size = rect.size;
    width = 0;
    height = 0;
    for (int i = 0; i < [staffs count]; i++) {
        Staff *staff = [staffs get:i];
        width = max(width, [staff width] * zoom);
        height += ([staff height] * zoom);
    }
    size.width = (int)width + 2;
    size.height = ((int)height) + LeftMargin;
    rect.size.width = size.width;
    rect.size.height = size.height;
    
    [self setFrame:rect];
    rect = [self frame];
    //  [self display];
}

/** Return true if the sheet music should display the note letters */
- (int)showNoteLetters {
    return showNoteLetters;
}

/** Get the main key signature */
-(KeySignature*)mainkey {
    return mainkey;
}


/** Set the size of the notes, large or small.  Smaller notes means
 * more notes per staff.
 */
+(void)setNoteSize:(BOOL)largenotes {
    LineWidth = 1;
    LeftMargin = 4;
    if (largenotes)
        LineSpace = 7;
    else
        LineSpace = 5;
    
    StaffHeight = LineSpace*4 + LineWidth*5;
    NoteHeight = LineSpace + LineWidth;
    NoteWidth = (3 * LineSpace) / 2;
}
/** add by yizhq start */
+(int) getNoteWidth
{
    return NoteWidth;
}

+(int) getNoteHeight
{
    return NoteHeight;
}
/** add by yizhq end */
/** Write the MIDI file title at the top of the page */
- (void)drawTitle {
    /* Set the font attribute */
    UIFont *font = [UIFont boldSystemFontOfSize:12.0];
    NSArray *keys = [NSArray arrayWithObjects:NSFontAttributeName, nil];
    NSArray *values = [NSArray arrayWithObjects:font, nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    NSArray *parts = [filename pathComponents];
    NSString *name = [[parts lastObject] retain];
    NSString *title = [MidiFile titleName:name];
    
    CGPoint point = CGPointMake(LeftMargin, 0);
    [title drawAtPoint:point withAttributes:dict];
    [name release];
    [title release];
}


- (NSAttributedString*)pageHeader {
    NSAttributedString *attr = [[NSAttributedString alloc]
                                initWithString:@""];
    [attr autorelease];
    return attr;
}


- (NSAttributedString*)pageFooter {
    //    UIPrintOperation *op = [NSPrintOperation currentOperation];
    //    int num = [op currentPage];
    //    NSString *pagenum = [NSString stringWithFormat:@"%d", num];
    //    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]
    //                                       initWithString:pagenum];
    //    [attr setAlignment:NSRightTextAlignment range:NSMakeRange(0, [pagenum length])];
    //    [attr autorelease];
    //    return attr;
    return nil;
}


/** Draw the SheetMusic.
 * If drawing to the screen, scale the graphics by the current zoom factor.
 * If printing, scale the graphics by the paper page size.
 * Get the vertical start and end points of the clip area.
 * Only draw Staffs which lie inside the clip area.
 */
- (void)drawRect:(CGRect)rect {
    //    NSGraphicsContext *gc = [NSGraphicsContext currentContext];
    //    [gc setShouldAntialias:YES];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [[UIColor whiteColor] setFill];
    [path fill];
    [[UIColor blackColor] setFill];
    
    //    NSAffineTransform *trans;
    CGRect clip;
    
    //    if ([NSGraphicsContext currentContextDrawingToScreen]) {
    //        trans = [NSAffineTransform transform];
    //        [trans scaleXBy:zoom yBy:zoom];
    //        [trans concat];
    CGContextScaleCTM(context, zoom, zoom);
    clip = CGRectMake((int)(rect.origin.x / zoom),
                      (int)(rect.origin.y / zoom),
                      (int)(rect.size.width / zoom),
                      (int)(rect.size.height / zoom) );
    //    }
    //    else {
    //        NSSize pagesize = [self printerPageSize];
    //        float scale = pagesize.width / (1.0 * PageWidth);
    //        trans = [NSAffineTransform transform];
    //        [trans scaleXBy:scale yBy:scale];
    //        [trans concat];
    //        clip = NSMakeRect(0,
    //                          (int)(rect.origin.y / scale),
    //                          (int)(rect.size.width / scale),
    //                          (int)(rect.size.height / scale) );
    //        [self drawTitle];
    //    }
    
    int ypos = TitleHeight;
    
    for (int i =0; i < [staffs count]; i++) {
        Staff *staff = [staffs get:i];
        if ((ypos + [staff height] < clip.origin.y) || (ypos > clip.origin.y + clip.size.height)) {
            /* Staff is not in the clip, don't need to draw it */
        }
        else {
            //            trans = [NSAffineTransform transform];
            //            [trans translateXBy:0 yBy:ypos];
            //            [trans concat];
            CGContextTranslateCTM (context, 0, ypos);
            
            //[staff drawRect:clip];
            [staff drawRect:context InRect:clip];
            
            NSLog(@"aaaaaaaaaaa %i", shadeCurrentPulseTime);
            if (shadePrevPulseTime != -1 && shadeCurrentPulseTime !=-10) {
                [staff shadeNotes:context withColor:shadeColor];
                
                
            }
            
            
            //            trans = [NSAffineTransform transform];
            //            [trans translateXBy:0 yBy:-ypos];
            //            [trans concat];
            CGContextTranslateCTM (context, 0, -ypos);
        }
        
        ypos += [staff height];
    }
    
    //    if ([NSGraphicsContext currentContextDrawingToScreen]) {
    //        trans = [NSAffineTransform transform];
    //        [trans scaleXBy:(1.0/zoom) yBy:(1.0/zoom)];
    //        [trans concat];
    CGContextScaleCTM (context, (1.0/zoom), (1.0/zoom));
    //    }
    //    else {
    //        NSSize pagesize = [self printerPageSize];
    //        float scale = pagesize.width / (1.0 * PageWidth);
    //        trans = [NSAffineTransform transform];
    //        [trans scaleXBy:(1.0/scale) yBy:(1.0/scale)];
    //        [trans concat];
    //    }
}


/**
 * Return the number of pages needed to print this sheet music.
 * This method is called by NSPrintOperation to
 * determine the number of pages this view has.
 *
 * A staff should fit within a single page, not be split across two pages.
 * If the sheet music has exactly 2 tracks, then two staffs should
 * fit within a single page, and not be split across two pages.
 */
- (BOOL)knowsPageRange:(NSRange*)range {
    int num = 1;
    int currheight = TitleHeight;
    CGSize pagesize = [self printerPageSize];
    float scale = pagesize.width / (1.0 * PageWidth);
    int viewPageHeight = (int)(pagesize.height / scale);
    
    if (numtracks == 2 && ([staffs count] % 2) == 0) {
        for (int i = 0; i < [staffs count]; i += 2) {
            int heights = [(Staff*)[staffs get:i] height] +
            [(Staff*)[staffs get:i+1] height];
            if (currheight + heights > viewPageHeight) {
                num++;
                currheight = heights;
            }
            else {
                currheight += heights;
            }
        }
    }
    else {
        for (int i = 0; i < [staffs count]; i++) {
            Staff *staff = [staffs get:i];
            if (currheight + [staff height] > viewPageHeight) {
                num++;
                currheight = [staff height];
            }
            else {
                currheight += [staff height];
            }
        }
    }
    range->location = 1;
    range->length = num;
    return YES;
}


/** Given a page number (for printing), return the drawing
 * rectangle that corresponds to that page number. This method
 * is used to print to a printer, and to save as a PDF file.
 */
- (CGRect)rectForPage:(int)pagenumber {
    CGSize pagesize = [self printerPageSize];
    float scale = pagesize.width / (1.0 * PageWidth);
    int viewPageHeight = (int)(pagesize.height / scale);
    
    CGRect rect = CGRectMake(0, 0, pagesize.width, 0);
    
    int pagenum = 1;
    int staffnum = 0;
    //    int ypos = 0;
    
    if (numtracks == 2 && ([staffs count] % 2) == 0) {
        /* Determine the "y" (vertical) start of the rectangle.
         * Skip the staffs until we reach the given page number
         */
        int ypos = TitleHeight;
        if (pagenumber > 1) {
            rect.origin.y = TitleHeight;
        }
        while (pagenum < pagenumber && staffnum + 1 < [staffs count]) {
            int staffheights = [(Staff*)[staffs get:staffnum] height] +
            [(Staff*)[staffs get:staffnum+1] height];
            
            if (ypos + staffheights >= viewPageHeight) {
                pagenum++;
                ypos = 0;
            }
            else {
                ypos += staffheights;
                rect.origin.y += staffheights;
                staffnum += 2;
            }
        }
        if (staffnum >= [staffs count]) {
            rect.size.height = 0;   /* Return an empty rectangle */
            return rect;
        }
        
        /* Determine the height of the rectangle to draw. */
        rect.size.height = 0;
        if (pagenumber == 1) {
            rect.size.height += TitleHeight;
        }
        for (; staffnum+1 < [staffs count]; staffnum += 2) {
            int staffheights = [(Staff*)[staffs get:staffnum] height] +
            [(Staff*)[staffs get:staffnum+1] height];
            if (rect.size.height + staffheights >= viewPageHeight) {
                break;
            }
            rect.size.height += staffheights;
        }
    }
    
    else {
        /* Determine the "y" (vertical) start of the rectangle.
         * Skip the staffs until we reach the given page number
         */
        int ypos = TitleHeight;
        if (pagenumber > 1) {
            rect.origin.y = TitleHeight;
        }
        while (pagenum < pagenumber && staffnum < [staffs count]) {
            int staffheight = [(Staff*)[staffs get:staffnum] height];
            
            if (ypos + staffheight >= viewPageHeight) {
                pagenum++;
                ypos = 0;
            }
            else {
                ypos += staffheight;
                rect.origin.y += staffheight;
                staffnum++;
            }
        }
        if (staffnum >= [staffs count]) {
            rect.size.height = 0;   /* Return an empty rectangle */
            return rect;
        }
        
        /* Determine the height of the rectangle to draw. */
        rect.size.height = 0;
        if (pagenumber == 1) {
            rect.size.height = TitleHeight;
        }
        for (; staffnum < [staffs count]; staffnum++) {
            int staffheight = [(Staff*)[staffs get:staffnum] height];
            if (rect.size.height + staffheight >= viewPageHeight) {
                break;
            }
            rect.size.height += staffheight;
        }
    }
    
    /* Convert the y location and height from view coordinates to printer coordinates */
    rect.origin.x = 0;
    rect.origin.y = rect.origin.y * scale;
    rect.size.width = pagesize.width;
    rect.size.height = rect.size.height * scale;
    
    return rect;
}

/** Get the height of the printer page */
- (CGSize)printerPageSize {
    
    //UIPrintInfo *info = [[UIPrintOperation currentOperation] printInfo];
    //CGSize size = [info paperSize];
    CGSize size = CGSizeMake(0,0);
    //    size.height = size.height - [info topMargin] - [info bottomMargin];
    //    size.width = size.width - [info leftMargin] - [info rightMargin];
    return size;
}

/** Shade all the chords played at the given pulse time.
 *  Loop through all the staffs and call staff.shadeNotes().
 *  If scrollGradually is true, scroll gradually (smooth scrolling)
 *  to the shaded notes.
 */
- (void)shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime 
                   gradualScroll:(BOOL)gradualScroll {
//    if (![self canDraw]) {
//        return;
//    }
//    [self lockFocus];
    shadeCurrentPulseTime = currentPulseTime;
    shadePrevPulseTime = prevPulseTime;
    
    //    NSGraphicsContext *gc = [NSGraphicsContext currentContext];
    //    [gc setShouldAntialias:YES];
    
    //    NSAffineTransform *trans = [NSAffineTransform transform];
    //    [trans scaleXBy:zoom yBy:zoom];
    //    [trans concat];
    
    
    int ypos = TitleHeight;
    int x_shade = 0;
    int y_shade = 0;
    
    for (int i = 0; i < [staffs count]; i++) {
        Staff *staff = [staffs get:i];
        //        trans = [NSAffineTransform transform];
        //        [trans translateXBy:0 yBy:ypos];
        //        [trans concat];
        
//        [staff shadeNotes:context withCurr:currentPulseTime withPrev:prevPulseTime andX:&x_shade andColor:shadeColor];
        
        //        trans = [NSAffineTransform transform];
        //        [trans translateXBy:0 yBy:-ypos];
        //        [trans concat];
        
        ypos += [staff height];
        if (currentPulseTime >= [staff endTime]) {
            y_shade += [staff height];
        }
        
        int ret = [staff calcShadeNotes:currentPulseTime withPrev:prevPulseTime andX:&x_shade];

        
        //        trans = [NSAffineTransform transform];
        //        [trans translateXBy:0 yBy:-ypos];
        //        [trans concat];
        
//        ypos += [staff height];

    }
    
    //    trans = [NSAffineTransform transform];
    //    [trans scaleXBy:(1.0/zoom) yBy:(1.0/zoom)];
    //    [trans concat];
    
    x_shade = (int)(x_shade * zoom);
    y_shade -= NoteHeight;
    y_shade = (int)(y_shade * zoom);
    
//    CGPoint shadePos;
    shadePos.x = x_shade;
    shadePos.y = y_shade;
    if (currentPulseTime >= 0) {
        [self scrollToShadedNotes:shadePos gradualScroll:gradualScroll];
    }
    
    //    [[UIGraphicsContext currentContext] flushGraphics];
    //[self unlockFocus];
	[self setNeedsDisplay];
}


-(void)shadeNotesByModel1:(int)staffIndex andChordIndex:(int)chordIndex andChord:(ChordSymbol*)chord
{
    int ypos = TitleHeight;
    int x_shade = 0;
    int y_shade = 0;
    
    shadeCurrentPulseTime = [chord startTime];
    shadePrevPulseTime = [chord startTime];


    for (int i = 0; i <= index; i++) {
        Staff *staff = [staffs get:i];
        y_shade += [staff height];
        
        if (i == index) {
            [staff setShadeNotesModel1:chordIndex withChordSymbol:chord andX:&x_shade];
        }
    }
    

    x_shade = (int)(x_shade * zoom);
    y_shade -= NoteHeight;
    y_shade = (int)(y_shade * zoom);
    
    shadePos.x = x_shade;
    shadePos.y = y_shade;

    [self scrollToShadedNotes:shadePos gradualScroll:YES];
    [self setNeedsDisplay];
}


/** Scroll the sheet music so that the shaded notes are visible.
 * If scrollGradually is true, scroll gradually (smooth scrolling)
 * to the shaded notes.
 */
- (void)scrollToShadedNotes:(CGPoint)shadePos gradualScroll:(BOOL)gradualScroll {
    int x_shade1 = shadePos.x;
    int y_shade = shadePos.y;

    
//    UIClipView *clipview = (UIClipView*) [self superview];
//    UIScrollView *scrollView = (UIScrollView*) [self superview];
//    CGRect scrollRect = scrollView.frame;
//    
//
    
    static int y_pos = 0;
    CGPoint newPos;
    newPos.x = 0; newPos.y = y_pos;

    if (scrollVert) {
        int scrollDist = (int)(y_shade - y_pos);

        if (gradualScroll) {
            if (scrollDist > (zoom * StaffHeight * 8))
                scrollDist = scrollDist / 2;
            else if (scrollDist > (NoteHeight * 3 * zoom))
                scrollDist = (int)(NoteHeight * 3 * zoom);
        }
        newPos.y += scrollDist;
        y_pos = newPos.y;
    }
    else {
//        int x_view = (int)(scrollRect.origin.x + 40 * scrollRect.size.width/100);
//        int xmax   = (int)(scrollRect.origin.x + 65 * scrollRect.size.width/100);
//        int scrollDist = x_shade1 - x_view;
//
//        if (gradualScroll) {
//            if (x_shade1 > xmax)
//                scrollDist = (x_shade1 - x_view)/3;
//            else if (x_shade1 > x_view)
//                scrollDist = (x_shade1 - x_view)/6;
//        }
//
//        newPos.x += scrollDist;
//        if (newPos.x < 0) {
//            newPos.x = 0;
//        }
    }

    [scrollView setContentOffset:newPos animated:NO];
//    [clipview scrollToPoint:scrollView];
//    [scrollView reflectScrolledClipView:clipview];
}


/** Return the font attributes for drawing note letters
 *  and measure numbers.
 */
static NSDictionary *fontAttr = NULL;
+(NSDictionary*)fontAttributes {
    if (fontAttr == NULL) {
        UIFont *font = [UIFont boldSystemFontOfSize:10.0];
        NSArray *keys = [NSArray arrayWithObjects:NSFontAttributeName, nil];
        NSArray *values = [NSArray arrayWithObjects:font, nil];
        fontAttr = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        fontAttr = [fontAttr retain];
    }
    return fontAttr;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)isFlipped {
    return YES;
}

- (void)dealloc {
    [staffs release];
    [super dealloc];
}


- (NSString*) description {
    NSString *result = [NSString stringWithFormat:@"SheetMusic staffs=%d\n", [staffs count]];
    for (int i = 0; i < [staffs count]; i++) {
        Staff *staff = [staffs get:i];
		result = [result stringByAppendingString:[staff description]];
    }
    result = [result stringByAppendingString:@"End SheetMusic\n"];
    return result;
}


/** add by yizhq start*/
-(void) CreateConnectNodes:(Array*)allsymbols andTime:(TimeSignature *)time
{
    for (int i = 0; i < [allsymbols count]; i++)
    {
        Array *symbols = [allsymbols get:i];
        for(int k = 0; k < [symbols count]; k++)
        {
            if ([[symbols get:k] isKindOfClass:[ChordSymbol class]]) {
                
                [[symbols get:k] setConnectNoteWidth:nil withNoteData:nil andNoteWidth:-1];
                NoteData *nds = [[symbols get:k] notedata];
                if([[symbols get:k] getNotedata] == nil)
                {
                    continue;
                }
                
                for (int j = 0; j < [[symbols get:k] notedata_len]; j++) {
                    if(nds[j].next == 1)
                    {
                        int index = 0;
                        int bi = 0;
                        NoteData *n = [self getConnectWidth:symbols andIndex:&index andWidth:&bi andNoteData:&nds[j] andStartIndex:k+1];
                        NSLog(@"index is %d",index);
                        if (index != 0) {
                            ChordSymbol *c = [symbols get:index];
                           
                            NSLog(@"-------- staffno1[%@]  staff no is %@ oooooooooo %i--------", [[symbols get:k] getStaffNo], [c getStaffNo], bi);
                            
                            if ([[[symbols get:k] getStaffNo] isEqualToString:[c getStaffNo]]) {

                                [[symbols get:k] setConnectNoteWidth:c withNoteData:&nds[j] andNoteWidth:bi];
                            }else{
                                [[symbols get:k] setConnectNoteWidth:c withNoteData:&nds[j] andNoteWidth:20];
                                [c setConnectNoteWidth2:n andNoteWidth:-15];
                            }
                        }
                        break;
                    }
                }
            }
        
        }
    }
}


-(NoteData *) getConnectWidth:(Array *)symbols andIndex:(int *)index andWidth:(int*)inWidth andNoteData:(NoteData *)note andStartIndex:(int)startIndex
{
    NoteData *ret = nil;
    *inWidth = 0;
    
    for (int i = startIndex; i < [symbols count]; i++) {
        id <MusicSymbol> s = [symbols get:i];
        *inWidth += [s width];

        if ([[symbols get:i] isKindOfClass:[ChordSymbol class]]) {
            ChordSymbol *chord = [symbols get:i];
            NoteData *nds = [chord notedata];
            if(nds == nil)
            {
                continue;
            }
            
            for (int j = 0; j < [chord notedata_len]; j++) {
                if (nds[j].number == note->number) {
                    *index = i;
                    ret = &(nds[j]);
                    return ret;
                }
            }
        }
    }
    
    if (*inWidth == 0) {
        *inWidth = -1;
    }
    
    return ret;
}

/** add by yizhq end */

/** add by sunlie start */
-(void) CreateConLineNodes:(Array*)allsymbols andTime:(TimeSignature *)time
{
    int i = 0;
    int lineWidth, lineWidth1;
    
    for (int k = 0; k < [allsymbols count]; k++) {
        Array* symbols = [allsymbols get:k];
        while (i<[symbols count] - 1) {
            if ([[symbols get:i] isKindOfClass:[ChordSymbol class]]) {
                ChordSymbol *chord = [symbols get:i];
                if ([chord conLine] > 0) {
                    int j = i+1;
                    while (j < [symbols count]) {
                        if ([[symbols get:j] isKindOfClass:[ChordSymbol class]]) {
                            ChordSymbol *cho = [symbols get:j];
                            if ([chord conLine] == [cho conLine]) {
//                                while ([cho connectChordSymbol] != nil) {
//                                    cho = [cho connectChordSymbol];
//                                    j++;
//                                }
                                [chord setConLineChord:cho];
                                [cho setConLine:-1];
                                [self getConLineWidth:symbols andStartIndex:i+1 andEndIndex:j andLineWidth:&lineWidth andLineWidth1:&lineWidth1];
                                if ([[chord getStaffNo] isEqualToString:[cho getStaffNo]]) {
                                    [chord setConLineWidth:lineWidth];
                                } else {
                                    [chord setConLineWidth:lineWidth];
                                    [chord setConLine:-1];
                                    [[chord _conLineChord] setConLineWidth:-lineWidth1];
                                }
                                i = j;
                                break;
                            }
                        }
                        j++;
                    }
                }
            }
            i++;
        }
    }
    
}

-(void) getConLineWidth:(Array *)symbols andStartIndex:(int)startIndex andEndIndex:(int)endIndex andLineWidth:(int *)lineWidth andLineWidth1:(int *)lineWidth1{
    ChordSymbol *prechord = nil;
    ChordSymbol *curchord = nil;
    *lineWidth = 0;
    *lineWidth1 = 0;
    int i;
    
    for (i = startIndex; i <= endIndex; i++) {
        if ([[symbols get:i] isKindOfClass:[ChordSymbol class]]) {
            if (curchord == nil) {
                prechord = [symbols get:i];
            }
            else {
                prechord = curchord;
            }
            curchord = [symbols get:i];
            if (![[prechord getStaffNo] isEqualToString:[curchord getStaffNo]]) {
                break;
            }
        }
        id <MusicSymbol> s = [symbols get:i];
        *lineWidth += [s width];
    }
    
    while (i <= endIndex) {
        id <MusicSymbol> s = [symbols get:i];
        *lineWidth1 += [s width];
        i++;
    }
    
    if (*lineWidth == 0) {
        *lineWidth = -1;
    }
    
    return;
}

-(void) CreateEightNodes:(Array*)allsymbols andTime:(TimeSignature *)time
{
    int i = 0;
    int j = 0;
    int value = 0;
    
    for (int k = 0; k < [allsymbols count]; k++) {
        Array* symbols = [allsymbols get:k];
        i = 0;
        while (i <[symbols count] - 1) {
            if ([[symbols get:i] isKindOfClass:[ChordSymbol class]]) {
                ChordSymbol *chord = [symbols get:i];
                if ([chord eightFlag] != 0) {
                    if (([chord eightFlag] > 1 || [chord eightFlag] < -1) && value == 0) {
                        value = [chord eightFlag];
                    } else if (value != 0 && [chord eightFlag] == value) {
                        value = 0;
                        i++;
                        continue;
                    }
                    j = i+1;
                    while (j < [symbols count]) {
                        if ([[symbols get:j] isKindOfClass:[ChordSymbol class]]) {
                            ChordSymbol *cho = [symbols get:j];
                            if (!([[chord getStaffNo] isEqualToString:[cho getStaffNo]])) {
                                [chord setEightWidth:-[self caculatorWidth:symbols andStartIndex:i+1 andEndIndex:j-1]];
                                i = j-1;
                                break;
                            } else if (value != 0 && [cho eightFlag] == value) {
                                [chord setEightWidth:[self caculatorWidth:symbols andStartIndex:i+1 andEndIndex:j]];
                                value = 0;
                                i = j;
                                break;
                            }
                        }
                        j++;
                    }
                }
            }
            i++;
        }
    }
}

-(int) caculatorWidth:(Array *)symbols andStartIndex:(int)startIndex andEndIndex:(int)endIndex {

    int i;
    int eightWidth = 0;
    
    for (i = startIndex; i <= endIndex; i++) {
        id <MusicSymbol> s = [symbols get:i];
        eightWidth += [s width];
    }
    
    return eightWidth;
}

/** add by sunlie end */

-(Array*)getStaffs
{
    return staffs;
}

-(int) getTrackCounts
{
    return numtracks;
}

@end


