/*
 * Copyright (c) 2009-2011 Madhav Vaidyanathan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */

#import "ChordSymbol.h"
#import "ClefSymbol.h"
#import "SheetMusic.h"

#define max(x,y) ((x) > (y) ? (x) : (y))
#define min(x,y) ((x) < (y) ? (x) : (y))   /** add by sunlie */
/** add by yizhq start */
#define PI 3.1415926
/** add by yizhq end */

#define NUMERATOR 0.5

static UIImage* right = nil;  /** The right image */
static UIImage* wrong = nil;    /** The wrong image */
static UIImage* perfect = nil;    /** The perfect image */

static UIImage* pedal1 = nil;    /** The pedal start image */
static UIImage* pedal2 = nil;    /** The pedal end image */
static UIImage* payin = nil;

static UIImage* shunboyin = nil;
static UIImage* niboyin = nil;
static UIImage* shunhuiyin = nil;
static UIImage* nihuiyin = nil;
static UIImage* chanyin = nil;


//static const char* s2c(id obj) {
//    NSString *s = [obj description]; 
//    const char *out = [s  cStringUsingEncoding:NSUTF8StringEncoding];
//    return out;
//}

/** @class ChordSymbol
 * A chord symbol represents a group of notes that are played at the same
 * time.  A chord includes the notes, the accidental symbols for each
 * note, and the stem (or stems) to use.  A single chord may have two 
 * stems if the notes have different durations (e.g. if one note is a
 * quarter note, and another is an eighth note).
 */

@implementation ChordSymbol


/** Create a new Chord Symbol from the given list of midi notes.
 * All the midi notes will have the same start time.  Use the
 * key signature to get the white key and accidental symbol for
 * each note.  Use the time signature to calculate the duration
 * of the notes. Use the clef when drawing the chord.
 */
- (id)initWithNotes:(Array*)midinotes andKey:(KeySignature*)key
     andTime:(TimeSignature*)time andClef:(int)c andSheet:(void*)s {

    int i;

    hastwostems = NO;
    clef = c;
    sheetmusic = s;

    starttime = [(MidiNote*)[midinotes get:0] startTime];
    endtime = [(MidiNote*)[midinotes get:0] endTime];
    minEndTime = endtime;
    for (i = 0; i < [midinotes count]; i++) {
        if (i > 1) {
            /* notes should already be sorted in increasing order (by number) */
            assert([[midinotes get:i] number] >= [[midinotes get:i-1] number]);
        }
        endtime = max(endtime, [(MidiNote*) [midinotes get:i] endTime] );
        minEndTime = min(minEndTime, [(MidiNote*) [midinotes get:i] endTime]);
        if ([[midinotes get:i] paflag] == 1) {
            paFlag = 1;
        }
        if ([[midinotes get:i] boflag] > 0) {
            boFlag = [[midinotes get:i] boflag];
        }
        if ([[midinotes get:i] huiFlag] > 0) {
            huiFlag = [[midinotes get:i] huiFlag];
        }
        if ([[midinotes get:i] trFlag] > 0) {
            trFlag = [[midinotes get:i] trFlag];
        }
    }

    notedata_len = [midinotes count];
    [self createNoteData:midinotes withKey:key andTime:time];
    

//    /* Find out how many stems we need (1 or 2) */
//    NoteDuration dur1 = notedata[0].duration;
//    NoteDuration dur2 = dur1;
//    int change = -1;
//    for (i = 0; i < notedata_len; i++) {
//        dur2 = notedata[i].duration;
//        if (dur1 != dur2) {
//            change = i;
//            break;
//        }
//    }
//
//    if (dur1 != dur2) {
//        /* We have notes with different durations.  So we will need
//         * two stems.  The first stem points down, and contains the
//         * bottom note up to the note with the different duration.
//         *
//         * The second stem points up, and contains the note with the
//         * different duration up to the top note.
//         */
//        hastwostems = YES;
//        stem1 = [[Stem alloc] initWithBottom:notedata[0].whitenote
//                              andTop:notedata[change-1].whitenote
//                              andDuration:dur1
//                              andDirection:StemDown
//                              andOverlap:[ChordSymbol notesOverlap:notedata
//                                                       withStart:0 
//                                                       andEnd:change]
//                ];
//
//        stem2 = [[Stem alloc] initWithBottom:notedata[change].whitenote
//                              andTop:notedata[notedata_len-1].whitenote
//                              andDuration:dur2
//                              andDirection:StemUp
//                              andOverlap:[ChordSymbol notesOverlap:notedata 
//                                                       withStart:change 
//                                                       andEnd: notedata_len]
//                ];
//
//    }
//    else {
//        /* All notes have the same duration, so we only need one stem. */
//        int direction = [ChordSymbol stemDirection:notedata[0].whitenote
//                                     withTop:notedata[notedata_len-1].whitenote
//                                     andClef:clef ];
//
//        stem1 = [[Stem alloc] initWithBottom:notedata[0].whitenote
//                              andTop:notedata[notedata_len-1].whitenote
//                              andDuration:dur1
//                              andDirection:direction
//                              andOverlap:[ChordSymbol notesOverlap:notedata
//                                                       withStart:0 
//                                                       andEnd:notedata_len]
//                ];
//
//        stem2 = nil;
//    }
//
//    /* For whole notes, no stem is drawn. */
//    if (dur1 == Whole) {
//        [stem1 release];
//        stem1 = nil;
//    }
//    if (dur2 == Whole) {
//        [stem2 release];
//        stem2 = nil;
//    }
//    width = [self minWidth];
//    assert(width > 0);
    
    /* add by sunlie start */
    judgedResult = 0;
    threeNotes = 0;
    conLine = 0;
    jumpedFlag = 0;
    eightFlag = 0;
    pedalFlag = 0;
    eightWidth = 0;
    stressFlag = 0;
    /* add by sunlie end */
    
    [ChordSymbol loadImages];
    
    return self;
}


/** Given the raw midi notes (the note number and duration in pulses),
 * calculate the following note data:
 * - The white key
 * - The accidental (if any)
 * - The note duration (half, quarter, eighth, etc)
 * - The side it should be drawn (left or side)
 * By default, notes are drawn on the left side.  However, if two notes
 * overlap (like A and B) you cannot draw the next note directly above it.
 * Instead you must shift one of the notes to the right.
 *
 * The KeySignature is used to determine the white key and accidental.
 * The TimeSignature is used to determine the duration.
 */
- (void)createNoteData:(Array*)midinotes withKey:(KeySignature*)key
       andTime:(TimeSignature*)time {
    
    notedata = (NoteData*) calloc([midinotes count], sizeof(NoteData));
    notedata_len = [midinotes count];
    NoteData *prev = NULL;

    for (int i = 0; i < [midinotes count]; i++) {
        MidiNote *midi = [midinotes get:i];
        NoteData *note = &(notedata[i]);
        note->number = [midi number];
        note->leftside = YES;
        note->whitenote = [key getWhiteNote:[midi number]];
        note->duration = [time getNoteDuration:([midi endTime]-[midi startTime])];
        note->accid = [key getAccidentalForNote:[midi number] 
                                 andMeasure:([midi startTime] / [time measure])];
        /* add by sunlie start */
        note->dur = [midi duration];
        note->previous = [midi previous];
        note->next = [midi next];
        note->addflag = [midi addflag];
        /* add by sunlie end */

        if (i > 0 && ( ( [note->whitenote dist:prev->whitenote]) == 1)) {
            /* This note overlaps with the previous note.
             * Change the side of this note.
             */
            if (prev->leftside) {
                note->leftside = NO;
            } else {
                note->leftside = YES;
            }
        } else {
            note->leftside = YES;
        }
        prev = note;
    }
}


/** Given the note data (the white keys and accidentals), create 
 * the Accidental Symbols and return them.
 */
- (void)createAccidSymbols {
    int count = 0;
    int i, n;
    for (i = 0; i < notedata_len; i++) {
        if (notedata[i].accid != AccidNone) {
            count++;
        }
    }
    accidsymbols = [Array new:count];
    for (n = 0; n < notedata_len; n++) {
        if (notedata[n].accid != AccidNone) {
            AccidSymbol *a = [[AccidSymbol alloc] initWithAccid:notedata[n].accid 
                              andNote:(notedata[n].whitenote) andClef:clef ];
            [accidsymbols add:a];
            [a release];
        }
    }
}

/** Calculate the stem direction (Up or down) based on the top and
 * bottom note in the chord.  If the average of the notes is above
 * the middle of the staff, the direction is down.  Else, the
 * direction is up.
 */
+(int)stemDirection:(WhiteNote*)bottom withTop:(WhiteNote*)top andClef:(int)clef {
    WhiteNote* middle;
    if (clef == Clef_Treble)
        middle = [WhiteNote allocWithLetter:WhiteNote_B andOctave:5];
    else
        middle = [WhiteNote allocWithLetter:WhiteNote_D andOctave:3];

    int dist = [middle dist:bottom] + [middle dist:top];
    [middle release];
    if (dist >= 0)
        return StemUp;
    else 
        return StemDown;
}

/** Return whether any of the notes in notedata (between start and
 * end indexes) overlap. This is needed by the Stem class to
 * determine the position of the stem (left or right of notes).
 */
+(BOOL)notesOverlap:(NoteData*)notedata withStart:(int)start andEnd:(int)end {
    for (int i = start; i < end; i++) {
        if (!notedata[i].leftside) {
            return YES;
        }
    }
    return NO;
}


/** Get the time (in pulses) this symbol occurs at.
 * This is used to determine the measure this symbol belongs to.
 */
- (int)startTime {
    return starttime;
}

/** Get the end time (in pulses) of the longest note in the chord.
 * Used to determine whether two adjacent chords can be joined
 * by a stem.
 */
- (int)endTime {
    return endtime;
}

/** Return the clef this chord is drawn in. */
- (int)clef {
    return clef;
}

/** Return true if this chord has two stems */
- (BOOL)hasTwoStems {
    return hastwostems;
}

/* add by sunlie start */
- (int)judgedResult {
    return judgedResult;
}

- (void)setJudgedResult:(int)j {
    judgedResult = j;
}

- (int)threeNotes {
    return threeNotes;
}

-(void)setThreeNotes:(int)t {
    threeNotes = t;
}

-(int)conLine {
    return conLine;
}

-(void)setConLine:(int)c {
    conLine = c;
}

-(int)minEndTime {
    return minEndTime;
}

-(int)jumpedFlag {
    return jumpedFlag;
}

