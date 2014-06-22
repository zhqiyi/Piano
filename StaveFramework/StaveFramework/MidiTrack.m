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

#import "MidiFile.h"
#import "MidiTrack.h"
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

/** Compare two MidiNotes based on their start times.
 *  If the start times are equal, compare by their numbers.
 *  Used by the C mergesort function.
 */
int sortbytime(void* v1, void* v2) {
    MidiNote **m1 = (MidiNote**) v1;
    MidiNote **m2 = (MidiNote**) v2;
    MidiNote *note1 = *m1;
    MidiNote *note2 = *m2;
    
    if ([note1 startTime] == [note2 startTime]) {
        return [note1 number] - [note2 number];
    }
    else {
        return [note1 startTime] - [note2 startTime];
    }
}
/** add by sunlie start */
int sortbynote(void* note1, void* note2) {
    MidiNote **m1 = (MidiNote**) note1;
    MidiNote **m2 = (MidiNote**) note2;
    MidiNote *n1 = *m1;
    MidiNote *n2 = *m2;
    
    return [n1 number]-[n2 number];
}
/** add by sunlie end */

/** @class MidiTrack
 * The MidiTrack takes as input the raw MidiEvents for the track, and gets:
 * - The list of midi notes in the track.
 * - The first instrument used in the track.
 *
 * For each NoteOn event in the midi file, a new MidiNote is created
 * and added to the track, using the AddNote() method.
 *
 * The NoteOff() method is called when a NoteOff event is encountered,
 * in order to update the duration of the MidiNote.
 */
@implementation MidiTrack

/** Create an empty MidiTrack. Used by the copy method */
- (id)initWithTrack:(int)t {
    tracknum = t;
    notes = [Array new:20];
    /** add by sunlie start */
    controlList = [Array new:10];
    controlList2 = [Array new:20];
    controlList3 = [Array new:10];
    controlList4 = [Array new:10];
    controlList5 = [Array new:20];
    controlList6 = [Array new:20];
    controlList7 = [Array new:20];
    controlList8 = [Array new:20];
    controlList9 = [Array new:10];
    controlList10 = [Array new:10];
    controlList11 = [Array new:10];
    controlList12 = [Array new:10];
    controlList13 = [Array new:10];
    controlList14 = [Array new:10];
    controlList15 = [Array new:10];
    /** add by sunlie end */
    instrument = 0;
    return self;
}

/** Create a MidiTrack based on the Midi events.  Extract the NoteOn/NoteOff
 *  events to gather the list of MidiNotes.
 */
- (id)initWithEvents:(Array*)list andTrack:(int)num {
    tracknum = num;
    notes = [Array new:100];
    instrument = 0;
    /** add by sunlie start */
    controlList = [Array new:10];
    controlList2 = [Array new:20];
    controlList3 = [Array new:10];
    controlList4 = [Array new:10];
    controlList5 = [Array new:20];
    controlList6 = [Array new:20];
    controlList7 = [Array new:20];
    controlList8 = [Array new:20];
    controlList9 = [Array new:10];
    controlList10 = [Array new:10];
    controlList11 = [Array new:10];
    controlList12 = [Array new:10];
    controlList13 = [Array new:10];
    controlList14 = [Array new:10];
    controlList15 = [Array new:10];
    /** add by sunlie end */
    
    for (int i= 0;i < [list count]; i++) {
        MidiEvent *mevent = [list get:i];
        if ([mevent eventFlag] == EventNoteOn && [mevent velocity] > 0) {
            MidiNote *note = [[MidiNote alloc] init];
            [note setStarttime:[mevent startTime]];
            [note setChannel:[mevent channel]];
            [note setNumber:[mevent notenumber]];
            [self addNote:note];
            [note release];
        }
        else if ([mevent eventFlag] == EventNoteOn && [mevent velocity] == 0) {
            [self noteOffWithChannel:[mevent channel] andNumber:[mevent notenumber]
                             andTime:[mevent startTime] ];
        }
        else if ([mevent eventFlag] == EventNoteOff) {
            [self noteOffWithChannel:[mevent channel] andNumber:[mevent notenumber]
                             andTime:[mevent startTime] ];
        }
        else if ([mevent eventFlag] == EventProgramChange) {
            instrument = [mevent instrument];
        }
        else if ([mevent metaevent] == MetaEventLyric) {
            if (lyrics == nil) {
                lyrics = [Array new:5];
            }
            [lyrics add:mevent];
        }
    }
    if ([notes count] > 0 && [(MidiNote*)[notes get:0] channel] == 9) {
        instrument = 128;  /* Percussion */
    }

    return self;
}


