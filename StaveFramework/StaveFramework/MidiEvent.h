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

int sortMidiEvent(void* v1, void* v2);

@interface MidiEvent : NSObject <NSCopying> {
    int     deltaTime;     /** The time between the previous event and this on */
    int     startTime;     /** The absolute time this event occurs */
    bool    hasEventflag;  /** False if this is using the previous eventflag */
    u_char  eventFlag;     /** NoteOn, NoteOff, etc.  Full list is in class MidiFile */
    u_char  channel;       /** The channel this event occurs on */

    u_char  notenumber;    /** The note number  */
    u_char  velocity;      /** The volume of the note */
    u_char  instrument;    /** The instrument */
    u_char  keyPressure;   /** The key pressure */
    u_char  chanPressure;  /** The channel pressure */
    u_char  controlNum;    /** The controller number */
    u_char  controlValue;  /** The controller value */
    u_short pitchBend;     /** The pitch bend value */
    u_char  numerator;     /** The numerator, for TimeSignature meta events */
    u_char  denominator;   /** The denominator, for TimeSignature meta events */
    int     tempo;         /** The tempo, for Tempo meta events */
    u_char  metaevent;     /** The metaevent, used if eventflag is MetaEvent */
    int     metalength;    /** The metaevent length  */
    u_char* metavalue;     /** The raw byte value, for Sysex and meta events */
}

-(id)init;
-(int)deltaTime;
-(int)startTime;
-(bool)hasEventflag;
-(u_char)eventFlag;
-(u_char)channel;
-(u_char)notenumber;
-(u_char)velocity;
-(u_char)instrument;
-(u_char)keyPressure;
-(u_char)chanPressure;
-(u_char)controlNum;
-(u_char)controlValue;
-(u_short)pitchBend;
-(int)numerator;
-(int)denominator;
-(int)tempo;
-(u_char)metaevent;
-(int)metalength;
-(u_char*)metavalue;


-(void)setDeltaTime:(int) value;
-(void)setStartTime:(int) value;
-(void)setHasEventflag:(bool) value;
-(void)setEventFlag:(u_char) value;
-(void)setChannel:(u_char) value;
-(void)setNotenumber:(u_char) value;
-(void)setVelocity:(u_char) value;
-(void)setInstrument:(u_char) value;
-(void)setKeyPressure:(u_char) value;
-(void)setChanPressure:(u_char) value;
-(void)setControlNum:(u_char) value;
-(void)setControlValue:(u_char) value;
-(void)setPitchBend:(u_short) value;
-(void)setNumerator:(int) value;
-(void)setDenominator:(int) value;
-(void)setTempo:(int) value;
-(void)setMetaevent:(u_char) value;
-(void)setMetalength:(int) value;
-(void)setMetavalue:(u_char*) value;

-(id)copyWithZone:(NSZone*)zone;
-(void)dealloc;
@end