-(void)setJumpedFlag:(int)j {
    jumpedFlag = j;
}

-(int)eightFlag {
    return eightFlag;
}

-(void)setEightFlag:(int)e {
    eightFlag = e;
}

-(int)pedalFlag {
    return pedalFlag;
}
-(void)setPedalFlag:(int)p {
    pedalFlag = p;
}

-(Array*)accidsymbols {
    return accidsymbols;
}

-(NoteData*)notedata {
    return notedata;
}

-(int)notedata_len {
    return notedata_len;
}

-(ChordSymbol *)_conLineChord {
    return _conLineChord;
}

-(void)setConLineChord:(ChordSymbol *)c {
    _conLineChord = c;
}

-(int)_conLineWidth {
    return _conLineWidth;
}

-(void)setConLineWidth:(int)c {
    _conLineWidth = c;
}
-(ChordSymbol *)eightChord {
    return eightChord;
}
-(void)setEightChord:(ChordSymbol *)c {
    eightChord = c;
}
-(int)eightWidth {
    return eightWidth;
}
-(void)setEightWidth:(int)c {
    eightWidth = c;
}
-(ChordSymbol *)connectChordSymbol {
    return _connectChordSymbol;
}

-(void)setBelongStaffHeight:(int)s {
    belongStaffHeight = s;
}
-(void)setStartTime:(int)s {
    starttime = s;
}
-(void)setEndTime:(int)e {
    endtime = e;
}

-(int)paFlag {
    return paFlag;
}
-(void)setPaFlag:(int)p {
    paFlag = p;
}

-(int)yiFlag {
    return yiFlag;
}

-(void)setYiFlag:(int)y {
    yiFlag = y;
}

-(void)setStemYiYin:(int)value
{
    if (stem1 != nil) {
        [stem1 setYiYin:value];
    }
    
    if (stem2 != nil) {
        [stem2 setYiYin:value];
    }
}


-(int)volumeFlag {
    return volumeFlag;
}
-(void)setVolumeFlag:(int)v {
    volumeFlag = v;
}
-(ChordSymbol *)volumeChord {
    return volumeChord;
}
-(void)setVolumeChord:(ChordSymbol *)c {
    volumeChord = c;
}
-(int)volumeWidth {
    return volumeWidth;
}
-(void)setVolumeWidth:(int)c {
    volumeWidth = c;
}
-(int)strengthFlag {
    return strengthFlag;
}
-(void)setStrengthFlag:(int)s {
    strengthFlag = s;
}
-(int)boFlag {
    return boFlag;
}
-(void)setBoFlag:(int)b {
    boFlag = b;
}
-(int)huiFlag {
    return huiFlag;
}
-(void)setHuiFlag:(int)h {
    huiFlag = h;
}
-(int)trFlag {
    return trFlag;
}
-(void)setTrFlag:(int)t {
    trFlag = t;
}
-(int)stressFlag {
    return stressFlag;
}
-(void)setStressFlag:(int)s {
    stressFlag = s;
}
-(void)setChordInfo {
    int i;
    
    [self createAccidSymbols];
    /* Find out how many stems we need (1 or 2) */
    NoteDuration dur1 = notedata[0].duration;
    NoteDuration dur2 = dur1;
    int change = -1;
    for (i = 0; i < notedata_len; i++) {
        dur2 = notedata[i].duration;
        if (dur1 != dur2) {
            change = i;
            break;
        }
    }
    
    if (dur1 != dur2) {
        /* We have notes with different durations.  So we will need
         * two stems.  The first stem points down, and contains the
         * bottom note up to the note with the different duration.
         *
         * The second stem points up, and contains the note with the
         * different duration up to the top note.
         */
        hastwostems = YES;
        stem1 = [[Stem alloc] initWithBottom:notedata[0].whitenote
                                      andTop:notedata[change-1].whitenote
                                 andDuration:dur1
                                andDirection:StemDown
                                  andOverlap:[ChordSymbol notesOverlap:notedata
                                                             withStart:0
                                                                andEnd:change]
                 ];
        
        stem2 = [[Stem alloc] initWithBottom:notedata[change].whitenote
                                      andTop:notedata[notedata_len-1].whitenote
                                 andDuration:dur2
                                andDirection:StemUp
                                  andOverlap:[ChordSymbol notesOverlap:notedata
                                                             withStart:change
                                                                andEnd: notedata_len]
                 ];
        
    }
    else {
        /* All notes have the same duration, so we only need one stem. */
        int direction = [ChordSymbol stemDirection:notedata[0].whitenote
                                           withTop:notedata[notedata_len-1].whitenote
                                           andClef:clef ];
        
        stem1 = [[Stem alloc] initWithBottom:notedata[0].whitenote
                                      andTop:notedata[notedata_len-1].whitenote
                                 andDuration:dur1
                                andDirection:direction
                                  andOverlap:[ChordSymbol notesOverlap:notedata
                                                             withStart:0
                                                                andEnd:notedata_len]
                 ];
        
        stem2 = nil;
    }
    
    /* For whole notes, no stem is drawn. */
    if (dur1 == Whole) {
        [stem1 release];
        stem1 = nil;
    }
    if (dur2 == Whole) {
        [stem2 release];
        stem2 = nil;
    }
    
//    yiFlag = 1;//add test by zyw
    
    [self setStemYiYin:yiFlag];
    
    width = [self minWidth];
    assert(width > 0);

}
/* add by sunlie end */

/* Return the stem will the smallest duration.  This property
 * is used when making chord pairs (chords joined by a horizontal
 * beam stem). The stem durations must match in order to make
 * a chord pair.  If a chord has two stems, we always return
 * the one with a smaller duration, because it has a better 
 * chance of making a pair.
 */
- (Stem*)stem {
    if (stem1 == nil) { return stem2; }
    else if (stem2 == nil) { return stem1; }
    else if ([stem1 duration] < [stem2 duration]) { return stem1; }
    else { return stem2; }
}

/** add by yizhq start */
- (Stem*)stem1
{
    return stem1;
}
/** add by yizhq end */

/** Get the width (in pixels) of this symbol. The width is set
 * in SheetMusic:alignSymbols to vertically align symbols.
 */
- (int)width {
    return width;
}

/** Set the width (in pixels) of this symbol. The width is set
 * in SheetMusic:alignSymbols to vertically align symbols.
 */
- (void)setWidth:(int)w {
    width = w;
}

/** Get the minimum width (in pixels) needed to draw this symbol.
 *
 * The accidental symbols can be drawn above one another as long
 * as they don't overlap (they must be at least 6 notes apart).
 * If two accidental symbols do overlap, the accidental symbol
 * on top must be shifted to the right.  So the width needed for
 * accidental symbols depends on whether they overlap or not.
 *
 * If we are also displaying the letters, include extra width.
 */
- (int)minWidth {
    /* The width needed for the note circles */
    int result = 2 * NoteHeight + NoteHeight * 3/4;
    
    if (yiFlag == 1) {
        result = result * NUMERATOR;
    }
    
    if ([accidsymbols count] > 0) {
        AccidSymbol *first = [accidsymbols get:0];
        result += [first minWidth];
        for (int i = 1; i < [accidsymbols count]; i++) {
            AccidSymbol *accid = [accidsymbols get:i];
            AccidSymbol *prev = [accidsymbols get:(i-1)];
            if ([[accid note] dist:[prev note]] < 6) {
                result += [accid minWidth];
            }
        }
    }
    SheetMusic *sheet = (SheetMusic*)sheetmusic;
    if (sheet != nil && [sheet showNoteLetters] != NoteNameNone) {
        result += 8;
    }
    
    if (paFlag == 1) {
        result += [payin size].width;
    }
    return result;
}


/** Get the number of pixels this symbol extends above the staff. Used
 *  to determine the minimum height needed for the staff (Staff:findBounds).
 */
- (int)aboveStaff {
    /* Find the topmost note in the chord */
    WhiteNote *topnote = notedata[ notedata_len-1 ].whitenote;

   /* The stem.End is the note position where the stem ends.
    * Check if the stem end is higher than the top note.
    */
    if (stem1 != nil)
        topnote = [WhiteNote max:topnote and:[stem1 end]];
    if (stem2 != nil)
        topnote = [WhiteNote max:topnote and:[stem2 end]];

    int dist = [topnote dist:[WhiteNote top:clef]] * NoteHeight/2;
    int result = 0;
    if (dist > 0)
        result = dist;
    result += 20;
    
    /** add by sunlie start */
//    if (conLine != 0) {
//        result += 1;
//    } else {
//        if (boFlag != 0 || huiFlag != 0 || trFlag != 0) {
//            result += [chanyin size].height;
//        }
//    }
    /** add by sunlie end */

    
    /* Check if any accidental symbols extend above the staff */
    int i;
    for (i = 0; i < [accidsymbols count]; i++) {
        AccidSymbol* symbol = [accidsymbols get:i];
        if ([symbol aboveStaff] > result) {
            result = [symbol aboveStaff];
        }
    }
    return result;
}

/** Get the number of pixels this symbol extends below the staff. Used
 *  to determine the minimum height needed for the staff (Staff:findBounds).
 */
- (int) belowStaff {
    /* Find the bottom note in the chord */
    WhiteNote* bottomnote = notedata[0].whitenote;

    /* The stem.End is the note position where the stem ends.
     * Check if the stem end is lower than the bottom note.
     */
    if (stem1 != nil)
        bottomnote = [WhiteNote min:bottomnote and:[stem1 end]];
    if (stem2 != nil)
        bottomnote = [WhiteNote min:bottomnote and:[stem2 end]];

    int dist = [[WhiteNote bottom:clef] dist:bottomnote] * NoteHeight/2;

    int result = 0;
    if (dist > 0)
        result = dist;
    
    result += 20;
//    /** add by sunlie start */
//    if (conLine > 0) {
//        result += 40;
//    } else if (conLine < 0) {
//        result += 35;
//    }
//    /** add by sunlie end */
//
//    if (pedalFlag != 0) {
//        result += pedal1.size.height;
//    }
    
    
    /* Check if any accidental symbols extend below the staff */
    int i;
    for (i = 0; i < [accidsymbols count]; i++) {
        AccidSymbol *symbol = [accidsymbols get:i]; 
        if ([symbol belowStaff] > result) {
            result = [symbol belowStaff];
        }
    }
    return result;
}