- (void)dealloc {
    [notes release];
    [lyrics release];
    /** add by sunlie start */
    [controlList release];
    [controlList2 release];
    [controlList3 release];
    [controlList4 release];
    [controlList5 release];
    [controlList6 release];
    [controlList7 release];
    [controlList8 release];
    [controlList9 release];
    [controlList10 release];
    [controlList11 release];
    [controlList12 release];
    [controlList13 release];
    [controlList14 release];
    [controlList15 release];
    /** add by sunlie end */
    [super dealloc];
}

- (int)number {
    return tracknum;
}

- (void)setNumber:(int)value {
    tracknum = value;
}

- (Array*)notes {
    return notes;
}

- (NSString*)instrumentName {
    if (instrument >= 0 && instrument <= 128) {
        return [[MidiFile instrumentNames] objectAtIndex:instrument];
    }
    else {
        return @"";
    }
}


- (int)instrument {
    return instrument;
}

- (void)setInstrument:(int)value {
    instrument = value;
}

- (Array*)lyrics {
    return lyrics;
}

-(void)setLyrics:(Array*)value {
    [lyrics release];
    lyrics = [value retain];
}

/** add by sunlie start */
-(Array*)controlList {
    return controlList;
}

-(void)setControlList:(Array*)cl {
    for (int i = 0; i < [cl count]; i++) {
        ControlData *cd = [cl get:i];
        [controlList add:[cd copy]];
    }
}

-(Array*)controlList2 {
    return controlList2;
}

-(void)setControlList2:(Array*)cl {
    for (int i = 0; i < [cl count]; i++) {
        ControlData *cd = [cl get:i];
        [controlList2 add:[cd copy]];
    }
}

-(Array*)controlList3 {
    return controlList3;
}

-(void)setControlList3:(Array*)cl {
    for (int i = 0; i < [cl count]; i++) {
        ControlData *cd = [cl get:i];
        [controlList3 add:[cd copy]];
    }
}

-(Array*)controlList4 {
    return controlList4;
}

-(void)setControlList4:(Array*)cl {
    for (int i = 0; i < [cl count]; i++) {
        ControlData *cd = [cl get:i];
        [controlList4 add:[cd copy]];
    }
}

-(Array*)controlList5 {
    return controlList5;
}

-(void)setControlList5:(Array*)cl {
    for (int i = 0; i < [cl count]; i++) {
        ControlData *cd = [cl get:i];
        [controlList5 add:[cd copy]];
    }
}

-(Array*)controlList6 {
    return controlList6;
}

-(void)setControlList6:(Array*)cl {
    for (int i = 0; i < [cl count]; i++) {
        ControlData *cd = [cl get:i];
        [controlList6 add:[cd copy]];
    }
}

-(Array*)controlList7 {
    return controlList7;
}

-(void)setControlList7:(Array*)cl {
    for (int i = 0; i < [cl count]; i++) {
        ControlData *cd = [cl get:i];
        [controlList7 add:[cd copy]];
    }
}

-(Array*)controlList8 {
    return controlList8;
}

-(void)setControlList8:(Array*)cl {
    for (int i = 0; i < [cl count]; i++) {
        ControlData *cd = [cl get:i];
        [controlList8 add:[cd copy]];
    }
}

-(Array*)controlList9 {
    return controlList9;
}

-(void)setControlList9:(Array*)cl {
    for (int i = 0; i < [cl count]; i++) {
        ControlData *cd = [cl get:i];
        [controlList9 add:[cd copy]];
    }
}

-(Array*)controlList10 {
    return controlList10;
}

-(void)setControlList10:(Array*)cl {
    for (int i = 0; i < [cl count]; i++) {
        ControlData *cd = [cl get:i];
        [controlList10 add:[cd copy]];
    }
}

-(Array*)controlList11 {
    return controlList11;
}

-(void)setControlList11:(Array*)cl {
    for (int i = 0; i < [cl count]; i++) {
        ControlData *cd = [cl get:i];
        [controlList11 add:[cd copy]];
    }
}

-(Array*)controlList12 {
    return controlList12;
}

-(void)setControlList12:(Array*)cl {
    for (int i = 0; i < [cl count]; i++) {
        ControlData *cd = [cl get:i];
        [controlList12 add:[cd copy]];
    }
}

-(Array*)controlList13 {
    return controlList13;
}

-(void)setControlList13:(Array*)cl {
    for (int i = 0; i < [cl count]; i++) {
        ControlData *cd = [cl get:i];
        [controlList13 add:[cd copy]];
    }
}

-(Array*)controlList14 {
    return controlList14;
}

-(void)setControlList14:(Array*)cl {
    for (int i = 0; i < [cl count]; i++) {
        ControlData *cd = [cl get:i];
        [controlList14 add:[cd copy]];
    }
}

-(Array*)controlList15 {
    return controlList15;
}

