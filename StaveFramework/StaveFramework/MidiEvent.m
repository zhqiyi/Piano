/*
 * Copyright (c) 2007-2012 Madhav Vaidyanathan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */

#import "MidiEvent.h"
#import "MidiFile.h"
#import <Foundation/NSAutoreleasePool.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <assert.h>
#include <stdio.h>
#include <sys/stat.h>
#include <math.h>

/** Compare two MidiEvents based on their start times. 
 *  Used by the C mergesort function.
 */
int sortMidiEvent(void* v1, void* v2) {
    MidiEvent **ev1 = (MidiEvent**)v1;
    MidiEvent **ev2 = (MidiEvent**)v2;
    MidiEvent *event1 = *ev1;
    MidiEvent *event2 = *ev2;

    if ([event1 startTime] == [event2 startTime]) {
        return [event1 eventFlag] - [event2 eventFlag];
    }
    else {
        return [event1 startTime] - [event2 startTime];
    }
}


/** @class MidiEvent
 * A MidiEvent represents a single event (such as EventNoteOn) in the
 * Midi file. It includes the delta time of the event.
 */
@implementation MidiEvent

/** Initialize all the MidiEvent fields to 0 */
- (id)init {
    deltaTime = 0;
    startTime = 0;
    hasEventflag = 0;
    eventFlag = 0;
    channel = 0;
    notenumber = 0;
    velocity = 0;
    instrument = 0;
    keyPressure = 0;
    chanPressure = 0;
    controlNum = 0;
    controlValue = 0;
    pitchBend = 0;
    numerator = 0;
    denominator = 0;
    tempo = 0;
    metaevent = 0;
    metalength = 0;
    metavalue = NULL;
    return self;
}


/* See MidiFile.h for a description of each field */
- (int)deltaTime { return deltaTime; }
- (int)startTime { return startTime; }
- (bool)hasEventflag { return hasEventflag; }
- (u_char)eventFlag { return eventFlag; }
- (u_char)channel { return channel; }
- (u_char)notenumber { return notenumber; }
- (u_char)velocity { return velocity; }
- (u_char)instrument { return instrument; }
- (u_char)keyPressure { return keyPressure; }
- (u_char)chanPressure { return chanPressure; }
- (u_char)controlNum { return controlNum; }
- (u_char)controlValue { return controlValue; }
- (u_short)pitchBend { return pitchBend; }
- (int)numerator { return numerator; }
- (int)denominator { return denominator; }
- (int)tempo { return tempo; }
- (u_char)metaevent { return metaevent; }
- (int)metalength { return metalength; }
- (u_char*)metavalue { return metavalue; }

- (void)setDeltaTime:(int)value { deltaTime = value; }
- (void)setStartTime:(int)value { startTime = value; }
- (void)setHasEventflag:(bool)value { hasEventflag = value; }
- (void)setEventFlag:(u_char)value { eventFlag = value; }
- (void)setChannel:(u_char)value { channel = value; }
- (void)setNotenumber:(u_char)value { notenumber = value; }
- (void)setVelocity:(u_char)value { velocity = value; }
- (void)setInstrument:(u_char)value { instrument = value; }
- (void)setKeyPressure:(u_char)value { keyPressure = value; }
- (void)setChanPressure:(u_char)value { chanPressure = value; }
- (void)setControlNum:(u_char)value { controlNum = value; }
- (void)setControlValue:(u_char)value { controlValue = value; }
- (void)setPitchBend:(u_short)value { pitchBend = value; }
- (void)setNumerator:(int)value { numerator = (u_char)value; }
- (void)setDenominator:(int)value { denominator = (u_char)value; }
- (void)setTempo:(int)value { tempo = value; }
- (void)setMetaevent:(u_char)value { metaevent = value; }
- (void)setMetalength:(int)value { metalength = value; }
- (void)setMetavalue:(u_char*)value { metavalue = value; /*NSLog(@"metavalue is %@", [NSString stringWithUTF8String:metavalue]);*/}

- (id)copyWithZone:(NSZone*)zone {
    MidiEvent *mevent = [[MidiEvent alloc] init];
    [mevent setDeltaTime:deltaTime];
    [mevent setStartTime:startTime];
    [mevent setHasEventflag:hasEventflag];
    [mevent setEventFlag:eventFlag];
    [mevent setChannel:channel];
    [mevent setNotenumber:notenumber];
    [mevent setVelocity:velocity];
    [mevent setInstrument:instrument];
    [mevent setKeyPressure:keyPressure];
    [mevent setChanPressure:chanPressure];
    [mevent setControlNum:controlNum];
    [mevent setControlValue:controlValue];
    [mevent setPitchBend:pitchBend];
    [mevent setNumerator:numerator];
    [mevent setDenominator:denominator];
    [mevent setTempo:tempo];
    [mevent setMetaevent:metaevent];
    [mevent setMetalength:metalength];
    [mevent setMetavalue:metavalue];
    return mevent;
}

- (void)dealloc {
    if (eventFlag == MetaEvent || eventFlag == SysexEvent1 ||
        eventFlag == SysexEvent2) {
        /* free(metavalue); */
        metavalue = NULL;
    }
    [super dealloc];
}

@end

