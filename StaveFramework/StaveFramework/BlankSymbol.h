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

@interface BlankSymbol : NSObject <MusicSymbol> {
    int starttime; 
    int width;
};

-(id)initWithTime:(int)starttime andWidth:(int)width;
-(int)startTime;
-(int)minWidth;
-(int)width;
-(void)setWidth:(int) w;
-(int)aboveStaff;
-(int)belowStaff;
-(void)draw:(CGContextRef)context atY:(int)ytop;
-(NSString*) description;

@end

