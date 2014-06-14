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
#import "BarSymbol.h"


/** @class BarSymbol 
 * The BarSymbol represents the vertical bars which delimit measures.
 * The starttime of the symbol is the beginning of the new
 * measure.
 */
@implementation BarSymbol

/** Create a BarSymbol. The starttime should be the beginning of a measure. */
- (id)initWithTime:(int)start {
    starttime = start;
    width = NoteWidth;
    return self;
}

/** Get the time (in pulses) this symbol occurs at.
 * This is used to determine the measure this symbol belongs to.
 */
- (int)startTime {
    return starttime;
}

/** Get the minimum width (in pixels) needed to draw this symbol */
- (int)minWidth {
    return 2 * LineSpace;
}

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

/** Get the number of pixels this symbol extends above the staff. Used
 *  to determine the minimum height needed for the staff (Staff:findBounds).
 */
- (int)aboveStaff {
    return 0;
}

/** Get the number of pixels this symbol extends below the staff. Used
 *  to determine the minimum height needed for the staff (Staff:findBounds).
 */
- (int)belowStaff {
    return 0;
}


-(void)setTrackNum:(int)num
{
    tracknum = num;
}

-(void)setTotalTracks:(int)value
{
    totaltracks = value;
}

-(void)setStraffHeight:(int)height
{
    straffHeight = height;
}


/** Draw a vertical bar.
 * @param ytop The ylocation (in pixels) where the top of the staff starts.
 */
-(void)draw:(CGContextRef)context atY:(int)ytop; {
//    int y = ytop;
//    int yend = y + LineSpace*4 + LineWidth*4;
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path moveToPoint:CGPointMake(NoteWidth/2, y)];
//    [path addLineToPoint:CGPointMake(NoteWidth/2, yend)];
//    [path setLineWidth:1];
//    [path stroke];
    

    int ystart, yend;
    if (tracknum == 0)
        ystart = ytop - LineWidth;
    else
        ystart = 0;
    
    if (tracknum == (totaltracks-1))
        yend = ytop + 4 * NoteHeight;
    else
        yend = straffHeight;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(NoteWidth/2, ystart)];
    [path addLineToPoint:CGPointMake(NoteWidth/2, yend)];
    [path stroke];
    
}

- (NSString*)description {
    NSString *s = [NSString stringWithFormat:
                    @"BarSymbol starttime=%d width=%d",
                      starttime, width];
    return s;
}

@end