/** Get the name for this note */
-(NSString*)noteNameFromNumber:(int)notenumber andWhiteNote:(WhiteNote*)whitenote {
    SheetMusic *sheet = (SheetMusic*)sheetmusic;
    int notename = [sheet showNoteLetters];
    if (notename == NoteNameLetter) {
        return [self letterFromNumber:notenumber andWhiteNote:whitenote];
    }
    else if (notename == NoteNameFixedDoReMi) {
        NSArray *fixedDoReMi = [NSArray arrayWithObjects:
            @"La", @"Li", @"Ti", @"Do", @"Di", @"Re", @"Ri", @"Mi", @"Fa", @"Fi", @"So", @"Si", nil
        ];
        int notescale = notescale_from_number(notenumber);
        return [fixedDoReMi objectAtIndex:notescale];
    }
    else if (notename == NoteNameMovableDoReMi) {
        NSArray *fixedDoReMi = [NSArray arrayWithObjects:
            @"La", @"Li", @"Ti", @"Do", @"Di", @"Re", @"Ri", @"Mi", @"Fa", @"Fi", @"So", @"Si", nil
        ];
        int mainscale = [[sheet mainkey] notescale];
        int diff = NoteScale_C - mainscale;
        notenumber += diff;
        if (notenumber < 0) {
            notenumber += 12;
        }
        int notescale = notescale_from_number(notenumber);
        return [fixedDoReMi objectAtIndex:notescale];
    }
    else if (notename == NoteNameFixedNumber) {
        NSArray *num = [NSArray arrayWithObjects:
            @"10", @"11", @"12", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil
        ];
        int notescale = notescale_from_number(notenumber);
        return [num objectAtIndex:notescale];
    }
    else if (notename == NoteNameMovableNumber) {
        NSArray *num = [NSArray arrayWithObjects:
            @"10", @"11", @"12", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil
        ];
        int mainscale = [[sheet mainkey] notescale];
        int diff = NoteScale_C - mainscale;
        notenumber += diff;
        if (notenumber < 0) {
            notenumber += 12;
        }
        int notescale = notescale_from_number(notenumber);
        return [num objectAtIndex:notescale];
    }
    else {
        return @"";
    }
}


/** Get the letter (A, A#, Bb) representing this note */
-(NSString*)letterFromNumber:(int)notenumber andWhiteNote:(WhiteNote*)whitenote {
    int notescale = notescale_from_number(notenumber);
    switch(notescale) {
        case NoteScale_A: return @"A";
        case NoteScale_B: return @"B";
        case NoteScale_C: return @"C";
        case NoteScale_D: return @"D";
        case NoteScale_E: return @"E";
        case NoteScale_F: return @"F";
        case NoteScale_G: return @"G";
        case NoteScale_Asharp:
            if ([whitenote letter] == WhiteNote_A)
                return @"A#";
            else
                return @"Bb";
        case NoteScale_Csharp:
            if ([whitenote letter] == WhiteNote_C)
                return @"C#";
            else
                return @"Db";
        case NoteScale_Dsharp:
            if ([whitenote letter] == WhiteNote_D)
                return @"D#";
            else
                return @"Eb";
        case NoteScale_Fsharp:
            if ([whitenote letter] == WhiteNote_F)
                return @"F#";
            else
                return @"Gb";
        case NoteScale_Gsharp:
            if ([whitenote letter] == WhiteNote_G)
                return @"G#";
            else
                return @"Ab";
        default:
            return @"";
    }
}


/** Draw the Chord Symbol:
 * - Draw the accidental symbols.
 * - Draw the black circle notes.
 * - Draw the stems.
 * @param ytop The ylocation (in pixels) where the top of the staff starts.
 */
- (void)draw:(CGContextRef)context atY:(int)ytop {
    
    /* Align the chord to the right */
    CGContextTranslateCTM (context, (width - [self minWidth]), 0);
    
    /* Draw the accidentals */
    WhiteNote *topstaff = [WhiteNote top:clef];
    int xpos = [self drawAccid:context atY:ytop];
    int w = [self drawPayin:context atY:ytop topStaff:topstaff];
    xpos += w;
    
    /* Draw the notes */
    CGContextTranslateCTM (context, xpos, 0);
    
    if (yiFlag == 1) {
        [self drawGraceNotes:context atY:ytop topStaff:topstaff];
    } else {
        [self drawNotes:context atY:ytop topStaff:topstaff];
    }
    
    [self drawBoYin:context atY:ytop topStaff:topstaff];
    [self drawHuiYin:context atY:ytop topStaff:topstaff];
    [self drawChanYin:context atY:ytop topStaff:topstaff];
    
    SheetMusic *sheet = (SheetMusic*)sheetmusic;
    if (sheet != nil && [sheet showNoteLetters] != 0) {
        [self drawNoteLetters:context atY:ytop topStaff:topstaff];
    }

/** add by yizhq start */
    [self drawResult:context andYtop:ytop];
    [self drawConnectNote1:context andYtop:ytop andTopStaff:topstaff];
//    [self drawConnectNote2:context andYtop:ytop andTopStaff:topstaff];
//        drawArpeggio(canvas, paint, ytop, topstaff);
/** add by yizhq end */
    
    /** add by sunlie start */
    if (_conLineWidth != 0 && _conLineWidth != -1) {
        [self drawConLine:context andYtop:ytop andTopStaff:topstaff];
    }
    
    if (jumpedFlag > 0) {
        [self drawJumpedNote:context andYtop:ytop andTopStaff:topstaff];
    }
    
    if (eightWidth > 0 || eightFlag > 1 || eightFlag < -1) {
        [self drawEightNotes:context andYtop:ytop andTopStaff:topstaff];
    }
    if (volumeFlag != 0 && volumeWidth > 0) {
        //NSLog(@"volumeFlag %i", volumeFlag);
        if (volumeFlag > 0) {
            [self drawTriangle:context andLength:volumeWidth andDirect:0];
        }else if(volumeFlag < 0){
            [self drawTriangle:context andLength:volumeWidth andDirect:1];
        }
    }

    if (stressFlag == 1) {
            [self drawStress:context andYtop:ytop andTopStaff:topstaff];
    }
    
    if (strengthFlag != 0) {
        [self drawStrength:context withValue:(int)strengthFlag];
    }
    
    /** add by sunlie end */
    
    [self drawPedal:context];
    
    /* Draw the stems */
    if (stem1 != nil)
        [stem1 draw:context atY:ytop topStaff:topstaff threeFlag:threeNotes];
    if (stem2 != nil)
        [stem2 draw:context atY:ytop topStaff:topstaff threeFlag:threeNotes];

    CGContextTranslateCTM (context, -xpos, 0);
    
    CGContextTranslateCTM (context, -(width - [self minWidth]), 0);
}

/** add by yizhq start */

- (void) drawStress:(CGContextRef)context andYtop:(float)ytop andTopStaff:(WhiteNote *)topStaff {
    
    int ypos;
    int xpos;
    int ynote;
    int direct;
    
    xpos = LineSpace/2;

    Stem *stem = nil;
    if ([self hasTwoStems] == YES) {
        stem = [self stem];
        direct = [stem direction];
    } else {
        stem = [self stem1];
        direct = [stem direction];
    }

    if (direct == StemDown) {
        
        ynote = ytop + [topStaff dist:[stem top]] * NoteHeight/2 - NoteHeight-NoteHeight/3;
        CGContextMoveToPoint(context, xpos, ynote);
        CGContextSetLineWidth(context, 1.5);
        CGContextSetLineCap(context, kCGLineCapButt);
        CGContextMoveToPoint(context, xpos, ynote);
        CGContextAddLineToPoint(context, xpos + 6, ynote - 2.5);
        CGContextAddLineToPoint(context, xpos, ynote - 5);
        CGContextDrawPath(context, kCGPathStroke);
    }else if (direct == StemUp) {
        ynote = ytop + [topStaff dist:[stem bottom]] *  NoteHeight/2 + NoteHeight*2;
        CGContextMoveToPoint(context, xpos, ynote);
        CGContextSetLineWidth(context, 1.5);
        CGContextSetLineCap(context, kCGLineCapButt);
        CGContextMoveToPoint(context, xpos, ynote);
        CGContextAddLineToPoint(context, xpos + 6, ynote - 2.5);
        CGContextAddLineToPoint(context, xpos, ynote - 5);
        CGContextDrawPath(context, kCGPathStroke);
    }
}


/*!
 *  draw strength control data
 *
 *  @param context <#context description#>
 *  @param value   <#value description#>
 */
