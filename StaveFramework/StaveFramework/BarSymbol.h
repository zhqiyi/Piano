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

@interface BarSymbol : NSObject <MusicSymbol> {
    int starttime;
    int width;
    
    int straffHeight;           /** The height of the staff in pixels */
    int tracknum;               /** The track this staff represents */
    int totaltracks;            /** The total number of tracks */
}

-(id)initWithTime:(int) starttime;
-(int)startTime;
-(int)minWidth;
-(int)width;
-(void)setWidth:(int)w;
-(int)aboveStaff;
-(int)belowStaff;

-(void)setTrackNum:(int)num;
-(void)setTotalTracks:(int)value;
-(void)setStraffHeight:(int)height;


-(void)draw:(CGContextRef)context atY:(int)ytop;
-(NSString*)description;

@end

