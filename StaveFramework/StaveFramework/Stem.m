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


/** @class Stem
 * The Stem class is used by ChordSymbol to draw the stem portion of
 * the chord.  The stem has the following fields:
 *
 * duration  - The duration of the stem.
 * direction - Either StemUp or StemDown
 * side      - Either left or right
 * top       - The topmost note in the chord
 * bottom    - The bottommost note in the chord
 * end       - The note position where the stem ends.  This is usually
 *             six notes past the last note in the chord.  For 8th/16th
 *             notes, the stem must extend even more.
 *
 * The class can change the direction of a stem after it
 * has been created.  The side and end fields may also change due to
 * the direction change.  But other fields will not change.
 */
#import "MusicSymbol.h"
#import "Stem.h"
#import "TimeSignature.h"

@implementation Stem

/** Get the direction of the stem (Up or Down) */
- (int)direction {
    return direction;
}

/** Get the duration of the stem (Eigth, Sixteenth, ThirtySecond) */
- (NoteDuration)duration {
    return duration;
}

/** Get the top note in the chord. This is needed to determine the stem direction */
- (WhiteNote*)top {
    return top;
}

/** Get the bottom note in the chord. This is needed to determine the stem direction */
- (WhiteNote*)bottom {
    return bottom;
}

/** Get the location where the stem ends.  This is usually six notes
 * past the last note in the chord. See method CalculateEnd.
 */
- (WhiteNote*)end {
    return end;
}


/** Get which side of the note the Stem is on (left or right). */
- (int)side {
    return side;
}


/** Set the location where the stem ends.  This is usually six notes
 * past the last note in the chord. See method CalculateEnd.
 */
- (void)setEnd:(WhiteNote*)w {
    WhiteNote *old = end;
    end = [w retain];
    [old release];
}

/** Return true if this is a receiver stem */
- (BOOL)receiver {
    return receiver_in_pair;
}

/** Set this Stem to be the receiver of a horizontal beam, as part
 * of a chord pair.  In draw(), if this stem is a receiver, we
 * don't draw a curvy stem, we only draw the vertical line.
 */
- (void)setReceiver:(BOOL)value {
    receiver_in_pair = value;
}

/** add by sunlie start */
- (int)cutNote {
    return cutNote;
}
- (void)setCutNote:(int)c {
    cutNote = c;
}
/** add by sunlie end */

/** Create a new stem.  The top note, bottom note, and direction are
 * needed for drawing the vertical line of the stem.  The duration is
 * needed to draw the tail of the stem.  The overlap boolean is true
 * if the notes in the chord overlap.  If the notes overlap, the
 * stem must be drawn on the right side.
 */
- (id)initWithBottom:(WhiteNote*)b andTop:(WhiteNote*)t
         andDuration:(int)dur andDirection:(int)dir andOverlap:(BOOL)overlap {
    
    top = [t retain];
    bottom = [b retain];
    duration = dur;
    direction = dir;
    notesoverlap = overlap;
    
    if (direction == StemUp || notesoverlap)
        side = RightSide;
    else
        side = LeftSide;
    end = [self calculateEnd];
    pair = nil;
    width_to_pair = 0;
    receiver_in_pair = NO;
    /** add by sunlie start */
    width_to_pairex = 0;
    cutNote = 0;
    /** add by sunlie end */
    return self;
}

/** Calculate the vertical position (white note key) where
 * the stem ends
 */
- (WhiteNote*)calculateEnd {
    id old;
    if (direction == StemUp) {
        WhiteNote *w = [top add:6];
        if (duration == Sixteenth) {
            old = w;
            w = [w add:2];
            [old release];
        }
        else if (duration == ThirtySecond) {
            old = w;
            w = [w add:4];
            [old release];
        }
        return w;
    }
    else if (direction == StemDown) {
        WhiteNote *w = [bottom add:-6];
        if (duration == Sixteenth) {
            old = w;
            w = [w add:-2];
            [old release];
        }
        else if (duration == ThirtySecond) {
            old = w;
            w = [w add:-4];
            [old release];
        }
        return w;
    }
    else {
        return nil;  /* Shouldn't happen */
    }
}

/** Change the direction of the stem.  This function is called by
 * ChordSymbol.makePair().  When two chords are joined by a horizontal
 * beam, their stems must point in the same direction (up or down).
 */