-(void)setControlList15:(Array*)cl {
    for (int i = 0; i < [cl count]; i++) {
        ControlData *cd = [cl get:i];
        [controlList15 add:[cd copy]];
    }
}
-(int)totalpulses {
    return totalpulses;
}

-(void)setTotalpulses:(int)t {
    totalpulses = t;
}

-(Array*)splitednotes {
    return splitednotes;
}

-(void)AddSplitednote:(MidiNote *)m {
    [splitednotes add:m];
}
/** add by sunlie end */

/** Add a MidiNote to this track.  This is called for each NoteOn event */
- (void)addNote:(MidiNote*)m {
    [notes add:m];
}

/** A NoteOff event occured.  Find the MidiNote of the corresponding
 * NoteOn event, and update the duration of the MidiNote.
 */
- (void)noteOffWithChannel:(int)channel andNumber:(int)number andTime:(int)endtime {
    for (int i = [notes count]-1; i >= 0; i--) {
        MidiNote* note = [notes get:i];
        if ([note channel] == channel && [note number] == number &&
            [note duration] == 0) {
            [note noteOff:endtime];
            return;
        }
    }
}

/** Return a deep copy clone of this MidiTrack */
- (id)copyWithZone:(NSZone*)zone {
    MidiTrack *track = [[MidiTrack alloc] initWithTrack:tracknum];
    [track setInstrument:instrument];
    for (int i = 0; i < [notes count]; i++) {
        MidiNote *note = [notes get:i];
        MidiNote *notecopy = [note copy];
        [[track notes] add:notecopy ];
        [notecopy release];
    }
    if (lyrics != nil) {
        Array *newlyrics = [Array new:[lyrics count]];
        for (int i = 0; i < [lyrics count]; i++) {
            MidiEvent *ev = [lyrics get:i];
            [newlyrics add:ev];
        }
        [track setLyrics:newlyrics];
        [newlyrics release];
    }
    
    /** add by sunlie start */
    [track setTotalpulses: totalpulses];
    if ([controlList count] > 0) {
        for (int i = 0; i < [controlList count]; i++) {
            ControlData *cd = [controlList get:i];
            [[track controlList] add:[cd copy]];
        }
    }
    
    if ([controlList2 count] > 0) {
        for (int i = 0; i < [controlList2 count]; i++) {
            ControlData *cd = [controlList2 get:i];
            [[track controlList2] add:[cd copy]];
        }
    }
    
    if ([controlList3 count] > 0) {
        for (int i = 0; i < [controlList3 count]; i++) {
            ControlData *cd = [controlList3 get:i];
            [[track controlList3] add:[cd copy]];
        }
    }
    
    if ([controlList4 count] > 0) {
        for (int i = 0; i < [controlList4 count]; i++) {
            ControlData *cd = [controlList4 get:i];
            [[track controlList4] add:[cd copy]];
        }
    }
    
    if ([controlList5 count] > 0) {
        for (int i = 0; i < [controlList5 count]; i++) {
            ControlData *cd = [controlList5 get:i];
            [[track controlList5] add:[cd copy]];
        }
    }
    
    if ([controlList6 count] > 0) {
        for (int i = 0; i < [controlList6 count]; i++) {
            ControlData *cd = [controlList6 get:i];
            [[track controlList6] add:[cd copy]];
        }
    }
    
    if ([controlList7 count] > 0) {
        for (int i = 0; i < [controlList7 count]; i++) {
            ControlData *cd = [controlList7 get:i];
            [[track controlList7] add:[cd copy]];
        }
    }
    
    if ([controlList8 count] > 0) {
        for (int i = 0; i < [controlList8 count]; i++) {
            ControlData *cd = [controlList8 get:i];
            [[track controlList8] add:[cd copy]];
        }
    }
    if ([controlList9 count] > 0) {
        for (int i = 0; i < [controlList9 count]; i++) {
            ControlData *cd = [controlList9 get:i];
            [[track controlList9] add:[cd copy]];
        }
    }
    
    if ([controlList10 count] > 0) {
        for (int i = 0; i < [controlList10 count]; i++) {
            ControlData *cd = [controlList10 get:i];
            [[track controlList10] add:[cd copy]];
        }
    }
    if ([controlList11 count] > 0) {
        for (int i = 0; i < [controlList11 count]; i++) {
            ControlData *cd = [controlList11 get:i];
            [[track controlList11] add:[cd copy]];
        }
    }
    if ([controlList12 count] > 0) {
        for (int i = 0; i < [controlList12 count]; i++) {
            ControlData *cd = [controlList12 get:i];
            [[track controlList12] add:[cd copy]];
        }
    }
    if ([controlList13 count] > 0) {
        for (int i = 0; i < [controlList13 count]; i++) {
            ControlData *cd = [controlList13 get:i];
            [[track controlList13] add:[cd copy]];
        }
    }
    if ([controlList14 count] > 0) {
        for (int i = 0; i < [controlList14 count]; i++) {
            ControlData *cd = [controlList14 get:i];
            [[track controlList14] add:[cd copy]];
        }
    }
    if ([controlList15 count] > 0) {
        for (int i = 0; i < [controlList15 count]; i++) {
            ControlData *cd = [controlList15 get:i];
            [[track controlList15] add:[cd copy]];
        }
    }
    /** add by sunlie end */
    
    return track;
}

