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
#import "TimeSignature.h"

@interface RestSymbol : NSObject <MusicSymbol> {
    int starttime;          /** The starttime of the rest */
    NoteDuration duration;  /** The rest duration (eighth, quarter, half, whole) */
    int width;              /** The width in pixels */
}

-(id)initWithTime:(int)t andDuration:(int)dur;
-(int)startTime;
-(int)width;
-(void)setWidth:(int)w;
-(int)minWidth;
-(int)aboveStaff;
-(int)belowStaff;
-(NoteDuration)duration;   /** add by sunlie */
-(void)draw:(CGContextRef)context atY:(int)ytop;
-(void)drawWhole:(CGContextRef)context atY:(int)ytop;
-(void)drawHalf:(CGContextRef)context atY:(int)ytop;
-(void)drawQuarter:(CGContextRef)context atY:(int)ytop;
-(void)drawEighth:(CGContextRef)context atY:(int)ytop;
-(NSString*)description;

@end