- (void)setDirection:(int)newdirection {
    direction = newdirection;
    if (direction == StemUp || notesoverlap)
        side = RightSide;
    else
        side = LeftSide;
    
    [end release];
    end = [self calculateEnd];
}

/** Pair this stem with another Chord.  Instead of drawing a curvy tail,
 * this stem will now have to draw a beam to the given stem pair.  The
 * width (in pixels) to this stem pair is passed as argument.
 */
- (void)setPair:(Stem*)p withWidth:(int)width {
    id old = pair;
    pair = [p retain];
    [old release];
    width_to_pair = width;
}

/** add by sunlie start */
-(void)setPairex:(Stem*)p withWidth:(int)width {
    id old = pairex;
    pairex = [p retain];
    [old release];
    width_to_pairex = width;
}
/** add by sunlie end */

-(BOOL)isBeam {
    return receiver_in_pair || (pair != nil);
}

/** Draw this stem.
 * @param ytop The y location (in pixels) where the top of the staff starts.
 * @param topstaff  The note at the top of the staff.
 */
/** modify by sunlie start */
-(void)draw:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote *)topstaff threeFlag:(int)threeFlag {
    if (duration == Whole)
        return;
    
    [self drawVerticalLine:context atY:ytop topStaff:topstaff threeFlag:threeFlag];
    if (duration == Quarter ||
        duration == DottedQuarter ||
        duration == Half ||
        duration == DottedHalf ||
        (receiver_in_pair && pair == nil)) {
        
        return;
    }
    
    if (pair != nil) {
        [self drawBeamStem:context atY:ytop topStaff:topstaff];
        if (pairex != nil) {
            [self drawBeamStemEx:context atY:ytop topStaff:topstaff];
        }
    }
    else
        [self drawCurvyStem:context atY:ytop topStaff:topstaff];
}
/** modify by sunlie end */

/** Draw the vertical line of the stem.
 * @param ytop The y location (in pixels) where the top of the staff starts.
 * @param topstaff  The note at the top of the staff.
 */
- (void)drawVerticalLine:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote *)topstaff threeFlag:(int)threeFlag {
    int xstart;
    if (side == LeftSide)
        xstart = LineSpace/4 + 1;
    else
        xstart = LineSpace/4 + NoteWidth;
    
    if (direction == StemUp) {
        int y1 = ytop + [topstaff dist:bottom] * NoteHeight/2
        + NoteHeight/4;
        
        int ystem = ytop + [topstaff dist:end] * NoteHeight/2;
        
        /** add by sunlie start for show */
        //        if (duration == Whole || duration == Half) {
        //            xstart += NoteWidth;
        //        }
        /** add by sunlie end for show */
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(xstart, y1)];
        [path addLineToPoint:CGPointMake(xstart, ystem)];
        [path stroke];
//        if(threeFlag == 1) {
//            CGContextSetRGBFillColor (context,  1, 0, 0, 1.0);
//            UIFont  *font = [UIFont boldSystemFontOfSize:15.0];
//            [@"3" drawInRect:CGRectMake(xstart, ystem-5, 10, 10) withFont:font];
//        }
    }
    else if (direction == StemDown) {
        int y1 = ytop + [topstaff dist:top] * NoteHeight/2
        + NoteHeight;
        
        if (side == LeftSide)
            y1 = y1 - NoteHeight/4;
        else
            y1 = y1 - NoteHeight/2;
        
        int ystem = ytop + [topstaff dist:end] * NoteHeight/2
        + NoteHeight;
        
        /** add by sunlie start for show */
        //        if (duration == Whole || duration == Half) {
        //            xstart -= NoteWidth;
        //        }
        /** add by sunlie end for show */
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(xstart, y1)];
        [path addLineToPoint:CGPointMake(xstart, ystem)];
        [path stroke];
//        if(threeFlag == 1) {
//            CGContextSetRGBFillColor (context,  1, 0, 0, 1.0);
//            UIFont  *font = [UIFont boldSystemFontOfSize:15.0];
//            [@"3" drawInRect:CGRectMake(xstart, ystem+12, 10, 10) withFont:font];
//        }
    }
}

/** Draw a curvy stem tail.  This is only used for single chords, not chord pairs.
 * @param ytop The y location (in pixels) where the top of the staff starts.
 * @param topstaff  The note at the top of the staff.
 */
