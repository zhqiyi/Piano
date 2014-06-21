/*
 * Copyright (c) 2007-2011 Madhav Vaidyanathan
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
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSZone.h>
#import <Foundation/NSException.h>

#import "Array.h"
#import "TimeSignature.h"
#import "MidiNote.h"
#import "BeatSignature.h"

int sortbynote(void* note1, void* note2);
int sortbytime(void* note1, void* note2);

@interface MidiTrack : NSObject <NSCopying> {
    int tracknum;          /** The track number */
    Array* notes;          /** Array of Midi notes */
    int instrument;        /** Instrument for this track */
    Array* lyrics;         /** The lyrics in this track */
    /** add by sunlie start */
    Array* splitednotes;
    Array* controlList;
    Array* controlList2;
    Array* controlList3;
    Array* controlList4;
    Array* controlList5;
    Array* controlList6;
    Array* controlList7;
    Array* controlList8;
    Array* controlList9;
    Array* controlList10;
    Array* controlList11;
    Array* controlList12;
    Array* controlList13;
    Array* controlList14;
    Array* controlList15;
    int totalpulses;
    /** add by sunlie end */
}
-(id)initWithTrack:(int)tracknum;
-(id)initWithEvents:(Array*)events andTrack:(int)tracknum;
-(void)dealloc;
-(int)number;
-(void)setNumber:(int)value;
-(Array*)notes;
-(NSString*)instrumentName;
-(int)instrument;
-(void)setInstrument:(int)value;
-(Array*)lyrics;
-(void)setLyrics:(Array*)value;
/** add by sunlie start */
-(Array*)controlList;
-(void)setControlList:(Array*)cl;
-(Array*)controlList2;
-(void)setControlList2:(Array*)cl2;
-(Array*)controlList3;
-(void)setControlList3:(Array*)cl3;
-(Array*)controlList4;
-(void)setControlList4:(Array*)cl4;
-(Array*)controlList5;
-(void)setControlList5:(Array*)cl5;
-(Array*)controlList6;
-(void)setControlList6:(Array*)cl6;
-(Array*)controlList7;
-(void)setControlList7:(Array*)cl7;
-(Array*)controlList8;
-(void)setControlList8:(Array*)cl8;
-(Array*)controlList9;
-(void)setControlList9:(Array*)cl9;
-(Array*)controlList10;
-(void)setControlList10:(Array*)cl10;
-(Array*)controlList11;
-(void)setControlList11:(Array*)cl11;
-(Array*)controlList12;
-(void)setControlList12:(Array*)cl12;
-(Array*)controlList13;
-(void)setControlList13:(Array*)cl13;
-(Array*)controlList14;
-(void)setControlList14:(Array*)cl14;
-(Array*)controlList15;
-(void)setControlList15:(Array*)cl15;
-(int)totalpulses;
-(void)setTotalpulses:(int)t;
-(Array*)splitednotes;
-(void)setSplitedNote:(int)num andNote:(MidiNote *)note;
-(void)AddSplitednote:(MidiNote *)m;
-(void)createSplitednotes:(TimeSignature *)time andBeatarray:(Array *)beatarray;
-(void)splitedNote:(MidiNote *)note andTimeSignature:(TimeSignature *)time;
-(void)createControlNotes:(TimeSignature *)time;
/** add by sunlie end */
-(NSString*)description;
-(void)addNote:(MidiNote *)m;
-(void)noteOffWithChannel:(int)channel andNumber:(int)num andTime:(int)endtime;
-(id)copyWithZone:(NSZone *)zone;

@end