-(void)drawStrength:(CGContextRef)context withValue:(int)value{

    char *str;
    CGContextSelectFont(context, "Georgia-Italic", 12.0, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetTextMatrix(context, CGAffineTransformMake(1.0,0.0, 0.0, -1.0, 0.0, 0.0));
    switch (value) {
        case -3://pp
            str = "pp";
            break;
        case -2://p
            str = " p";
            break;
        case -1://mp
            str = "mp";
            break;
        case 1://mf
            str = "mf";
            break;
        case 2://f
            str = " f";
            break;
        case 3://ff
            str = "ff";
            break;
        case 4://sf
            str = "sf";
            break;
        default:
            return;
    }
    CGContextShowTextAtPoint(context, NoteWidth/2, belongStaffHeight-20, str, 2);
}
/*!
 *  draw gradient symbol
 *
 *  @param context comtext
 *  @param length  symbol's horizontal length
 *  @param direct  the direction of change 0:left 1:right
 */
-(void)drawTriangle:(CGContextRef)context andLength:(int)length andDirect:(int)direct
{
	CGContextSetLineWidth(context, 1.0);
	CGContextSetLineCap(context, kCGLineCapButt);
    int x = NoteWidth/2;
    int top = belongStaffHeight;// + [topstaff dist:[[self stem] top]] * [SheetMusic getNoteHeight]/2;
    if (direct == 0) {
        CGContextMoveToPoint(context, x, top);
        CGContextAddLineToPoint(context, x + length, top - 5);
        CGContextAddLineToPoint(context, x, top - 10);
    }else{
        CGContextMoveToPoint(context, x + length, top + 5);
        CGContextAddLineToPoint(context, x, top);
        CGContextAddLineToPoint(context, x + length, top - 5);
    }
    
	CGContextStrokePath(context);
}
/** add by yizhq end */

/** Draw the accidental symbols.  If two symbols overlap (if they
 * are less than 6 notes apart), we cannot draw the symbol directly
 * above the previous one.  Instead, we must shift it to the right.
 * @param ytop The ylocation (in pixels) where the top of the staff starts.
 * @return The x pixel width used by all the accidentals.
 */
-(int)drawAccid:(CGContextRef)context atY:(int)ytop {
    int xpos = 0;

    AccidSymbol *prev = nil;
    int i;
    for (i = 0; i < [accidsymbols count]; i++) {
        AccidSymbol *symbol = [accidsymbols get:i];
        if (prev != nil && [[symbol note] dist:[prev note]] < 6) {
            xpos += [symbol width];
        }

        CGContextTranslateCTM (context, xpos, 0);
        
        [symbol draw:context atY:ytop];
        
        CGContextTranslateCTM (context, -xpos, 0);
        
        prev = symbol;
    }
    if (prev != nil) {
        xpos += [prev width];
    }
    return xpos;
}

/** Draw the black circle notes.
 * @param ytop The ylocation (in pixels) where the top of the staff starts.
 * @param topstaff The white note of the top of the staff.
 */
- (void)drawNotes:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote *)topstaff {
    UIBezierPath *path;
    UIColor *color;
    int noteindex, i;

    for (noteindex = 0; noteindex < notedata_len; noteindex++) {
        NoteData *note = &notedata[noteindex];

        if (note->addflag == 1) {
            continue;
        }
        /* Get the x,y position to draw the note */
        int ynote = ytop + [topstaff dist:(note->whitenote)] * NoteHeight/2;

        int xnote = LineSpace/4;
        if (!note->leftside)
            xnote += NoteWidth;

        /* Draw rotated ellipse.  You must first translate (0,0)
         * to the center of the ellipse.
         */
        
        CGContextTranslateCTM (context, (xnote + NoteWidth/2 + 1), (ynote - LineWidth + NoteHeight/2));

        CGContextRotateCTM(context, -45.0);

        SheetMusic *sheet = (SheetMusic*)sheetmusic;
        if (sheet != nil) {
            color = [sheet noteColor:note->number];
        }
        else {
            color = [UIColor blackColor];
        }

        if (note->duration == Whole || 
            note->duration == Half ||
            note->duration == DottedHalf) {

            path = [UIBezierPath bezierPath];
            [path setLineWidth:1];
            
            [path appendPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(-NoteWidth/2, -NoteHeight/2, NoteWidth, NoteHeight-1)]];
            
            [path appendPath:[UIBezierPath bezierPathWithOvalInRect:
                CGRectMake(-NoteWidth/2, -NoteHeight/2, NoteWidth, NoteHeight-1)]];
            [path appendPath:[UIBezierPath bezierPathWithOvalInRect:
                CGRectMake(-NoteWidth/2, -NoteHeight/2 + 1, NoteWidth, NoteHeight-2)]];
            [path appendPath:[UIBezierPath bezierPathWithOvalInRect:
                CGRectMake(-NoteWidth/2, -NoteHeight/2 + 1, NoteWidth, NoteHeight-3)]];
            [color setStroke];
            [path stroke];
        }
        else {
            path = [UIBezierPath bezierPath];
            [path setLineWidth:LineWidth];
            [path appendPath:[UIBezierPath bezierPathWithOvalInRect:
                CGRectMake(-NoteWidth/2, -NoteHeight/2, NoteWidth, NoteHeight-1)]];
            [color setFill];
            [path fill];
        }

        path = [UIBezierPath bezierPath];
        [path setLineWidth:LineWidth];


        [path appendPath:[UIBezierPath bezierPathWithOvalInRect:
            CGRectMake(-NoteWidth/2, -NoteHeight/2, NoteWidth, NoteHeight-1)]];
        [path stroke];

        CGContextRotateCTM(context, 45.0);

        CGContextTranslateCTM (context, -(xnote + NoteWidth/2 + 1),
                               -(ynote - LineWidth + NoteHeight/2));
    
//?????
        /* Draw horizontal lines if note is above/below the staff */
        path = [UIBezierPath bezierPath];
        [path setLineWidth:LineWidth];

        /* Draw a dot if this is a dotted duration. */
        if (note->duration == DottedHalf ||
            note->duration == DottedQuarter ||
            note->duration == DottedEighth) {

            UIBezierPath *path = [UIBezierPath bezierPath];
            [path setLineWidth:LineWidth];
            [path appendPath:[UIBezierPath bezierPathWithOvalInRect:
                CGRectMake(xnote + NoteWidth + LineSpace/3, ynote + LineSpace/3, 4, 4) ]];
            [path fill];
        }

        /* Draw horizontal lines if note is above/below the staff */
        path = [UIBezierPath bezierPath];
        [path setLineWidth:LineWidth];
        //[[UIColor blackColor] setStroke];

        WhiteNote *top = [topstaff add:1];
        int dist = [note->whitenote dist:top];
        int y = ytop - LineWidth;

        if (dist >= 2) {
            for (i = 2; i <= dist; i += 2) {
                y -= NoteHeight;
                [path moveToPoint:CGPointMake(xnote - LineSpace/4, y)];
                [path addLineToPoint:CGPointMake(xnote + NoteWidth + LineSpace/4, y) ];
            }
        }

        WhiteNote *bottom = [top add:(-8)];
        y = ytop + (LineSpace + LineWidth) * 4 - 1;
        dist = [bottom dist:(note->whitenote)];
        if (dist >= 2) {
            for (i = 2; i <= dist; i+= 2) {
                y += NoteHeight;
                [path moveToPoint:CGPointMake(xnote - LineSpace/4, y) ];
                [path addLineToPoint:CGPointMake(xnote + NoteWidth + LineSpace/4, y) ];
            }
        }
        [path stroke];
        [top release];
        [bottom release];

        /* End drawing horizontal lines */
    }
}


/** Draw the note letters (A, A#, Bb, etc) next to the note circles.
 * @param ytop The ylocation (in pixels) where the top of the staff starts.
 * @param topstaff The white note of the top of the staff.
 */
- (void)drawNoteLetters:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote *)topstaff {
    int noteindex;

    BOOL overlap = [ChordSymbol notesOverlap:notedata withStart:0 andEnd:notedata_len];
    for (noteindex = 0; noteindex < notedata_len; noteindex++) {
        NoteData *note = &notedata[noteindex];
        if (!note->leftside) {
            /* There's not enought pixel room to show the letter */
            continue;
        }

        /* Get the x,y position to draw the note */
        int ynote = ytop + [topstaff dist:(note->whitenote)] * NoteHeight/2;

        /* Draw the letter to the right side of the note */ 
        int xnote = LineSpace/2 + NoteWidth;

        if (note->duration == DottedHalf ||
            note->duration == DottedQuarter ||
            note->duration == DottedEighth || overlap) {

            xnote += NoteWidth*2/3;
        }
        CGPoint point = CGPointMake(xnote, ynote - NoteHeight*2/3);
        NSString *letter = [self noteNameFromNumber:note->number 
                            andWhiteNote:note->whitenote];
        [letter drawAtPoint:point withAttributes:[SheetMusic fontAttributes]];
    }
}


/** Return true if the chords can be connected, where their stems are
 * joined by a horizontal beam. In order to create the beam:
 *
 * - The chords must be in the same measure.
 * - The chord stems should not be a dotted duration.
 * - The chord stems must be the same duration, with one exception
 *   (Dotted Eighth to Sixteenth).
 * - The stems must all point in the same direction (up or down).
 * - The chord cannot already be part of a beam.
 *
 * - 6-chord beams must be 8th notes in 3/4, 6/8, or 6/4 time
 * - 3-chord beams must be either triplets, or 8th notes (12/8 time signature)
 * - 4-chord beams are ok for 2/2, 2/4 or 4/4 time, any duration
 * - 4-chord beams are ok for other times if the duration is 16th
 * - 2-chord beams are ok for any duration
 *
 * If startQuarter is true, the first note should start on a quarter note
 * (only applies to 2-chord beams).
 */
