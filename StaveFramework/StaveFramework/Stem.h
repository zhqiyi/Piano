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

#import "WhiteNote.h"
#import "TimeSignature.h"

#define StemUp     1  /* The stem points up */
#define StemDown   2  /* The stem points down */
#define LeftSide   1  /* The stem is to the left of the note */
#define RightSide  2  /* The stem is to the right of the note */

@interface Stem : NSObject {
    NoteDuration duration; /** Duration of the stem. */
    int direction;         /** Up, Down, or None */
    WhiteNote* top;        /** Topmost note in chord */
    WhiteNote* bottom;     /** Bottommost note in chord */
    WhiteNote* end;        /** Location of end of the stem */
    BOOL notesoverlap;     /** Do the chord notes overlap */
    int side;              /** Left side or right side of note */

    Stem* pair;            /** If pair != null, this is a horizontal 
                            * beam stem to another chord */
    int width_to_pair;     /** The width (in pixels) to the chord pair */
    BOOL receiver_in_pair; /** This stem is the receiver of a horizontal
                            * beam stem from another chord. */
    /** add by sunlie start */
    Stem* pairex;
    int width_to_pairex;
    int cutNote;        /** init: 0   cutnote:1  */
    /** add by sunlie end */
}

-(int)direction;
-(void)setDirection:(int)v;
-(NoteDuration)duration;
-(WhiteNote*) top;
-(WhiteNote*) bottom;
-(WhiteNote*) end;
-(int)side;
-(void)setEnd:(WhiteNote*)w;
-(BOOL)isBeam;
-(BOOL)receiver;
-(void)setReceiver:(BOOL) value;
-(id)initWithBottom:(WhiteNote*)b andTop:(WhiteNote*)t
     andDuration:(int)dur andDirection:(int)dir
     andOverlap:(BOOL)overlap;
-(WhiteNote*)calculateEnd;
-(void)setPair:(Stem*)pair withWidth:(int)width_to_pair;
/** add by sunlie start */
-(void)setPairex:(Stem*)pair withWidth:(int)width_to_pair;
-(int)cutNote;
-(void)setCutNote:(int)c;
-(void)drawBeamStemEx:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote*)topstaff;
/** add by sunlie end */
-(void)draw:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote*)topstaff threeFlag:(int)threeFlag;
-(void)drawVerticalLine:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote*)topstaff threeFlag:(int)threeFlag;
-(void)drawCurvyStem:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote*)topstaff;
-(void)drawBeamStem:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote*)topstaff;
-(void)dealloc;

@end