/** add by sunlie start */
-(void)setSplitedNote:(int)num andNote:(MidiNote *)note {
    MidiNote *mn;
    if ([splitednotes count] > num) {
        mn = [splitednotes get:[splitednotes count]-1];
        [note setPrevious:1];
        [mn setNext:1];
    }
    [self AddSplitednote:note];
    return;
}

-(void)createSplitednotes:(TimeSignature *)time andBeatarray:(Array *)beatarray {
    splitednotes = [Array new:500];
    int startTime;
    int endTime;
    int duration;
    int beginnum;
    int size = [beatarray count];
    int i = 1;
    int beatstarttime = 0;
    int interval = [time quarter]/16;
    BeatSignature *beat;
    Array *tmpnotes = [Array new:20];
    int j;
    
    if (size > 1) {
        beat = [beatarray get:i];
        beatstarttime = [beat starttime];
    }
    
    for (j = 0; j<[notes count]; j++) {
        MidiNote *note = [notes get:j];
        startTime = [note startTime];
        duration = [note duration];
        endTime = startTime + duration;
        [tmpnotes clear];
        
        if (beatstarttime != 0 && startTime >= beatstarttime) {
            [time setNumerator:[beat numerator]];
            [time setDenominator:[beat denominator]];
            [time setMeasure];
            i++;
            if (i < size) {
                beat = [beatarray get:i];
                beatstarttime = [beat starttime];
            } else {
                beatstarttime = 0;
            }
        }
        
        beginnum = [splitednotes count];
        
        if ((startTime+interval)/[time measure] != startTime/[time measure]) {
            startTime += interval;
            [note setDuration:[note duration]-interval];
            [note setStarttime:startTime];
        }
        
        if (startTime/[time measure] < (endTime-interval)/[time measure]) {
            do {
                MidiNote *newnote = [[MidiNote alloc]init];
                [newnote setStarttime:startTime];
                [newnote setChannel:[note channel]];
                [newnote setNumber:[note number]];
                [newnote setDuration:[time measure]-startTime%[time measure]];
                
                if ([tmpnotes count] > 0) {
                    MidiNote *tmpNote;
                    tmpNote = [tmpnotes get:[tmpnotes count]-1];
                    [newnote setPrevious:1];
                    [tmpNote setNext:1];
                }
                [tmpnotes add:newnote];
                startTime = [newnote startTime] + [newnote duration];
            } while (startTime/[time measure] < (endTime-interval)/[time measure]);
            
            if (startTime/[time measure] == (endTime-interval)/[time measure]) {
                if ((endTime-startTime) > interval) {
                    MidiNote *newnote = [[MidiNote alloc]init];
                    [newnote setStarttime:startTime];
                    [newnote setChannel:[note channel]];
                    [newnote setNumber:[note number]];
                    [newnote setDuration:endTime-startTime];
                    
                    if ([tmpnotes count] > 0) {
                        MidiNote *tmpNote;
                        tmpNote = [tmpnotes get:[tmpnotes count]-1];
                        [newnote setPrevious:1];
                        [tmpNote setNext:1];
                    }
                    [tmpnotes add:newnote];
                }
            }
        }
        
        if ([tmpnotes count] == 0) {
            [self splitedNote:note andTimeSignature:time];
        } else {
            int k = [tmpnotes count];
            if (k == 1) {
                [self splitedNote:[tmpnotes get:0] andTimeSignature:time];
            } else {
                for (k = 0; k < [tmpnotes count]-1; k++) {
                    [self splitedNote:[tmpnotes get:k] andTimeSignature:time];
                    [[splitednotes get:[splitednotes count]-1] setNext:1];
                }
                [self splitedNote:[tmpnotes get:k] andTimeSignature:time];
            }
        }
    }
    
    [splitednotes sort:sortbytime];
    [tmpnotes release];
    return;
}