+(BOOL)canCreateBeams:(Array*)chords withTime:(TimeSignature*)time onBeat:(BOOL)startQuarter {

    int numChords = [chords count];
    ChordSymbol *chord0 = [chords get:0];
    Stem* firstStem = [chord0 stem];
    Stem* lastStem = [[chords get:(numChords-1)] stem];
    BOOL notesixteenFlag = NO;
    int zsFlag=1;  //add by sunlie
    
    if (firstStem == nil || lastStem == nil) {
        return NO;
    }
    int measure = [[chords get:0] startTime] / [time measure];
    NoteDuration dur = [firstStem duration];
    NoteDuration dur2 = [lastStem duration];

    BOOL dotted8_to_16 = NO;
    if (numChords == 2 && dur == DottedEighth && dur2 == Sixteenth) {
        dotted8_to_16 = YES;
    } 

    if (dur == Whole || dur == Half || dur == DottedHalf || dur == Quarter ||
        dur == DottedQuarter ||
        (dur == DottedEighth && !dotted8_to_16)) {

        return NO;
    }
    
    /** add by sunlie start */
    zsFlag=1;
    for (int k=0; k < numChords; k++) {
        if ([[chords get:k] yiFlag] != 1) {
            zsFlag = 0;
            break;
        }
    }
    /** add by sunlie end */

    if (zsFlag == 0) {
        if (numChords == 6) {
            if (dur != Eighth) {
                return NO;
            }
            BOOL correctTime =
            (([time numerator] == 3 && [time denominator] == 4) ||
             ([time numerator] == 6 && [time denominator] == 8) ||
             ([time numerator] == 6 && [time denominator] == 4) );
            if (!correctTime) {
                return NO;
            }
            
            if ([time numerator] == 6 && [time denominator] == 4) {
                /* first chord must start at 1st or 4th quarter note */
                int beat = [time quarter] * 3;
                if (( [chord0 startTime] % beat) > [time quarter]/6) {
                    return NO;
                }
            }
        }
        else if (numChords == 4) {
            if ([time numerator] == 3 && [time denominator] == 8) {
                return NO;
            }
//            BOOL correctTime =
//            ([time numerator] == 2 || [time numerator] == 4 || [time numerator] == 8);
//            if (!correctTime && dur != Sixteenth) {
//                return NO;
//            }
            if (dur == Triplet) {
                return NO;
            }
            
            /* chord must start on quarter note */
            int beat = [time quarter];
            if (dur == Eighth) {
                /* 8th note chord must start on 1st or 3rd quarter note */
                beat = [time quarter] * 2;
            }
            else if (dur == ThirtySecond) {
                /* 32nd note must start on an 8th beat */
                beat = [time quarter] / 2;
            }
            
            if (([chord0 startTime] % beat) > [time quarter]/6) {
                return NO;
            }
        }
        else if (numChords == 3) {
            Stem* secondStem = [[chords get:1] stem];     /** add by sunlie */
            
            /** modify by sunlie */
            BOOL valid = (dur == Triplet) ||
            (dur == Eighth &&
             [time numerator] == 12 && [time denominator] == 8) ||
            ((dur == Eighth) && abs([chord0 startTime]/[time quarter]-[time quarter]/2)<[time quarter]/16) ||
            (dur == Sixteenth) ||
            ([firstStem duration] == Sixteenth && [secondStem duration] == Sixteenth && [lastStem duration] == Eighth) ||
            ([firstStem duration] == Eighth && [secondStem duration] == Sixteenth && [lastStem duration] == Sixteenth) ||
            ([firstStem duration] == Sixteenth && [secondStem duration] == Eighth && [lastStem duration] == Sixteenth);
            if (!valid) {
                return NO;
            }
            
            /** add by sunlie start */
            if (([firstStem duration] == Sixteenth && [secondStem duration] == Sixteenth && [lastStem duration] == Eighth) ||
                ([firstStem duration] == Eighth && [secondStem duration] == Sixteenth && [lastStem duration] == Sixteenth) ||
                ([firstStem duration] == Sixteenth && [secondStem duration] == Eighth && [lastStem duration] == Sixteenth)) {
                notesixteenFlag = YES;
            }
            /** add by sunlie end */
            
            /* chord must start on quarter note */
            int beat = [time quarter];
            if ([time numerator] == 12 && [time denominator] == 8) {
                /* In 12/8 time, chord must start on 3*8th beat */
                beat = [time quarter]/2 * 3;
            }
            if (([chord0 startTime] % beat) > [time quarter]/6) {
                return NO;
            }
        }
        else if (numChords == 2) {
            if (startQuarter) {
                int beat = [time quarter];
                if (([chord0 startTime] % beat) > [time quarter]/6) {
                    return NO;
                }
            }
        }
    }
    

    for (int i = 0; i < numChords; i++) {
        ChordSymbol *chord = [chords get:i];
        if (([chord startTime] / [time measure]) != measure) {
            return NO;
        }
        if ([chord stem] == nil) {
            return NO;
        }
//        if ([[chord stem] duration] != dur && !dotted8_to_16 && !notesixteenFlag) {
//            return NO;
//        }
        if ([[chord stem] isBeam]) {
            return NO;
        }
    }

    /** add by sunlie start */
    if (numChords == 3) {
        if (dur == Triplet) {
            [[chords get:1] setThreeNotes:1];
        }
    }
    /** add by sunlie end */
    
    /* Check that all stems can point in same direction */
    BOOL hasTwoStems = NO;
    int direction = StemUp; 
    for (int i = 0; i < numChords; i++) {
        ChordSymbol *chord = [chords get:i];
        if ([chord hasTwoStems]) {
            if (hasTwoStems && [[chord stem] direction] != direction) {
                return NO;
            }
            hasTwoStems = YES;
            direction = [[chord stem] direction];
        }
    }

    /* Get the final stem direction */
    if (!hasTwoStems) {
        WhiteNote *note1;
        WhiteNote *note2;
        note1 = ([firstStem direction] == StemUp ? [firstStem top] : [firstStem bottom]);
        note2 = ([lastStem direction] == StemUp ? [lastStem top] : [lastStem bottom]);
        direction = [ChordSymbol stemDirection:note1 withTop:note2 andClef: [chord0 clef]];
    }

    /* If the notes are too far apart, don't use a beam */
    if (direction == StemUp) {
        if (abs([[firstStem top] dist:[lastStem top]]) >= 11) {
            return NO;
        }
    }
    else {
        if (abs([[firstStem bottom] dist:[lastStem bottom]]) >= 11) {
            return NO;
        }
    }
    return YES;
}


/** Connect the chords using a horizontal beam. 
 *
 * spacing is the horizontal distance (in pixels) between the right side 
 * of the first chord, and the right side of the last chord.
 *
 * To make the beam:
 * - Change the stem directions for each chord, so they match.
 * - In the first chord, pass the stem location of the last chord, and
 *   the horizontal spacing to that last stem.
 * - Mark all chords (except the first) as "receiver" pairs, so that 
 *   they don't draw a curvy stem.
 */
+(void)createBeam:(Array*)chords withSpacing:(int)spacing {
    Stem* firstStem = [[chords get:0] stem];
    Stem* lastStem = [[chords get:([chords count]-1)] stem];

    /* Calculate the new stem direction */
    int newdirection = -1;
    for (int i = 0; i < [chords count]; i++) {
        ChordSymbol *chord = [chords get:i];
        if ([chord hasTwoStems]) {
            newdirection = [[chord stem] direction];
            break;
        }
    }

    if (newdirection == -1) {
        WhiteNote *note1;
        WhiteNote *note2;
        note1 = ([firstStem direction] == StemUp ? [firstStem top] : [firstStem bottom]);
        note2 = ([lastStem direction] == StemUp ? [lastStem top] : [lastStem bottom]);
        newdirection = [ChordSymbol stemDirection:note1 withTop:note2 andClef:[[chords get:0] clef]];
    }
    for (int i = 0; i < [chords count]; i++) {
        ChordSymbol *chord = [chords get:i];
        [[chord stem] setDirection:newdirection];
    }

    if ([chords count] == 2) {
        [ChordSymbol bringStemsCloser:chords];
    }
    else {
        [ChordSymbol lineUpStemEnds:chords];
    }

//    [firstStem setPair:lastStem withWidth:spacing];    /** modify by sunlie */
    /** add by sunlie start */
    if ([chords count] == 3) {
        ChordSymbol *c = [chords get:1];
        Stem* secondStem = [c stem];
        if ([firstStem duration] == Sixteenth && [secondStem duration] == Sixteenth && [lastStem duration] == Eighth) {
            [firstStem setPairex:lastStem withWidth:spacing];
            if ([[c accidsymbols] count] > 0) {
                AccidSymbol *accid = [[c accidsymbols] get:0];
                [firstStem setPair:secondStem withWidth:spacing/2 + [accid width]/2];
            } else {
                [firstStem setPair:secondStem withWidth:spacing/2];
            }
        }
        else if ([firstStem duration] == Eighth && [secondStem duration] == Sixteenth && [lastStem duration] == Sixteenth) {
            [firstStem setPair:lastStem withWidth:spacing];
            [secondStem setPair:lastStem withWidth:spacing/2];
        }
        else if ([firstStem duration] == Sixteenth && [secondStem duration] == Eighth && [lastStem duration] == Sixteenth) {
            [firstStem setCutNote:1];
            [firstStem setPair:lastStem withWidth:spacing];
        }
        else {
            [firstStem setPair:lastStem withWidth:spacing];
        }
    }
    else {
        [firstStem setPair:lastStem withWidth:spacing];
    }
    /** add by sunlie end */
    for (int i = 1; i < [chords count]; i++) {
        ChordSymbol *chord = [chords get:i];
        [[chord stem] setReceiver: YES];
    }
}


/** We're connecting the stems of two chords using a horizontal beam.
 *  Adjust the vertical endpoint of the stems, so that they're closer
 *  together.  For a dotted 8th to 16th beam, increase the stem of the
 *  dotted eighth, so that it's as long as a 16th stem.
 */
+(void)bringStemsCloser:(Array*)chords {
    Stem* firstStem = [[chords get:0] stem];
    Stem* lastStem = [[chords get:1] stem];
    WhiteNote *newend = nil;

    /* If we're connecting a dotted 8th to a 16th, increase
     * the stem end of the dotted eighth.
     */
    if ([firstStem duration] == DottedEighth &&
        [lastStem duration] == Sixteenth) {
        if ([firstStem direction] == StemUp) {
            newend = [[firstStem end] add:2];
            [firstStem setEnd:newend];
            [newend release];
        }
        else {
            newend = [[firstStem end] add:-2];
            [firstStem setEnd:newend];
            [newend release];
        }
    }

    /* Bring the stem ends closer together */
    int distance = abs([[firstStem end] dist: [lastStem end]]);
    if ([firstStem direction] == StemUp) {
        if ([WhiteNote max:[firstStem end] and:[lastStem end]] == [firstStem end]) {
            newend = [[lastStem end] add:(distance/2)]; 
            [lastStem setEnd:newend];
            [newend release];
        }
        else {
            newend = [[firstStem end] add:(distance/2)];
            [firstStem setEnd:newend];
            [newend release];
        }
    }
    else {
        if ([WhiteNote min:[firstStem end] and:[lastStem end]] == [firstStem end]) {
            newend = [[lastStem end] add:(-distance/2)];
            [lastStem setEnd:newend];
            [newend release];
        }
        else {
            newend = [[firstStem end] add:(-distance/2)];
            [firstStem setEnd:newend];
            [newend release];
        }
    }
}

/** We're connecting the stems of three or more chords using a horizontal beam.
 *  Adjust the vertical endpoint of the stems, so that the middle chord stems
 *  are vertically in between the first and last stem.
 */