- (void)drawCurvyStem:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote *)topstaff {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path setLineWidth:2];
    
    int xstart = 0;
    if (side == LeftSide)
        xstart = LineSpace/4 + 1;
    else
        xstart = LineSpace/4 + NoteWidth;
    
    if (direction == StemUp) {
        int ystem = ytop + [topstaff dist:end] * NoteHeight/2;
        
        if (duration == Eighth ||
            duration == DottedEighth ||
            duration == Triplet ||
            duration == Sixteenth ||
            duration == ThirtySecond) {
            
            [path moveToPoint:CGPointMake(xstart, ystem)];
            [path addCurveToPoint:CGPointMake(xstart + LineSpace/2,
                                              ystem + NoteHeight*3)
                    controlPoint1:CGPointMake(xstart,
                                              ystem + 3*LineSpace/2)
                    controlPoint2:CGPointMake(xstart + LineSpace*2,
                                              ystem + NoteHeight*2)
             ];
        }
        ystem += NoteHeight;
        
        if (duration == Sixteenth ||
            duration == ThirtySecond) {
            
            [path moveToPoint:CGPointMake(xstart, ystem)];
            [path addCurveToPoint:CGPointMake(xstart + LineSpace/2,
                                              ystem + NoteHeight*3)
                    controlPoint1:CGPointMake(xstart,
                                              ystem + 3*LineSpace/2)
                    controlPoint2:CGPointMake(xstart + LineSpace*2,
                                              ystem + NoteHeight*2)
             ];
        }
        
        ystem += NoteHeight;
        if (duration == ThirtySecond) {
            [path moveToPoint:CGPointMake(xstart, ystem)];
            [path addCurveToPoint:CGPointMake(xstart + LineSpace/2,
                                              ystem + NoteHeight*3)
                    controlPoint1:CGPointMake(xstart,
                                              ystem + 3*LineSpace/2)
                    controlPoint2:CGPointMake(xstart + LineSpace*2,
                                              ystem + NoteHeight*2)
             ];
        }
    }
    
    else if (direction == StemDown) {
        int ystem = ytop + [topstaff dist:end]*NoteHeight/2 +
        NoteHeight;
        
        if (duration == Eighth ||
            duration == DottedEighth ||
            duration == Triplet ||
            duration == Sixteenth ||
            duration == ThirtySecond) {
            
            [path moveToPoint:CGPointMake(xstart, ystem)];
            [path addCurveToPoint:CGPointMake(xstart + LineSpace,
                                              ystem - NoteHeight*2 - LineSpace/2)
                    controlPoint1:CGPointMake(xstart,
                                              ystem - LineSpace)
                    controlPoint2:CGPointMake(xstart + LineSpace*2,
                                              ystem - NoteHeight*2)
             ];
        }
        ystem -= NoteHeight;
        
        if (duration == Sixteenth ||
            duration == ThirtySecond) {
            
            [path moveToPoint:CGPointMake(xstart, ystem)];
            [path addCurveToPoint:CGPointMake(xstart + LineSpace,
                                              ystem - NoteHeight*2 - LineSpace/2)
                    controlPoint1:CGPointMake(xstart,
                                              ystem - LineSpace)
                    controlPoint2:CGPointMake(xstart + LineSpace*2,
                                              ystem - NoteHeight*2)
             ];
        }
        
        ystem -= NoteHeight;
        if (duration == ThirtySecond) {
            [path moveToPoint:CGPointMake(xstart, ystem)];
            [path addCurveToPoint:CGPointMake(xstart + LineSpace,
                                              ystem - NoteHeight*2 - LineSpace/2)
                    controlPoint1:CGPointMake(xstart,
                                              ystem - LineSpace)
                    controlPoint2:CGPointMake(xstart + LineSpace*2,
                                              ystem - NoteHeight*2)
             ];
        }
    }
    [path stroke];
}

/* Draw a horizontal beam stem, connecting this stem with the Stem pair.
 * @param ytop The y location (in pixels) where the top of the staff starts.
 * @param topstaff  The note at the top of the staff.
 */
