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
#import <Foundation/NSString.h>
#import "MusicSymbol.h"
#import "WhiteNote.h"

/** Accidentals */
enum {
    AccidNone, AccidSharp, AccidFlat, AccidNatural
};

@interface AccidSymbol : NSObject <MusicSymbol> {
    int accid;             /** The accidental (sharp, flat, natural) */
    WhiteNote* whitenote;  /** The white note where the symbol occurs */
    int clef;              /** Which clef the symbols is in */
    int width;             /** Width of symbol */
}

-(id)initWithAccid:(int)a andNote:(WhiteNote*)note andClef:(int)clef;
-(WhiteNote*)note;
-(int)startTime;
-(int)minWidth;
-(int)width;
-(void)setWidth:(int) w;
-(int)aboveStaff;
-(int)belowStaff;
-(void) draw:(CGContextRef) context atY:(int) ytop;
-(void)drawSharp:(CGContextRef) context atY:(int)ynote;
-(void)drawFlat:(CGContextRef) context atY:(int)ynote;
-(void)drawNatural:(CGContextRef) context atY:(int)ynote;
-(NSString*)description;
-(void)dealloc;

@end