+(void)lineUpStemEnds:(Array*)chords {
    Stem* firstStem = [[chords get:0] stem];
    Stem* lastStem = [[chords get:([chords count]-1)] stem];
    Stem* middleStem = [[chords get:1] stem];
    WhiteNote *newend = nil;

    if ([firstStem direction] == StemUp) {
        /* Find the highest stem. The beam will either:
         * - Slant downwards (first stem is highest)
         * - Slant upwards (last stem is highest)
         * - Be straight (middle stem is highest)
         */
        WhiteNote* top = [firstStem end];
        for (int i = 0; i < [chords count]; i++) {
            ChordSymbol *chord = [chords get:i];
            top = [WhiteNote max:top and:[[chord stem] end]];
        }
        if (top == [firstStem end] && [top dist:[lastStem end]] >= 2) {
            [firstStem setEnd:top];
            newend = [top add:-1];
            [middleStem setEnd:newend];
            [newend release];
            newend = [top add:-2];
            [lastStem setEnd:newend];
            [newend release];
        }
        else if (top == [lastStem end] && [top dist:[firstStem end]] >= 2) {
            newend = [top add:-2];
            [firstStem setEnd:newend];
            [newend release];
            newend = [top add:-1];
            [middleStem setEnd:newend];
            [newend release];
            [lastStem setEnd:top];
        }
        else {
            [firstStem setEnd:top];
            [middleStem setEnd:top];
            [lastStem setEnd:top];
        }
    }
    else {
        /* Find the bottommost stem. The beam will either:
         * - Slant upwards (first stem is lowest)
         * - Slant downwards (last stem is lowest)
         * - Be straight (middle stem is highest)
         */
        WhiteNote* bottom = [firstStem end];
        for (int i = 0; i < [chords count]; i++) {
            ChordSymbol *chord = [chords get:i];
            bottom = [WhiteNote min:bottom and:[[chord stem] end]];
        }

        if (bottom == [firstStem end] && [[lastStem end] dist:bottom] >= 2) {
            [firstStem setEnd:bottom];
            newend = [bottom add:1];
            [middleStem setEnd:newend];
            [newend release];
            newend = [bottom add:2];
            [lastStem setEnd:newend];
            [newend release];
        }
        else if (bottom == [lastStem end] && [[firstStem end] dist:bottom] >= 2) {
            newend = [bottom add:2];
            [firstStem setEnd:newend];
            [newend release];
            newend = [bottom add:1];
            [middleStem setEnd:newend];
            [newend release];
            [lastStem setEnd:bottom];
        }
        else {
            [firstStem setEnd:bottom];
            [middleStem setEnd:bottom];
            [lastStem setEnd:bottom];
        }
    }

    /* All middle stems have the same end */
    for (int i = 1; i < [chords count]-1; i++) {
        Stem *stem = [[chords get:i] stem];
        [stem setEnd: [middleStem end]];
    }
}

-(NSString*)description {
    NSString *clefs[] = { @"Treble", @"Bass" };
    NSString *s = [NSString stringWithFormat:
                    @"ChordSymbol clef=%@ start=%d end=%d width=%d hastwostems=%d ",
                    clefs[clef], starttime, endtime, width, hastwostems];
    for (int i = 0; i < [accidsymbols count]; i++) {
        AccidSymbol *symbol = [accidsymbols get:i];
        s = [s stringByAppendingString:[symbol description]];
        s = [s stringByAppendingString:@" "];
    }
    for (int i = 0; i < notedata_len; i++) {
        NSString *notestr = [NSString stringWithFormat:
                              @"Note whitenote=%@ duration=%@ leftside=%d ",
                              [notedata[i].whitenote description],
                              [TimeSignature durationString:notedata[i].duration ],
                              notedata[i].leftside];
        s = [s stringByAppendingString:notestr];
    }
    if (stem1 != nil) {
        s = [s stringByAppendingString:[stem1 description]];
        s = [s stringByAppendingString:@" "];
    }
    if (stem2 != nil) {
        s = [s stringByAppendingString:[stem2 description]];
        s = [s stringByAppendingString:@" "];
    }
    return s;
}

- (void)dealloc {
    for (int i = 0; i < notedata_len; i++) {
        [notedata[i].whitenote release];
    }
    notedata_len = 0;
    free(notedata); notedata = NULL;
    [accidsymbols release];  accidsymbols = nil;
    [stem1 release]; stem1 = nil;
    [stem2 release]; stem2 = nil;
    [super dealloc];
}

/**  add by yizhq start */
- (void) drawResult:(CGContextRef)context andYtop:(float)ytop
{
    if (judgedResult == 0 || judgedResult == -2)
		return;

    UIImage *image = nil;
    switch(judgedResult){
        case -1:
//            [[UIColor redColor] setFill];
            image = wrong;
            break;
        case 1:
//            [[UIColor yellowColor] setFill];
            image = right;
            break;
        case 2:
//            [[UIColor greenColor] setFill];
            image = perfect;
            break;
    }

	int ypos = [SheetMusic getNoteHeight];
    
    CGContextTranslateCTM (context, 0 , ypos-10);

    CGRect imageRect = CGRectMake(0, 0, [image size].width, [image size].height);
    [image drawInRect:imageRect];
    // 	CGContextFillEllipseInRect(context, CGRectMake(0, 0, [SheetMusic getNoteWidth], [SheetMusic getNoteWidth]));
    CGContextTranslateCTM (context, 0 , -(ypos-10));
    

}

- (void) drawConnectNote1:(CGContextRef)context andYtop:(float)ytop andTopStaff:(WhiteNote *)topStaff
{
   	if (_connectNoteWidth == -1)
        return;
    
    
    int leftDirect, rightDirect, direct, ynote;
    Stem *stem = nil;
    if ([self hasTwoStems] == YES) {
        stem = [self stem];
        leftDirect = [stem direction];
    } else {
        stem = [self stem1];
        leftDirect = [stem direction];
    }
    
    if ([_connectChordSymbol hasTwoStems] == YES) {
        rightDirect = [[_connectChordSymbol stem] direction];
    } else {
        rightDirect = [[_connectChordSymbol stem1] direction];
    }
    
    if (leftDirect == rightDirect) {
        direct = leftDirect;
    } else {
        direct = leftDirect;
    }
    
//    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    if (direct == StemDown) {

        ynote = ytop + [topStaff dist:[stem top]] * [SheetMusic getNoteHeight]/2;
        float radius = sqrt(_connectNoteWidth*_connectNoteWidth/2);
        float x = _connectNoteWidth/2 + 0 + [SheetMusic getNoteWidth]/2;
        float y = ynote - 20 + radius;
        //NSLog(@"drawConnectNote1 - StemDown - x is %f y is %f radius is %f",x,y,radius);
        CGContextBeginPath(context);
        CGContextAddArc(context, x, y, radius, -45*PI/180, -135*PI/180, 1);
        CGContextStrokePath(context);

    } else if (direct == StemUp) {

        ynote = ytop + [topStaff dist:[stem top]] * [SheetMusic getNoteHeight]/2;
        float radius = sqrt(_connectNoteWidth*_connectNoteWidth/2);
        float x = _connectNoteWidth/2 + 0 + [SheetMusic getNoteWidth]/2;
        float y = ynote - sqrt(radius*radius/2) + 10;
        //NSLog(@"drawConnectNote1 - StemUp - x is %f y is %f radius is %f width %i",x,y,radius,_connectNoteWidth);
        CGContextBeginPath(context);
        CGContextAddArc(context, x, y, radius, 45* PI/180, 135*PI/180, 0);
        CGContextStrokePath(context);
    }
    
 //  CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
}

- (void) drawConnectNote2:(CGContextRef)context andYtop:(float)ytop andTopStaff:(WhiteNote *)topStaff
{
    if (_connectNoteWidth2 == -1)
        return;
    
    
    int leftDirect, ynote;
    Stem *stem = nil;
    if ([self hasTwoStems] == YES) {
        stem = [self stem];
        leftDirect = [stem direction];
    } else {
        stem = [self stem1];
        leftDirect = [stem direction];
    }
    
//    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    
    if (leftDirect == StemDown) {
        
//        ynote = ytop + [topStaff dist:_connectNote2->whitenote] * [SheetMusic getNoteHeight]/2;
        ynote = ytop + [topStaff dist:[stem top]] * [SheetMusic getNoteHeight]/2;
        float radius = sqrt(_connectNoteWidth2*_connectNoteWidth2/2);
        float x = _connectNoteWidth2/2 + 0 + [SheetMusic getNoteWidth]/2;
        float y = ynote-10 + radius;
//        NSLog(@"drawConnectNote2 - StemDown - x is %f y is %f radius is %f",x,y,radius);
        CGContextBeginPath(context);
        CGContextAddArc(context, x, y, radius, 15*PI/180, 165*PI/180, 0);
        CGContextStrokePath(context);
    } else if (leftDirect == StemUp) {
//        ynote = ytop + [topStaff dist:_connectNote2->whitenote] * [SheetMusic getNoteHeight]/2;
        ynote = ytop + [topStaff dist:[stem top]] * [SheetMusic getNoteHeight]/2;
        float radius = sqrt(_connectNoteWidth2*_connectNoteWidth2/2);
        float x = _connectNoteWidth2/2 + - 0 + [SheetMusic getNoteWidth]/2;
        float y = ynote - 10 + radius;
//        NSLog(@"drawConnectNote2 - StemUp - x is %f y is %f radius is %f",x,y,radius);
        CGContextBeginPath(context);
        CGContextAddArc(context, x, y, radius, -15*PI/180, -165*PI/180, 1);
        CGContextStrokePath(context);
    }
//    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
}

-(void)setStaffNo:(NSString *)staffNo
{
    [_staffNo release];
    _staffNo = [staffNo retain];
}

-(NSString *)getStaffNo
{
	return _staffNo;
}

-(NoteData *)getNotedata
{
	return notedata;
}

-(int)getNotedataLength
{
    return notedata_len;
}

-(void)setConnectNoteWidth:(ChordSymbol*) chordSymbol withNoteData:(NoteData*)note andNoteWidth:(int)connectNoteWidth
{
	_connectChordSymbol = chordSymbol;
	_connectNote = note;
	_connectNoteWidth = connectNoteWidth;
}

