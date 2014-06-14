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
#import "Array.h"
#import "ClefSymbol.h"
#import "AccidSymbol.h"
#import "KeySignature.h"
#import "TimeSignature.h"
#import "MidiFile.h"
#import "ChordSymbol.h"

@interface Staff : NSObject {
    Array* symbols;             /** The list of music symbols in this staff */
    Array* lyrics;              /** The lyrics to display (can be null) */
    int ytop;                   /** The y pixel of the top of the staff */
    ClefSymbol *clefsym;        /** The left-side Clef symbol */
    Array* keys;                /** The key signature accidental symbols */
    BOOL showMeasures;          /** If true, show the measure numbers */
    int keysigWidth;            /** The width of the clef and key signature */
    int width;                  /** The width of the staff in pixels */
    int height;                 /** The height of the staff in pixels */
    int tracknum;               /** The track this staff represents */
    int totaltracks;            /** The total number of tracks */
    int starttime;              /** The time (in pulses) of first symbol */
    int endtime;                /** The time (in pulses) of last symbol */
    int measureLength;          /** The time (in pulses) of a measure */
    /** add by yizhq start */
    IntArray *eightVeIndex;
    /** add by yizhq end */
    
    
    id <MusicSymbol> shadeCurr;
    int shadeXpos;
    BOOL isFind;
}

-(id)initWithSymbols:(Array*)symbols andKey:(KeySignature*)key 
     andOptions:(MidiOptions*)options 
     andTrack:(int)t andTotalTracks:(int)total;
-(int)findClef;
-(void)calculateHeight;
-(void)calculateWidth:(BOOL)scrollVert;
-(void)calculateStartEndTime;
-(void)fullJustify;
-(void)addLyrics:(Array*)lyrics;
-(void)drawHorizLines:(CGContextRef)context;
-(void)drawEndLines:(CGContextRef)context;
-(void)drawRect:(CGContextRef)context InRect:(CGRect)clip;
-(void)drawMeasureNumbers:(CGContextRef)context;
-(void)drawLyrics:(CGContextRef)context;
-(int)width;
-(int)height;
-(int)startTime;
-(int)endTime;
-(void)setEndTime:(int)value;
-(int)tracknum;
/** add by sunlie start */
-(Array*)symbols;
-(void)setHeight:(int)h;
/** add by sunlie end */
-(void)shadeNotes:(CGContextRef)context withCurr:(int)currentPulseTime withPrev:(int)prevPulseTime
       andX:(int*)x_shade andColor:(UIColor*)color ;
-(void)dealloc;
-(NSString*)description;

- (int)calcShadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime andX:(int *)x_shade;
- (void)shadeNotes:(CGContextRef)context withColor: (UIColor *)color;
- (void)cleanShadeNote;
- (int)setShadeNotesModel1:(int)value withChordSymbol:(ChordSymbol*)symbol andX:(int *)x_shade;
@end