- (void)drawBeamStem:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote *)topstaff {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path setLineWidth:NoteHeight/2];
    
    int xstart = 0;
    int xstart2 = 0;
    
    if (side == LeftSide)
        xstart = LineSpace/4 + 1;
    else if (side == RightSide)
        xstart = LineSpace/4 + NoteWidth;
    
    if ([pair side] == LeftSide)
        xstart2 = LineSpace/4 + 1;
    else if ([pair side] == RightSide)
        xstart2 = LineSpace/4 + NoteWidth;
    
    
    if (direction == StemUp) {
        int xend = width_to_pair + xstart2;
        int ystart = ytop + [topstaff dist:end] * NoteHeight/2;
        int yend = ytop + [topstaff dist:[pair end]] * NoteHeight/2;
        
        if (duration == Eighth ||
            duration == DottedEighth ||
            duration == Triplet ||
            duration == Sixteenth ||
            duration == ThirtySecond) {
            
            [path moveToPoint:CGPointMake(xstart, ystart)];
            [path addLineToPoint:CGPointMake(xend, yend)];
        }
        ystart += NoteHeight;
        yend += NoteHeight;
        
        /* A dotted eighth will connect to a 16th note. */
        if (duration == DottedEighth) {
            int x = xend - NoteHeight;
            double slope = (yend - ystart) * 1.0 / (xend - xstart);
            int y = (int)(slope * (x - xend) + yend);
            
            [path moveToPoint:CGPointMake(x, y)];
            [path addLineToPoint:CGPointMake(xend, yend)];
        }
        
        /** add by sunlie start */
        if (cutNote == 1) {
            int x = xstart + NoteHeight;
            double slope = (yend - ystart) * 1.0 / (xend - xstart);
            int y = (int)(slope * (x - xstart) + ystart);
            
            [path moveToPoint:CGPointMake(xstart, ystart)];
            [path addLineToPoint:CGPointMake(x, y)];
            
            x = xend - NoteHeight;
            y = (int)(slope * (x - xend) + yend);
            
            [path moveToPoint:CGPointMake(x, y)];
            [path addLineToPoint:CGPointMake(xend, yend)];
        }
        /** add by sunlie end */
        
        /** modify by sunlie */
        if ((duration == Sixteenth && cutNote == 0) ||
            duration == ThirtySecond) {
            
            [path moveToPoint:CGPointMake(xstart, ystart)];
            [path addLineToPoint:CGPointMake(xend, yend)];
        }
        ystart += NoteHeight;
        yend += NoteHeight;
        
        if (duration == ThirtySecond) {
            [path moveToPoint:CGPointMake(xstart, ystart)];
            [path addLineToPoint:CGPointMake(xend, yend)];
        }
    }
    
    else {
        int xend = width_to_pair + xstart2;
        int ystart = ytop + [topstaff dist:end] * NoteHeight/2 +
        NoteHeight;
        int yend = ytop + [topstaff dist:[pair end]] * NoteHeight/2
        + NoteHeight;
        
        if (duration == Eighth ||
            duration == DottedEighth ||
            duration == Triplet ||
            duration == Sixteenth ||
            duration == ThirtySecond) {
            
            [path moveToPoint:CGPointMake(xstart, ystart)];
            [path addLineToPoint:CGPointMake(xend, yend)];
        }
        ystart -= NoteHeight;
        yend -= NoteHeight;
        
        /* A dotted eighth will connect to a 16th note. */
        if (duration == DottedEighth) {
            int x = xend - NoteHeight;
            double slope = (yend - ystart) * 1.0 / (xend - xstart);
            int y = (int)(slope * (x - xend) + yend);
            
            [path moveToPoint:CGPointMake(x, y)];
            [path addLineToPoint:CGPointMake(xend, yend)];
        }
        
        /** add by sunlie start */
        if (cutNote == 1) {
            int x = xstart + NoteHeight;
            double slope = (yend - ystart) * 1.0 / (xend - xstart);
            int y = (int)(slope * (x - xstart) + ystart);
            
            [path moveToPoint:CGPointMake(xstart, ystart)];
            [path addLineToPoint:CGPointMake(x, y)];
            
            x = xend - NoteHeight;
            y = (int)(slope * (x - xend) + yend);
            
            [path moveToPoint:CGPointMake(x, y)];
            [path addLineToPoint:CGPointMake(xend, yend)];
        }
        /** add by sunlie end */

        /** modify by sunlie */
        if ((duration == Sixteenth && cutNote == 0) ||
            duration == ThirtySecond) {
            
            [path moveToPoint:CGPointMake(xstart, ystart)];
            [path addLineToPoint:CGPointMake(xend, yend)];
        }
        ystart -= NoteHeight;
        yend -= NoteHeight;
        
        if (duration == ThirtySecond) {
            [path moveToPoint:CGPointMake(xstart, ystart)];
            [path addLineToPoint:CGPointMake(xend, yend)];
        }
    }
    [path stroke];
}