-(void)setConnectNoteWidth2:(NoteData*)note andNoteWidth:(int)connectNoteWidth
{
	_connectNote2 = note;
	_connectNoteWidth2 = connectNoteWidth;
}
/**  add by yizhq end */
/**  add by sunlie start */
- (void) drawConLine:(CGContextRef)context andYtop:(float)ytop andTopStaff:(WhiteNote *)topStaff
{
   	if (_conLineWidth == -1)
        return;
    
    
    int leftDirect, rightDirect, direct, ynote, ynote1 = 0;
//    UIColor *color = [UIColor blackColor];
//    [color set];
    UIBezierPath* aPath = [UIBezierPath bezierPath];
    aPath.lineWidth = 1;
    aPath.lineCapStyle = kCGLineCapRound;
    aPath.lineJoinStyle = kCGLineCapRound;
    
    Stem *stem = nil;
    if ([self hasTwoStems] == YES) {
        stem = [self stem];
        leftDirect = [stem direction];
    } else {
        stem = [self stem1];
        leftDirect = [stem direction];
    }
    
    if ([_conLineChord hasTwoStems] == YES) {
        rightDirect = [[_conLineChord stem] direction];
    } else {
        rightDirect = [[_conLineChord stem1] direction];
    }
    
    if (leftDirect == rightDirect) {
        direct = leftDirect;
    } else {
        direct = leftDirect;
    }
    
    if (_conLineWidth > 0 && conLine > 0) {
        
        WhiteNote *topstaff = [WhiteNote top: [_conLineChord clef]];
        if (direct == StemDown) {
            
            ynote = ytop + [topStaff dist:[stem top]] * [SheetMusic getNoteHeight]/2;

            if (rightDirect == StemDown) {
                ynote1 = ytop + [topstaff dist:[[_conLineChord stem] top]] * NoteHeight/2;
                
            } else if (rightDirect == StemUp) {
                ynote1 = ytop + [topstaff dist:[[_conLineChord stem] end]] * NoteHeight/2 ;
            }
            
            [aPath moveToPoint:CGPointMake(NoteWidth/2, ynote-8)];
            [aPath addQuadCurveToPoint:CGPointMake(_conLineWidth+NoteWidth/2, ynote1) controlPoint:CGPointMake((NoteWidth/2+_conLineWidth+NoteWidth/2)/2, ynote-40)];
            [aPath stroke];
            
        } else if (direct == StemUp) {
            
            ynote = ytop + [topStaff dist:[stem top]] * [SheetMusic getNoteHeight]/2;
            
            if (rightDirect == StemDown) {
                ynote1 = ytop + [topstaff dist:[[_conLineChord stem] end]] * NoteHeight/2 ;
                
            } else if (rightDirect == StemUp) {
                ynote1 = ytop + [topstaff dist:[[_conLineChord stem] top]] * NoteHeight/2 ;
            }
            
            [aPath moveToPoint:CGPointMake(NoteWidth/2, ynote+5)];
            [aPath addQuadCurveToPoint:CGPointMake(_conLineWidth+NoteWidth/2, ynote1+5) controlPoint:CGPointMake((NoteWidth/2+_conLineWidth+NoteWidth/2)/2, ynote+40)];
            [aPath stroke];
        }
    } else if (_conLineWidth > 0 && conLine < 0) {
        if (direct == StemDown) {
            
            ynote = ytop + [topStaff dist:[stem top]] * [SheetMusic getNoteHeight]/2;
            [aPath moveToPoint:CGPointMake(NoteWidth/2, ynote-5)];
            [aPath addQuadCurveToPoint:CGPointMake(_conLineWidth+NoteWidth/2, ynote-35) controlPoint:CGPointMake((NoteWidth/2+_conLineWidth+NoteWidth/2)/2, ynote-35)];
//            [aPath addQuadCurveToPoint:CGPointMake(_conLineWidth+NoteWidth/2, ynote-5) controlPoint:CGPointMake((NoteWidth/2+_conLineWidth+NoteWidth/2)/2, ynote-45)];
            [aPath stroke];
            
        } else if (direct == StemUp) {
            
            ynote = ytop + [topStaff dist:[stem top]] * [SheetMusic getNoteHeight]/2;
            [aPath moveToPoint:CGPointMake(NoteWidth/2, ynote+5)];
            [aPath addQuadCurveToPoint:CGPointMake(_conLineWidth+NoteWidth/2, ynote+35) controlPoint:CGPointMake((NoteWidth/2+_conLineWidth+NoteWidth/2)/2, ynote+35)];
//            [aPath addQuadCurveToPoint:CGPointMake(_conLineWidth+NoteWidth/2, ynote+5) controlPoint:CGPointMake((NoteWidth/2+_conLineWidth+NoteWidth/2)/2, ynote+45)];
            [aPath stroke];
        }
    } else if (_conLineWidth < -1) {
        if (direct == StemDown) {
            
            ynote = ytop + [topStaff dist:[stem top]] * [SheetMusic getNoteHeight]/2;
            [aPath moveToPoint:CGPointMake(NoteWidth/2, ynote-5)];
            [aPath addQuadCurveToPoint:CGPointMake(_conLineWidth-NoteWidth/2, ynote-35) controlPoint:CGPointMake(_conLineWidth/2, ynote-40)];
//            [aPath addQuadCurveToPoint:CGPointMake(_conLineWidth-NoteWidth/2, ynote-5) controlPoint:CGPointMake(_conLineWidth/2, ynote-45)];
            [aPath stroke];
            
        } else if (direct == StemUp) {
            
            ynote = ytop + [topStaff dist:[stem top]] * [SheetMusic getNoteHeight]/2;
            [aPath moveToPoint:CGPointMake(NoteWidth/2, ynote+5)];
            [aPath addQuadCurveToPoint:CGPointMake(_conLineWidth+NoteWidth/2, ynote+35) controlPoint:CGPointMake(_conLineWidth/2, ynote+40)];
//            [aPath addQuadCurveToPoint:CGPointMake(_conLineWidth+NoteWidth/2, ynote+5) controlPoint:CGPointMake(_conLineWidth/2, ynote+45)];
            [aPath stroke];
        }
    }
    
    
//    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
}

- (void) drawJumpedNote:(CGContextRef)context andYtop:(float)ytop andTopStaff:(WhiteNote *)topStaff {
    
    int leftDirect;
    int ypos;
    Stem *stem = nil;
    if ([self hasTwoStems] == YES) {
        stem = [self stem];
        leftDirect = [stem direction];
    } else {
        stem = [self stem1];
        leftDirect = [stem direction];
    }
    
    if (leftDirect == StemDown) {
        ypos = ytop + [topStaff dist:[stem top]] * NoteHeight/2 - NoteHeight - 5;
    } else if (leftDirect == StemUp) {
        ypos = ytop + [topStaff dist:[stem bottom]] * NoteHeight/2+NoteHeight/3;
    }
    
    if (jumpedFlag == 1) {
        CGContextTranslateCTM (context, 0 , ypos);
        CGContextFillEllipseInRect(context, CGRectMake(LineSpace/2, LineSpace, [SheetMusic getNoteWidth]/2, [SheetMusic getNoteWidth]/2));
        CGContextTranslateCTM (context, 0 , -ypos);
    } else if (jumpedFlag == 2) {
        CGContextMoveToPoint(context, LineSpace/2, 2*LineSpace);
        CGContextAddLineToPoint(context, 1.5*LineSpace, 2*LineSpace);
        CGContextAddLineToPoint(context, LineSpace, 3*LineSpace);
        CGContextAddLineToPoint(context, LineSpace/2, 2*LineSpace);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
}

- (void) drawEightNotes:(CGContextRef)context andYtop:(float)ytop andTopStaff:(WhiteNote *)topStaff {
    
    int leftDirect;
    int ypos;
    Stem *stem = nil;
    if ([self hasTwoStems] == YES) {
        stem = [self stem];
        leftDirect = [stem direction];
    } else {
        stem = [self stem1];
        leftDirect = [stem direction];
    }
    
    ypos = ytop + [topStaff dist:[stem top]] * [SheetMusic getNoteHeight]*2/3;
    
    if (eightWidth != 0) {
        int w = fabs(eightWidth) - 25;
        
        if (eightFlag > 1) { //up

            [self draw8va:context:CGRectMake(-15, 0, 25, -10)];

            [self drawDottedLine:context andStart:CGPointMake(10, 10) andEnd:CGPointMake(10 + w, 10)];
            
            [self drawVerticalLine:CGPointMake(10 + w, 10) andEnd:CGPointMake(10 + w, 20)];
            

        } else if (eightFlag < -1) {//down
            
            [self draw8va:context:CGRectMake(-15, belongStaffHeight-30, 25, belongStaffHeight-20)];
            
            [self drawDottedLine:context andStart:CGPointMake(10, belongStaffHeight-20) andEnd:CGPointMake(10 + w, belongStaffHeight-20)];
            
            [self drawVerticalLine:CGPointMake(10 + w, belongStaffHeight-30) andEnd:CGPointMake(10 + w, belongStaffHeight-20)];
            
        } else if (eightFlag == 1) {
            
            [self drawDottedLine:context andStart:CGPointMake(10, 10) andEnd:CGPointMake(10 + w, 10)];
            
            if (eightWidth>0) {
                [self drawVerticalLine:CGPointMake(10 + w, 10) andEnd:CGPointMake(10 + w, 20)];
            }
            
        } else if (eightFlag == -1) {
            
            [self drawDottedLine:context andStart:CGPointMake(10, belongStaffHeight-20) andEnd:CGPointMake(10 + w, belongStaffHeight-20)];
            
            if (eightWidth>0) {
                [self drawVerticalLine:CGPointMake(10 + w, belongStaffHeight-30) andEnd:CGPointMake(10 + w, belongStaffHeight-20)];
            }
            
        }
    } else {
        int w = width;
        
        if (eightFlag == 200) {
            [self draw8va:context:CGRectMake(-15, 0, 25, -10)];
            
            [self drawDottedLine:context andStart:CGPointMake(10, 10) andEnd:CGPointMake(10 + w, 10)];
            
            [self drawVerticalLine:CGPointMake(10 + w, 10) andEnd:CGPointMake(10 + w, 20)];
            
        } else if (eightFlag == -200) {
            [self draw8va:context:CGRectMake(-15, belongStaffHeight-30, 25, belongStaffHeight-20)];
            
            [self drawDottedLine:context andStart:CGPointMake(10, belongStaffHeight-20) andEnd:CGPointMake(10 + w, belongStaffHeight-20)];
            
            [self drawVerticalLine:CGPointMake(10 + w, belongStaffHeight-30) andEnd:CGPointMake(10 + w, belongStaffHeight-20)];
            
        } else if (eightFlag == 1) {
            [self drawDottedLine:context andStart:CGPointMake(10, 10) andEnd:CGPointMake(10 + w, 10)];
            [self drawVerticalLine:CGPointMake(10 + w, 10) andEnd:CGPointMake(10 + w, 20)];
            
            if (eightWidth>0) {
                [self drawVerticalLine:CGPointMake(10 + w, 10) andEnd:CGPointMake(10 + w, 20)];
            }
        } else if (eightFlag == -1) {
            [self drawDottedLine:context andStart:CGPointMake(10, belongStaffHeight-20) andEnd:CGPointMake(10 + w, belongStaffHeight-20)];
            [self drawVerticalLine:CGPointMake(10 + w, belongStaffHeight-30) andEnd:CGPointMake(10 + w, belongStaffHeight-20)];
            
            if (eightWidth>0) {
                [self drawVerticalLine:CGPointMake(10 + w, belongStaffHeight-30) andEnd:CGPointMake(10 + w, belongStaffHeight-20)];
            }
        }
    }
}



-(void)draw8va:(CGContextRef)context :(CGRect)rect
{
    CGContextSelectFont(context, "Georgia-Italic", 12.0, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetTextMatrix(context, CGAffineTransformMake(1.0,0.0, 0.0, -1.0, 0.0, 0.0));
    CGContextShowTextAtPoint(context, rect.origin.x, rect.origin.y + 10, "8va", 3);
}

-(void)drawVerticalLine:(CGPoint)start andEnd:(CGPoint)end
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:start];
    [path addLineToPoint:end];
    [path setLineWidth:1];
    [path stroke];
}

