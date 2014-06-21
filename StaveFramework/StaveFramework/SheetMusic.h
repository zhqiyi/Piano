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

#import "Array.h"
#import "TimeSignature.h"
#import "KeySignature.h"
#import "ClefMeasures.h"
#import "MidiFile.h"
#import "SymbolWidths.h"
#import "MusicSymbol.h"
#import "Staff.h"

#define PageWidth   800   /* The width of each page */
#define PageHeight 1050   /* The height of each page (when printing) */


/* add by sunlie start */
struct _ControlAll {
    __unsafe_unretained Array *list1;
    __unsafe_unretained Array *list2;
    __unsafe_unretained Array *list3;
    __unsafe_unretained Array *list4;
};
typedef struct _ControlAll ControlAll;
/* add by sunlie end */

id<MusicSymbol> getSymbol(Array *symbols, int index);

@interface SheetMusic : UIView {
    Array* staffs;            /** The array of Staffs to display (from top to bottom) */
    KeySignature *mainkey;    /** The main key signature */
    int numtracks;            /** The number of tracks */
    float zoom;               /** The zoom level to draw at (1.0 == 100%) */
    BOOL scrollVert;          /** Whether to scroll vertically or horizontally */
    int showNoteLetters;      /** Show the note letters */
    NSString *filename;       /** The MIDI file name */
    UIColor* NoteColors[12];  /** The colors to use for drawing each note */
    UIColor *shadeColor;      /** The color for shading */
    UIColor *shade2Color;     /** The color for shading left-hand piano */
    /* add by sunlie start */
    Array* beatarray;
    Array* tonearray;
    /* add by sunlie end */
    /** add by yizhq start */
    CGContextRef pContext;
    int shadeCurrentPulseTime;
    int shadePrevPulseTime;
    int x_shade;
    CGPoint shadePos;
    
    
    float width;
    float height;
    
    /** add by yizhq start */
    BOOL modelFlag;
    UIColor *SectionNormalColor;
    UIColor *SectionHighLightColor;
    int SectionStartTime;
    int SectionEndTime;
    MidiOptions *smOptions;
    /** add by yizhq end */
}

-(id)initWithFile:(MidiFile*)file andOptions:(MidiOptions*)options;
-(KeySignature*) getKeySignature:(Array*)tracks;
-(Array*) createChords:(Array*)midinotes withKey:(KeySignature*)key
               andTime:(TimeSignature*)time andClefs:(ClefMeasures*) clefs andCList2:(Array *)list andCList3:(Array *)list3
             andCList4:(Array *)list4 andCList5:(Array *)list5 andCList7:(Array *)list7 andCList8:(Array *)list8 andCList9:(Array *)list9 andCList10:(Array *)list10 andCList11:(Array *)list11 andCList14:(Array *)list14;
-(Array*) createSymbols:(Array*)chords withClefs:(ClefMeasures*)clefs
                andTime:(TimeSignature*)time andLastTime:(int)lastStartTime andBeatarray:(Array *)barray;
-(Array*) addBars:(Array*)chords withTime:(TimeSignature*)time
      andLastTime:(int)lastStartTime andBeatarray:(Array *)barray;
-(Array*) addRests:(Array*)chords withTime:(TimeSignature*)time andBeatarray:(Array *)barray;
-(Array*) getRests:(TimeSignature*)time fromStart:(int)start toEnd:(int)end andBeatarray:(Array *)barray;
-(Array*) addClefChanges:(Array*)symbols withClefs:(ClefMeasures*)clefs
                 andTime:(TimeSignature*) time;
-(void) alignSymbols:(Array*)allsymbols withWidths:(SymbolWidths *)widths;
+(int) keySignatureWidth:(KeySignature*)key;
-(Array*) createStaffsForTrack:(Array*)symbols withKey:(KeySignature*)key
                    andMeasure:(int) measurelen andOptions:(MidiOptions*)options
                      andTrack:(int)track andTotalTracks:(int)totaltracks;
-(Array*) createStaffs:(Array*)allsymbols withKey:(KeySignature*)key
            andOptions:(MidiOptions*)options andMeasure:(int)measurelen;
+(BOOL)findConsecutiveChords:(Array*)symbols andTime:(TimeSignature*) time
                    andStart:(int)startIndex andIndexes:(int*) chordIndexes
                andNumChords:(int)numChords andHorizDistance:(int*)dist;
-(void)createBeamedChords:(Array*)allsymbols withTime:(TimeSignature*)time
             andNumChords:(int)numChords onBeat:(BOOL)startBeat;
-(void)createAllBeamedChords:(Array*)allsymbols withTime:(TimeSignature*)time;
-(void) setZoom:(float)value;
-(int) showNoteLetters;
-(void)drawTitle;
-(void) drawRect:(CGRect) rect;
-(BOOL) knowsPageRange:(NSRange*)range;
-(CGRect)rectForPage:(int)pagenum;
-(CGSize) printerPageSize;
-(NSAttributedString*)pageHeader;
-(NSAttributedString*)pageFooter;
-(void) shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime gradualScroll:(BOOL)value;
-(void) scrollToShadedNotes:(CGPoint)shadePos gradualScroll:(BOOL)value;
-(void) setColors:(Array*)newcolors andShade:(UIColor*)c andShade2:(UIColor*)c2;
-(UIColor*)noteColor:(int) notescale;
-(UIColor*) shadeColor;
-(UIColor*) shade2Color;
-(KeySignature*)mainkey;
-(Array*)getLyrics:(Array*)tracks;
-(void)addLyrics:(Array*)lyrics toStaffs:(Array*)staffs;
-(void) dealloc;
-(Array*)getStaffs;
-(int) getTrackCounts;
-(void)shadeNotesByModel1:(int)staffIndex andChordIndex:(int)chordIndex andChord:(ChordSymbol*)chord;
	
+(void) setNoteSize:(BOOL) largenotes;
/** add by yizhq start */
+(int) getNoteWidth;
+(int) getNoteHeight;

-(void)setColors4Section:(BOOL)flag;
-(int)getSheetMusicCurrentModel;
-(void)setJSModel:(int)startSectionNum withEndSectionNum:(int)endSectionNum withTimeNumerator:(int)numerrator withTimeQuarter:(int)quarter withMeasure:(int)measure;
-(void)clearJSModel;
/** add by yizhq end */

+(NSDictionary*)fontAttributes;


@property (strong, nonatomic) UIScrollView *scrollView;

@end