/** add by sunlie start */
- (void)drawBeamStemEx:(CGContextRef)context atY:(int)ytop topStaff:(WhiteNote*)topstaff {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path setLineWidth:NoteHeight/2];
    
    int xstart = 0;
    int xstart2 = 0;
    
    if (side == LeftSide)
        xstart = LineSpace/4 + 1;
    else if (side == RightSide)
        xstart = LineSpace/4 + NoteWidth;
    
    if ([pairex side] == LeftSide)
        xstart2 = LineSpace/4 + 1;
    else if ([pairex side] == RightSide)
        xstart2 = LineSpace/4 + NoteWidth;
    
    if (direction == StemUp) {
        int xend = width_to_pairex + xstart2;
        int ystart = ytop + [topstaff dist:end] * NoteHeight/2;
        int yend = ytop + [topstaff dist:[pairex end]] * NoteHeight/2;
        
        if (duration == Eighth ||
            duration == DottedEighth ||
            duration == Triplet ||
            duration == Sixteenth ||
            duration == ThirtySecond) {
            
            [path moveToPoint:CGPointMake(xstart, ystart)];
            [path addLineToPoint:CGPointMake(xend, yend)];
        }
        ystart += NoteHeight;
        yend += NoteHeight;
        
        /* A dotted eighth will connect to a 16th note. */
        if (duration == DottedEighth) {
            int x = xend - NoteHeight;
            double slope = (yend - ystart) * 1.0 / (xend - xstart);
            int y = (int)(slope * (x - xend) + yend);
            
            [path moveToPoint:CGPointMake(x, y)];
            [path addLineToPoint:CGPointMake(xend, yend)];
        }
        
        if (([pairex duration] == Sixteenth) ||
            [pairex duration] == ThirtySecond) {
            
            [path moveToPoint:CGPointMake(xstart, ystart)];
            [path addLineToPoint:CGPointMake(xend, yend)];
        }
        ystart += NoteHeight;
        yend += NoteHeight;
        
        if ([pairex duration] == ThirtySecond) {
            [path moveToPoint:CGPointMake(xstart, ystart)];
            [path addLineToPoint:CGPointMake(xend, yend)];
        }
    }
    
    else {
        int xend = width_to_pairex + xstart2;
        int ystart = ytop + [topstaff dist:end] * NoteHeight/2 +
        NoteHeight;
        int yend = ytop + [topstaff dist:[pairex end]] * NoteHeight/2
        + NoteHeight;
        
        if (duration == Eighth ||
            duration == DottedEighth ||
            duration == Triplet ||
            duration == Sixteenth ||
            duration == ThirtySecond) {
            
            [path moveToPoint:CGPointMake(xstart, ystart)];
            [path addLineToPoint:CGPointMake(xend, yend)];
        }
        ystart -= NoteHeight;
        yend -= NoteHeight;
        
        /* A dotted eighth will connect to a 16th note. */
        if (duration == DottedEighth) {
            int x = xend - NoteHeight;
            double slope = (yend - ystart) * 1.0 / (xend - xstart);
            int y = (int)(slope * (x - xend) + yend);
            
            [path moveToPoint:CGPointMake(x, y)];
            [path addLineToPoint:CGPointMake(xend, yend)];
        }
        
        if (([pairex duration] == Sixteenth) ||
            [pairex duration] == ThirtySecond) {
            
            [path moveToPoint:CGPointMake(xstart, ystart)];
            [path addLineToPoint:CGPointMake(xend, yend)];
        }
        ystart -= NoteHeight;
        yend -= NoteHeight;
        
        if ([pairex duration] == ThirtySecond) {
            [path moveToPoint:CGPointMake(xstart, ystart)];
            [path addLineToPoint:CGPointMake(xend, yend)];
        }
    }
    [path stroke];
}
/** add by sunlie end */

- (void)dealloc {
    [top release];
    [bottom release];
    [end release];
    [pair release];
    [super dealloc];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"Stem duration=%@ direction=%d top=%@ bottom=%@ end=%@ overlap=%d side=%d width_to_pair=%d receiver_in_pair=%d",
            [TimeSignature durationString:duration], 
            direction, 
            [top description], [bottom description], [end description], 
            notesoverlap, side, width_to_pair, receiver_in_pair ];
}


@end


