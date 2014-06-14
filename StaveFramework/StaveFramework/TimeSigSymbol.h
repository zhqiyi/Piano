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

#import <Foundation/NSObject.h>
#import "MusicSymbol.h"

@interface TimeSigSymbol : NSObject <MusicSymbol> {
    int  numerator;         /** The numerator */
    int  denominator;       /** The denominator */
    int  width;             /** The width in pixels */
    BOOL candraw;           /** True if we can draw the time signature */
    int  starttime;         /** add by sunlie */
}

-(id)initWithNumer:(int)n andDenom:(int)d andStartTime:(int)s;     /** modify by sunlie */
+(void)loadImages;
-(int)startTime;
-(int)minWidth;
-(int)width;
-(void)setWidth:(int)w;
-(int)aboveStaff;
-(int)belowStaff;
-(void)draw:(CGContextRef)context atY:(int)ytop;
-(NSString*)description;

@end