-(void)drawDottedLine:(CGContextRef)context andStart:(CGPoint)start andEnd:(CGPoint)end
{
    CGContextSaveGState(context);
    

    CGFloat lengths[] = {10.0,10.0};
    CGContextSetLineDash(context, 0, lengths,2);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:start];
    [path addLineToPoint:end];
    [path setLineWidth:1];
    [path stroke];
    
    CGContextRestoreGState(context);
}

/**  add by sunlie end */

-(void)drawPedal:(CGContextRef)context {

    if (pedalFlag == 0) return;
    
    int x = 0;
    UIImage *image = nil;
    switch (pedalFlag) {
        case 1:
            image = pedal1;
            break;
        case 2:
            image = pedal2;
            x = [self minWidth];
            break;
        default:
            break;
    }

	int ypos = belongStaffHeight;
    CGContextTranslateCTM (context, x , ypos-10);
    CGRect imageRect = CGRectMake(0, 0, [image size].width, [image size].height);
    [image drawInRect:imageRect];
    CGContextTranslateCTM (context, -x , -(ypos-10));
}

-(int)drawPayin:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote *)topstaff {
    
    if (paFlag == 0) return 0;

    int direct, ypos;
    Stem *stem = nil;
    if ([self hasTwoStems] == YES) {
        stem = [self stem];
        direct = [stem direction];
    } else {
        stem = [self stem1];
        direct = [stem direction];
    }
    
    if (direct == StemUp ) {
        ypos = ytop + [topstaff dist:[stem end]] * NoteHeight/2;
    } else {
        ypos = ytop + [topstaff dist:[stem top]] * NoteHeight/2;
    }
    
    CGContextTranslateCTM (context, 0 , ypos);
    CGRect imageRect = CGRectMake(0, 0, [payin size].width, [payin size].height);
    [payin drawInRect:imageRect];
    CGContextTranslateCTM (context, 0 , -(ypos));
    
    return [payin size].width;
}



-(void)drawBoYin:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote *)topstaff {
    if (boFlag == 0) return;
    
    UIImage *image = nil;
    switch (boFlag) {
        case 1:
            image = shunboyin;
            break;
        case 2:
            image = niboyin;
            break;
        default:
            break;
    }
    
    int direct, ypos, ypos2;
    Stem *stem = nil;
    if ([self hasTwoStems] == YES) {
        stem = [self stem];
        direct = [stem direction];
    } else {
        stem = [self stem1];
        direct = [stem direction];
    }
    
    
    if (direct == StemUp ) {
        ypos2 = ytop + [topstaff dist:[stem end]] * NoteHeight/2;
    } else {
        ypos2 = ytop + [topstaff dist:[stem top]] * NoteHeight/2;
    }
    
    if (ypos2 <= ytop) {
        ypos = ypos2 - [image size].height - 5;
    } else {
        ypos = ytop - [image size].height - 5;
    }
    
    CGContextTranslateCTM (context, 0 , ypos);
    CGRect imageRect = CGRectMake(0, 0, [image size].width, [image size].height);
    [image drawInRect:imageRect];
    CGContextTranslateCTM (context, 0 , -ypos);
}


-(void)drawHuiYin:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote *)topstaff {
    
    if (huiFlag == 0) return;
    
    UIImage *image = nil;
    switch (huiFlag) {
        case 1:
            image = shunhuiyin;
            break;
        case 2:
            image = nihuiyin;
            break;
        default:
            break;
    }
    
    int direct, ypos, ypos2;
    Stem *stem = nil;
    if ([self hasTwoStems] == YES) {
        stem = [self stem];
        direct = [stem direction];
    } else {
        stem = [self stem1];
        direct = [stem direction];
    }
    
    
    if (direct == StemUp ) {
        ypos2 = ytop + [topstaff dist:[stem end]] * NoteHeight/2;
    } else {
        ypos2 = ytop + [topstaff dist:[stem top]] * NoteHeight/2;
    }
    
    if (ypos2 <= ytop) {
        ypos = ypos2 - [image size].height - 5;
    } else {
        ypos = ytop - [image size].height - 5;
    }
    
    CGContextTranslateCTM (context, 0 , ypos);
    CGRect imageRect = CGRectMake(0, 0, [image size].width, [image size].height);
    [image drawInRect:imageRect];
    CGContextTranslateCTM (context, 0 , -ypos);
}


-(void)drawChanYin:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote *)topstaff {
    
    if (trFlag == 0) return;

    int direct, ypos, ypos2;
    Stem *stem = nil;
    if ([self hasTwoStems] == YES) {
        stem = [self stem];
        direct = [stem direction];
    } else {
        stem = [self stem1];
        direct = [stem direction];
    }
    
    if (direct == StemUp ) {
        ypos2 = ytop + [topstaff dist:[stem end]] * NoteHeight/2;
    } else {
        ypos2 = ytop + [topstaff dist:[stem top]] * NoteHeight/2;
    }
    
    if (ypos2 <= ytop) {
        ypos = ypos2 - [chanyin size].height - 5;
    } else {
        ypos = ytop - [chanyin size].height - 5;
    }
    

    CGContextTranslateCTM (context, 0 , ypos);
    CGRect imageRect = CGRectMake(0, 0, [chanyin size].width, [chanyin size].height);
    [chanyin drawInRect:imageRect];
    CGContextTranslateCTM (context, 0 , -ypos);
    
}


- (void)drawGraceNotes:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote *)topstaff {

    int noteindex;
    int noteWidth = NoteWidth*NUMERATOR+1;
    int noteHeight = NoteHeight*NUMERATOR;
    
    for (noteindex = 0; noteindex < notedata_len; noteindex++) {
        NoteData *note = &notedata[noteindex];
        
        if (note->addflag == 1) {
            continue;
        }
        /* Get the x,y position to draw the note */
        int ynote = ytop + [topstaff dist:(note->whitenote)] * noteHeight/2;
       
        int xnote = LineSpace/4;
        if (!note->leftside)
            xnote += noteWidth;
        
    
        /* Draw rotated ellipse.  You must first translate (0,0)
         * to the center of the ellipse.
         */
        CGContextTranslateCTM (context, (xnote + noteWidth/2 + 1), (ynote - LineWidth + noteHeight/2));
        CGContextRotateCTM(context, -45.0);
        
        UIColor *color = [UIColor blackColor];
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path setLineWidth:LineWidth];
        [color setFill];
        [path appendPath:[UIBezierPath bezierPathWithOvalInRect:
                          CGRectMake(-noteWidth/2, -noteHeight/2, noteWidth, noteHeight-1)]];
        [path fill];
        
        
        path = [UIBezierPath bezierPath];
        [path setLineWidth:LineWidth];
        [[UIColor blackColor] setStroke];
        [path appendPath:[UIBezierPath bezierPathWithOvalInRect:
                          CGRectMake(-noteWidth/2, -noteHeight/2, noteWidth, noteHeight-1)]];
        [path stroke];
        
        CGContextRotateCTM(context, 45.0);
        CGContextTranslateCTM (context, -(xnote + noteWidth/2 + 1),
                               -(ynote - LineWidth + noteHeight/2));
        
    }
}


/** Load the Right、Wrong and Perfect images into memory. */
+ (void)loadImages {
    NSString *filename;
    if (wrong == NULL) {
        filename = [[NSBundle mainBundle]
                    pathForResource:@"wrong"
                    ofType:@"png"];
        wrong = [[UIImage alloc] initWithContentsOfFile:filename];
    }
    if (perfect == NULL) {
        filename = [[NSBundle mainBundle]
                    pathForResource:@"perfect"
                    ofType:@"png"];
        perfect = [[UIImage alloc] initWithContentsOfFile:filename];
    }
    
    if (right == NULL) {
        filename = [[NSBundle mainBundle]
                    pathForResource:@"right"
                    ofType:@"png"];
        right = [[UIImage alloc] initWithContentsOfFile:filename];
    }
    
    
    if (pedal1 == NULL) {
        filename = [[NSBundle mainBundle]
                    pathForResource:@"pedal-start"
                    ofType:@"png"];
        pedal1 = [[UIImage alloc] initWithContentsOfFile:filename];
    }
    
    if (pedal2 == NULL) {
        filename = [[NSBundle mainBundle]
                    pathForResource:@"pedal-end"
                    ofType:@"png"];
        pedal2 = [[UIImage alloc] initWithContentsOfFile:filename];
    }
    
    if (payin == NULL) {
        filename = [[NSBundle mainBundle]
                    pathForResource:@"payin"
                    ofType:@"png"];
        payin = [[UIImage alloc] initWithContentsOfFile:filename];
    }
    

    
    
    if (shunboyin == NULL) {
        filename = [[NSBundle mainBundle]
                    pathForResource:@"shunboyin"
                    ofType:@"png"];
        shunboyin = [[UIImage alloc] initWithContentsOfFile:filename];
    }
    
    
    if (niboyin == NULL) {
        filename = [[NSBundle mainBundle]
                    pathForResource:@"niboyin"
                    ofType:@"png"];
        niboyin = [[UIImage alloc] initWithContentsOfFile:filename];
    }
    
    
    if (shunhuiyin == NULL) {
        filename = [[NSBundle mainBundle]
                    pathForResource:@"shunhuiyin"
                    ofType:@"png"];
        shunhuiyin = [[UIImage alloc] initWithContentsOfFile:filename];
    }
    
    if (nihuiyin == NULL) {
        filename = [[NSBundle mainBundle]
                    pathForResource:@"nihuiyin"
                    ofType:@"png"];
        nihuiyin = [[UIImage alloc] initWithContentsOfFile:filename];
    }
    
    if (chanyin == NULL) {
        filename = [[NSBundle mainBundle]
                    pathForResource:@"chanyin"
                    ofType:@"png"];
        chanyin = [[UIImage alloc] initWithContentsOfFile:filename];
    }
}

@end

/** Comparison function for sorting Chords by start time */
int sortChordSymbol(id chord1, id chord2, void* unused) {
    ChordSymbol *c1 = (ChordSymbol*) chord1;
    ChordSymbol *c2 = (ChordSymbol*) chord2;
    return [c1 startTime] - [c2 startTime];
}