-(void)splitedNote:(MidiNote *)note andTimeSignature:(TimeSignature *)time {
    MidiNote *n;
    int dur = 0;
    int beginnum = [splitednotes count];
    Array *midiNotes = [Array new:10];
    int err1 = 0;
    int err2 = 0;
    
    n = [note copy];
    if([n duration]%([time quarter]/8) <= ([time quarter]/8 - [n duration]%([time quarter]/8))) {
        err1 = [n duration]%([time quarter]/8);
    } else {
        err1 = [time quarter]/8 - [n duration]%([time quarter]/8);
    }
    
    if([n duration]%([time quarter]/6) <= ([time quarter]/6 - [n duration]%([time quarter]/6))) {
        err2 = [n duration]%([time quarter]/6);
    } else {
        err2 = [time quarter]/6 - [n duration]%([time quarter]/6);
    }
    
    if (err1 <= err2 || err1 < 20) {
        if ([n duration]%([time quarter]/8) > [time quarter]/16) {
            dur = ([n duration]/([time quarter]/8) + 1)*([time quarter]/8);
        } else {
            dur = ([n duration]/([time quarter]/8))*([time quarter]/8);
        }
    } else {
        if ([n duration]%([time quarter]/6) > [time quarter]/12) {
            dur = ([n duration]/([time quarter]/6) + 1)*([time quarter]/6);
        } else {
            dur = ([n duration]/([time quarter]/6))*([time quarter]/6);
        }
    }
    [n setDuration:dur];
    
    while (YES) {
        MidiNote *tmpnote;
        
        if ([n duration]%[time quarter]==0 || abs([n duration]%[time quarter]-[time quarter]) <= [time quarter]/8) {
            [self setSplitedNote:beginnum andNote:n];
            if ([midiNotes count] > 0) {
                int k = 0;
                for (k = [midiNotes count]-1; k>=0; k--) {
                    MidiNote *m = [midiNotes get:k];
                    [self setSplitedNote:beginnum andNote:m];
                }
            }
            break;
        }
        /** add by sunlie start */
        else if ([n duration]*1.0/[time quarter] > 1.5 && [n startTime]%[time quarter] <= [time quarter]/8) {
            tmpnote = [[MidiNote alloc] init];
            [tmpnote setStarttime:[n startTime]];
            [tmpnote setChannel:[n channel]];
            [tmpnote setNumber:[n number]];
            [tmpnote setDuration:[n duration]-[n duration]%[time quarter]];
            [n setStarttime:[n startTime]+[tmpnote duration]];
            [n setDuration:[n duration]-[tmpnote duration]];
            [self setSplitedNote:beginnum andNote:tmpnote];
            [tmpnote release];
        }
        /** add by sunlie end */
        else if (([n duration]%([time quarter]/2) <= [time quarter]/8) ||
                   ([n duration]%([time quarter]/3) <= [time quarter]/8)) {
            
            if ([n duration]/[time quarter] > 0) {
                
                if (([n duration]%([time quarter]/2) <= [time quarter]/8)
                    &&(abs([n duration] - 1.5 * [time quarter]) <= [time quarter]/8)) {
                    [self setSplitedNote:beginnum andNote:n];
                    if ([midiNotes count] > 0) {
                        int k = 0;
                        for (k = [midiNotes count]-1; k>=0; k--) {
                            MidiNote *m = [midiNotes get:k];
                            [self setSplitedNote:beginnum andNote:m];
                        }
                    }
                    break;
                }
                
                if ([n startTime]%[time quarter] <= [time quarter]/8) {
                    tmpnote = [[MidiNote alloc] init];
                    [tmpnote setStarttime:[n endTime]-[n duration]%[time quarter]];
                    [tmpnote setChannel:[n channel]];
                    [tmpnote setNumber:[n number]];
                    [tmpnote setDuration:[n duration]%[time quarter]];
                    [n setDuration:[n duration]-[tmpnote duration]];
                    [midiNotes add:tmpnote];
                    [tmpnote release];
                } else if (([n startTime]%([time quarter]/2) <= [time quarter]/8) ||
                           ([n startTime]%([time quarter]/3) <= [time quarter]/8)) {
                    tmpnote = [[MidiNote alloc] init];
                    [tmpnote setStarttime:[n startTime]];
                    [tmpnote setChannel:[n channel]];
                    [tmpnote setNumber:[n number]];
                    [tmpnote setDuration:[n duration]%[time quarter]];
                    [n setDuration:[n duration]-[tmpnote duration]];
                    [n setStarttime:[n startTime]+[tmpnote duration]];
                    [self setSplitedNote:beginnum andNote:tmpnote];
                    if ([midiNotes count] > 0) {
                        int k = 0;
                        for (k = [midiNotes count]-1; k>=0; k--) {
                            MidiNote *m = [midiNotes get:k];
                            [self setSplitedNote:beginnum andNote:m];
                        }
                    }
                    [tmpnote release];
                } else if (([n duration]%([time quarter]/2) <= [time quarter]/8) ||
                           ([n duration]%([time quarter]/3) <= [time quarter]/8)) {
                    tmpnote = [[MidiNote alloc] init];
                    [tmpnote setStarttime:[n startTime]];
                    [tmpnote setChannel:[n channel]];
                    [tmpnote setNumber:[n number]];
                    [tmpnote setDuration:[n duration]%([time quarter]/2)];
                    [self setSplitedNote:beginnum andNote:tmpnote];
                    
                    MidiNote *noteadd = [[MidiNote alloc] init];
                    [noteadd setStarttime:[n startTime]+[tmpnote duration]];
                    [noteadd setChannel:[n channel]];
                    [noteadd setNumber:[n number]];
                    [noteadd setDuration:[n duration]%([time quarter]/2)];
                    [self setSplitedNote:beginnum andNote:noteadd];
                    
                    [n setDuration:[n duration]-[tmpnote duration]];
                    [n setStarttime:[n startTime]+[tmpnote duration]];
                    if ([midiNotes count] > 0) {
                        int k = 0;
                        for (k = [midiNotes count]-1; k>=0; k--) {
                            MidiNote *m = [midiNotes get:k];
                            [self setSplitedNote:beginnum andNote:m];
                        }
                    }
                    [tmpnote release];
                    [noteadd release];
                    
                } else {
                    [self setSplitedNote:beginnum andNote:n];
                    if ([midiNotes count] > 0) {
                        int k = 0;
                        for (k = [midiNotes count]-1; k>=0; k--) {
                            MidiNote *m = [midiNotes get:k];
                            [self setSplitedNote:beginnum andNote:m];
                        }
                    }
                    break;
                }
                
            } else {
                [self setSplitedNote:beginnum andNote:n];
                if ([midiNotes count] > 0) {
                    int k = 0;
                    for (k = [midiNotes count]-1; k>=0; k--) {
                        MidiNote *m = [midiNotes get:k];
                        [self setSplitedNote:beginnum andNote:m];
                    }
                }
                break;
            }
        } else if (([n duration]%([time quarter]/4) <= [time quarter]/8) ||
                   ([n duration]%([time quarter]/6) <= [time quarter]/8)) {
            if ((([n duration]*2)/[time quarter] > 0) || (([n duration]*3)/[time quarter] > 0)) {
                if (([n duration]%([time quarter]/4) <= [time quarter]/8)
                    &&(abs([n duration] - 1.5 * ([time quarter]/2)) <= [time quarter]/8)) {
                    [self setSplitedNote:beginnum andNote:n];
                    if ([midiNotes count] > 0) {
                        int k = 0;
                        for (k = [midiNotes count]-1; k>=0; k--) {
                            MidiNote *m = [midiNotes get:k];
                            [self setSplitedNote:beginnum andNote:m];
                        }
                    }
                    break;
                }
                
                if (([n startTime]%([time quarter]/2) <= [time quarter]/8) ||
                    ([n startTime]%([time quarter]/3) <= [time quarter]/8)) {
                    if ([n duration]%([time quarter]/4) <= [time quarter]/8) {
                        tmpnote = [[MidiNote alloc] init];
                        [tmpnote setStarttime:[n endTime]-[n duration]%([time quarter]/2)];
                        [tmpnote setChannel:[n channel]];
                        [tmpnote setNumber:[n number]];
                        [tmpnote setDuration:[n duration]%([time quarter]/2)];
                        [n setDuration:[n duration]-[tmpnote duration]];
                        [midiNotes add:tmpnote];
                        [tmpnote release];
                    } else {
                        tmpnote = [[MidiNote alloc] init];
                        [tmpnote setStarttime:[n endTime]-[n duration]%([time quarter]/3)];
                        [tmpnote setChannel:[n channel]];
                        [tmpnote setNumber:[n number]];
                        [tmpnote setDuration:[n duration]%([time quarter]/3)];
                        [n setDuration:[n duration]-[tmpnote duration]];
                        [midiNotes add:tmpnote];
                        [tmpnote release];
                    }
                } else {
                    if ([n duration]%([time quarter]/4) <= [time quarter]/8) {
                        tmpnote = [[MidiNote alloc] init];
                        [tmpnote setStarttime:[n startTime]];
                        [tmpnote setChannel:[n channel]];
                        [tmpnote setNumber:[n number]];
                        [tmpnote setDuration:[n duration]%([time quarter]/2)];
                        [n setDuration:[n duration]-[tmpnote duration]];
                        [n setStarttime:[n startTime]+[tmpnote duration]];
                        [self setSplitedNote:beginnum andNote:tmpnote];
                        if ([midiNotes count] > 0) {
                            int k = 0;
                            for (k = [midiNotes count]-1; k>=0; k--) {
                                MidiNote *m = [midiNotes get:k];
                                [self setSplitedNote:beginnum andNote:m];
                            }
                        }
                        [tmpnote release];
                    } else {
                        tmpnote = [[MidiNote alloc] init];
                        [tmpnote setStarttime:[n startTime]];
                        [tmpnote setChannel:[n channel]];
                        [tmpnote setNumber:[n number]];
                        [tmpnote setDuration:[n duration]%([time quarter]/3)];
                        [n setDuration:[n duration]-[tmpnote duration]];
                        [n setStarttime:[n startTime]+[tmpnote duration]];
                        [self setSplitedNote:beginnum andNote:tmpnote];
                        if ([midiNotes count] > 0) {
                            int k = 0;
                            for (k = [midiNotes count]-1; k>=0; k--) {
                                MidiNote *m = [midiNotes get:k];
                                [self setSplitedNote:beginnum andNote:m];
                            }
                        }
                        [tmpnote release];
                    }
                }
            } else {
                [self setSplitedNote:beginnum andNote:n];
                if ([midiNotes count] > 0) {
                    int k = 0;
                    for (k = [midiNotes count]-1; k>=0; k--) {
                        MidiNote *m = [midiNotes get:k];
                        [self setSplitedNote:beginnum andNote:m];
                    }
                }
                break;
            }
        } else if (([n duration]%([time quarter]/8) <= [time quarter]/8) ||
                   ([n duration]%([time quarter]/12) <= [time quarter]/8)) {
            if ((([n duration]*4)/[time quarter] > 0) || (([n duration]*6)/[time quarter] > 0)) {
                if (([n duration]%([time quarter]/8) <= [time quarter]/8)
                    &&(abs([n duration] - 1.5 * ([time quarter]/4)) <= [time quarter]/8)) {
                    [self setSplitedNote:beginnum andNote:n];
                    if ([midiNotes count] > 0) {
                        int k = 0;
                        for (k = [midiNotes count]-1; k>=0; k--) {
                            MidiNote *m = [midiNotes get:k];
                            [self setSplitedNote:beginnum andNote:m];
                        }
                    }
                    break;
                }
                
                if ((([n duration]*4)/[time quarter] > 0) || (([n duration]*6)/[time quarter] > 0)) {
                    if ([n duration]%([time quarter]/8) <= [time quarter]/8) {
                        tmpnote = [[MidiNote alloc] init];
                        [tmpnote setStarttime:[n endTime]-[n duration]%([time quarter]/4)];
                        [tmpnote setChannel:[n channel]];
                        [tmpnote setNumber:[n number]];
                        [tmpnote setDuration:[n duration]%([time quarter]/4)];
                        [n setDuration:[n duration]-[tmpnote duration]];
                        [midiNotes add:tmpnote];
                        [tmpnote release];
                    } else {
                        tmpnote = [[MidiNote alloc] init];
                        [tmpnote setStarttime:[n endTime]-[n duration]%([time quarter]/6)];
                        [tmpnote setChannel:[n channel]];
                        [tmpnote setNumber:[n number]];
                        [tmpnote setDuration:[n duration]%([time quarter]/6)];
                        [n setDuration:[n duration]-[tmpnote duration]];
                        [midiNotes add:tmpnote];
                        [tmpnote release];
                    }
                } else {
                    if ([n duration]%([time quarter]/8) <= [time quarter]/8) {
                        tmpnote = [[MidiNote alloc] init];
                        [tmpnote setStarttime:[n startTime]];
                        [tmpnote setChannel:[n channel]];
                        [tmpnote setNumber:[n number]];
                        [tmpnote setDuration:[n duration]%([time quarter]/4)];
                        [n setDuration:[n duration]-[tmpnote duration]];
                        [n setStarttime:[n startTime] + [tmpnote duration]];
                        [self setSplitedNote:beginnum andNote:tmpnote];
                        [tmpnote release];
                    } else {
                        tmpnote = [[MidiNote alloc] init];
                        [tmpnote setStarttime:[n startTime]];
                        [tmpnote setChannel:[n channel]];
                        [tmpnote setNumber:[n number]];
                        [tmpnote setDuration:[n duration]%([time quarter]/6)];
                        [n setDuration:[n duration]-[tmpnote duration]];
                        [n setStarttime:[n startTime] + [tmpnote duration]];
                        [self setSplitedNote:beginnum andNote:tmpnote];
                        [tmpnote release];
                    }
                }
            } else {
                [self setSplitedNote:beginnum andNote:n];
                break;
            }
        }
    }
    [n release];
    [midiNotes release];
    return;
}

