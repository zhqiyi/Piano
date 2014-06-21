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

#import "MusicSymbol.h"
#import "WhiteNote.h"
#import "TimeSignature.h"
#import "KeySignature.h"
#import "AccidSymbol.h"
#import "Stem.h"
#import "MidiFile.h"


struct _NoteData {
    int number;             /** The Midi note number, used to determine the color */
    __unsafe_unretained WhiteNote *whitenote;   /** The white note location to draw */
    NoteDuration duration;  /** The duration of the note */
    BOOL leftside;          /** Whether to draw note to the left or right of the stem */
    int accid;              /** Used to create the AccidSymbols for the chord */
    /* add by sunlie start */
    int dur;
    int previous;
    int next;
    int addflag;
    /* add by sunlie end */
};
typedef struct _NoteData NoteData;

int sortChordSymbol(id chord1, id chord2, void *unused);

@interface ChordSymbol : NSObject <MusicSymbol> {
    int clef;             /** Which clef the chord is being drawn in */
    int starttime;        /** The time (in pulses) the notes occurs at */
    int endtime;          /** The starttime plus the longest note duration */
    NoteData* notedata;   /** The notes to draw */
    int notedata_len;     /** The length of the notedata array */
    Array* accidsymbols;  /** The accidental symbols to draw */
    int width;            /** The width of the chord */
    Stem *stem1;          /** The stem of the chord. Can be nil. */
    Stem *stem2;          /** The second stem of the chord. Can be nil */
    BOOL hastwostems;     /** True if this chord has two stems */
    void *sheetmusic;     /** Used to get colors and other SheetMusic options */
    /** add by sunlie start */
    int judgedResult;  	 /** 0: wrong 1：good 2：great     add by sunlie */
    int threeNotes;      /** 0: init  1:Triplet  2: before 16 3: after16 4: middle 16--add by sunlie */
    int conLine;
    ChordSymbol *_conLineChord;
    int _conLineWidth;
    int minEndTime;
    int jumpedFlag;      /** 0: init  1:dot  2:triangle  */
    int eightFlag;       /** 0: init  1:low  2:high  */
    ChordSymbol *eightChord;
    int eightWidth;
    int pedalFlag;
    int belongStaffHeight;
    int paFlag;
    int yiFlag;
    int volumeFlag;
    ChordSymbol *volumeChord;
    int volumeWidth;
    int strengthFlag;
    int boFlag;
    int huiFlag;
    int trFlag;
    int stressFlag;
    /** add by sunlie end */

    /** add by yizhq start */
    int _connectNoteWidth;
    NoteData *_connectNote;
    ChordSymbol *_connectChordSymbol;
    NSString *_staffNo;
    int _connectNoteWidth2;
    NoteData *_connectNote2;
    /** add by yizhq end */
}

-(id)initWithNotes:(Array*)notes andKey:(KeySignature*)key
     andTime: (TimeSignature*)time andClef:(int)c andSheet:(void*)s;
-(void) createNoteData:(Array*)notes withKey:(KeySignature*)key
               andTime:(TimeSignature*)time;

    /** add by yizhq start */
-(void)setConnectNoteWidth:(ChordSymbol*) chordSymbol withNoteData:(NoteData*)note andNoteWidth:(int)connectNoteWidth;
-(void)setConnectNoteWidth2:(NoteData*)note andNoteWidth:(int)connectNoteWidth;
-(NoteData *)getNotedata;
-(int)getNotedataLength;
-(NSString *)getStaffNo;
-(void)setStaffNo:(NSString *)staffNo;
    /** add by yizhq end */

-(void)createAccidSymbols;
+(int)stemDirection:(WhiteNote*)bottom withTop:(WhiteNote*)top andClef:(int)clef;
+(BOOL)notesOverlap:(NoteData*)notedata withStart:(int)start andEnd:(int)end;
-(int)startTime;
-(int)endTime;
-(int)clef;
-(BOOL)hasTwoStems;
/* add by sunlie start */
-(int)judgedResult;
-(void)setJudgedResult:(int)j;
-(int)threeNotes;
-(void)setThreeNotes:(int)t;
-(int)conLine;
-(void)setConLine:(int)c;
-(int)minEndTime;
-(int)jumpedFlag;
-(void)setJumpedFlag:(int)j;
-(int)eightFlag;
-(void)setEightFlag:(int)e;
-(int)pedalFlag;
-(void)setPedalFlag:(int)p;
-(ChordSymbol *)_conLineChord;
-(void)setConLineChord:(ChordSymbol *)c;
-(int)_conLineWidth;
-(void)setConLineWidth:(int)c;
-(ChordSymbol *)eightChord;
-(void)setEightChord:(ChordSymbol *)c;
-(int)eightWidth;
-(void)setEightWidth:(int)c;
-(Array*)accidsymbols;
-(ChordSymbol *)connectChordSymbol;
-(void)setChordInfo;
-(void)setBelongStaffHeight:(int)s;
-(void)setStartTime:(int)s;
-(void)setEndTime:(int)e;
-(int)paFlag;
-(void)setPaFlag:(int)p;
-(int)yiFlag;
-(void)setYiFlag:(int)y;
-(int)volumeFlag;
-(void)setVolumeFlag:(int)v;
-(ChordSymbol *)volumeChord;
-(void)setVolumeChord:(ChordSymbol *)c;
-(int)volumeWidth;
-(void)setVolumeWidth:(int)c;
-(int)strengthFlag;
-(void)setStrengthFlag:(int)s;
-(int)boFlag;
-(void)setBoFlag:(int)b;
-(int)huiFlag;
-(void)setHuiFlag:(int)h;
-(int)trFlag;
-(void)setTrFlag:(int)t;
-(int)stressFlag;
-(void)setStressFlag:(int)s;
/* add by sunlie end */
/** add by yizhq start */
-(Stem*) stem1;
/** add by yizhq end */
-(Stem*)stem;
-(int)width;
-(void)setWidth:(int)w;
-(int)minWidth;
-(int)aboveStaff;
-(int)belowStaff;
-(void)draw:(CGContextRef)context atY:(int)ytop;
-(int)drawAccid:(CGContextRef)context atY:(int)ytop;
-(void)drawNotes:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote*)topstaff;
-(void)drawNoteLetters:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote*)topstaff;
-(NSString*)letterFromNumber:(int)num andWhiteNote:(WhiteNote*)w;


-(int)notedata_len;
-(NoteData*)notedata;

+(BOOL)canCreateBeams:(Array*)chords withTime:(TimeSignature*)time 
       onBeat:(BOOL)startQuarter; 
+(void)createBeam:(Array*)chords withSpacing:(int)spacing; 
+(void)bringStemsCloser:(Array*)chords;
+(void)lineUpStemEnds:(Array*)chords;
+(void)loadImages;
-(NSString*)description;


@end