-(void)createControlNotes:(TimeSignature *)time {
    int flag6 = -1;
    int flag11 = -1;
    int flag12 = -1;
    int flag13 = -1;
    int cdcount6 = 0;
    int cdcount11 = 0;
    int cdcount12 = 0;
    int cdcount13 = 0;
    ControlData *cd6,*cd11,*cd12,*cd13;
    int i = 0;
    
    
    if (cdcount6 < [controlList6 count]) {
        cd6 = [controlList6 get:cdcount6];
    }
    if (cdcount11 < [controlList11 count]) {
        cd11 = [controlList11 get:cdcount11];
    }
    if (cdcount12 < [controlList12 count]) {
        cd12 = [controlList12 get:cdcount12];
    }
    if (cdcount13 < [controlList13 count]) {
        cd13 = [controlList13 get:cdcount13];
    }
    
    while (i < [notes count]) {
        if (cdcount6 < [controlList6 count]) {
            MidiNote* note = [notes get:i];
            if ([note startTime] > [cd6 endtime] && flag6 > 0) {
                for (int j = flag6; j < i-1; j++) {
                    MidiNote* mn = [notes get:j];
                    MidiNote* mn1 = [notes get:i-1];
                    [mn setStarttime:[mn1 startTime]];
                    [mn setDuration:[mn1 duration]];
                    [mn setPaflag:1];
                }
                flag6 = -1;
                cdcount6++;
                if (cdcount6 < [controlList6 count]) {
                    cd6 = [controlList6 get:cdcount6];
                }
            }
            
            if ([note startTime] > [cd6 starttime] && flag6 == -1) {
                flag6 = i;
            }
        }
        
        if (cdcount11 < [controlList11 count]) {
            MidiNote* note = [notes get:i];
            if ([note startTime] >= [cd11 starttime] && flag11 < 0) {
                flag11 = [note startTime];
                [notes remove:note];
                i--;
            } else if ([note startTime] < [cd11 endtime] && [note endTime] >= [cd11 endtime]) {
                [note setDuration:[note duration]+[note startTime]-flag11];
                [note setStarttime:flag11];
                if ([cd11 cvalue] >= 11 && [cd11 cvalue] <= 64) {
                    [note setBoflag:1];
                } else if ([cd11 cvalue] >= 65 && [cd11 cvalue] <= 127) {
                    [note setBoflag:2];
                }
                
                flag11 = -1;
                
                cdcount11++;
                if (cdcount11 < [controlList11 count]) {
                    cd11 = [controlList11 get:cdcount11];
                }
            } else if ([note startTime] > [cd11 starttime] && [note endTime] < [cd11 endtime]) {
                [notes remove:note];
                i--;
            }
        }
        
        if (cdcount12 < [controlList12 count]) {
            MidiNote* note = [notes get:i];
            if ([note startTime] >= [cd12 starttime] && flag12 < 0) {
                flag12 = [note startTime];
                [notes remove:note];
                i--;
            } else if ([note startTime] < [cd12 endtime] && [note endTime] >= [cd12 endtime]) {
                [note setDuration:[note duration]+[note startTime]-flag12];
                [note setStarttime:flag12];
                if ([cd12 cvalue] >= 11 && [cd12 cvalue] <= 64) {
                    [note setHuiFlag:1];
                } else if ([cd12 cvalue] >= 65 && [cd12 cvalue] <= 127) {
                    [note setHuiFlag:2];
                }
                
                flag12 = -1;
                cdcount12++;
                if (cdcount12 < [controlList12 count]) {
                    cd12 = [controlList12 get:cdcount12];
                }
            } else if ([note startTime] > [cd12 starttime] && [note endTime] < [cd12 endtime]) {
                [notes remove:note];
                i--;
            }
        }
        
        if (cdcount13 < [controlList13 count]) {
            MidiNote* note = [notes get:i];
            if ([note startTime] >= [cd13 starttime] && flag13 < 0) {
                flag13 = [note startTime];
            } else if ([note startTime] < [cd13 endtime] && [note endTime] >= [cd13 endtime]) {
                MidiNote* n = [notes get:i-1];
                [n setDuration:[note endTime]-[n startTime]];
                [n setTrFlag:1];
                [notes remove:note];
                i--;
                
                flag13 = -1;
                cdcount13++;
                if (cdcount13 < [controlList13 count]) {
                    cd13 = [controlList13 get:cdcount13];
                }
            } else if ([note startTime] > [cd13 starttime] && [note endTime] < [cd13 endtime]) {
                [notes remove:note];
                i--;
            }
        }
        
        i++;
    }
}

/** add by sunlie end */

- (NSString*)description {
    NSString *s = [NSString stringWithFormat:
                   @"Track number=%d instrument=%d\n", tracknum, instrument];
    for (int i = 0; i < [notes count]; i++) {
        MidiNote *m = [notes get:i];
        s = [s stringByAppendingString:[m description]];
        s = [s stringByAppendingString:@"\n"];
    }
    s = [s stringByAppendingString:@"End Track\n"];
    return s;
}

@end /* class MidiTrack */

