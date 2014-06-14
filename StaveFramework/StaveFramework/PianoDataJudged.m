//
//  PianoDataJudged.m
//  PainoSpirit
//
//  Created by 李洪胜 on 14-4-10.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//
#include <sys/time.h>
#import "PianoDataJudged.h"

@implementation PianoDataJudged

-(id) init {
    int i;
    pianoData = [Array new:100];
    notes = [Array new:100];
    prevChordList = [Array new:100];
    curChordList = [Array new:100];
    judgedResult = [IntArray new:4];
    (void)gettimeofday(&beginTime, NULL);
    
    for (i=0; i<4; i++) {
        [judgedResult add:0];
    }
    return self;
}

-(void)setPianoData:(NSMutableArray*)data {
    int i;
    for (i = 0; i < [data count]; i++) {
        [pianoData add:[data objectAtIndex:i]];
    }
    [self parseData];
    [pianoData clear];
}

-(IntArray*)judgedResult {
    return judgedResult;
}

-(void)setJudgedResult:(IntArray*)j {
    judgedResult = j;
}

-(struct timeval)beginTime {
    return beginTime;
}

-(void)setBeginTime:(struct timeval)b {
    beginTime = b;
}

-(TimeSignature*)timesig {
    return timesig;
}

-(void)setTimesig:(TimeSignature*)t {
    timesig = t;
}

-(double)pulsesPerMsec {
    return pulsesPerMsec;
}

-(void)setPulsesPerMsec:(double)p {
    pulsesPerMsec = p;
}

-(void)parseData {
    int i = 0;
    long msec;
    double starttime;
    
    while ((i+2) < [pianoData count]) {
        
        if ([[pianoData get:i] intValue] == 0x90) {
            if ([[pianoData get:i+2] integerValue] > 0) {
                struct timeval now;
                (void)gettimeofday(&now, NULL);
                msec = (now.tv_sec - beginTime.tv_sec)*1000 +
                (now.tv_usec - beginTime.tv_usec)/1000;
                starttime = msec * pulsesPerMsec;
                MidiNote *note = [[MidiNote alloc]init];
                [note setStarttime:starttime];
                [note setNumber:[[pianoData get:i+1] intValue]];
                [notes add:note];
            }
        }
        i += 3;
    }
}

-(void)FindChords:(int)curPulseTime andPrevPulseTime:(int)prevPulseTime andStaffs:(Array*)staffs {
    int upFlag = 0;
    Staff *staff;
    int i;
    int j;
    int k;
    
    for (i=0; i<[staffs count]; i++) {
        staff = [staffs get:i];
        if (([staff endTime] <= curPulseTime) || ([staff startTime] > curPulseTime)) {
            continue;
        } else {
            Array* symbols = [staff symbols];
            for (j = 0; j < [symbols count]; j++) {

                NSObject <MusicSymbol> *symbol = [symbols get:j];
                if ([symbol isKindOfClass:[ChordSymbol class]]) {
                    ChordSymbol *chord = (ChordSymbol *)symbol;
                    if ([chord startTime] > curPulseTime) {
                        break;
                    } else if ([chord startTime] > prevPulseTime) {
                        if (upFlag == 0) {
                            upFlag = 1;
                            if ([curChordList count] >= 0) {
                                for (k = 0; k < [curChordList count]; k++) {
                                    [prevChordList add:[curChordList get:k]];
                                }
                                [curChordList clear];
                            }
                            [curChordList add:chord];
                        } else {
                            [curChordList add:chord];
                        }
                    }
                }
            }
        }
    }
}

-(void)judgedPianoPlay:(int)curPulseTime andPrevPulseTime:(int)prevPulseTime andStaffs:(Array*)staffs andMidifile:(MidiFile *)midifile {
    
    if (staffs == nil) {
        return;
    }
    
    int j;
    
    if (curPulseTime != 10) {
        [self FindChords:curPulseTime andPrevPulseTime:prevPulseTime andStaffs:staffs];
    }
    
    if ([prevChordList count] >= 0) {
        for (j = [prevChordList count] - 1; j >= 0; j--) {
            ChordSymbol *chord = [prevChordList get:j];
            int start = [chord startTime];
            int end = [chord endTime];
            NoteData *noteData = [chord notedata];
            int count = 0;
            int rightCount = 0;
            int i,k;
            int result = 0;
            NoteData nd;
            
            for (i = 0; i < [chord notedata_len]; i++) {
                nd = noteData[i];
                if (nd.previous == 1) {
                    continue;
                } else
                {
                    count++;
                }
            }
            
            if (count == 0) {
                [chord setJudgedResult:-2];
                [prevChordList remove:chord];
                continue;
            }
            
            for (i = 0; i < [chord notedata_len]; i++) {
                nd = noteData[i];
                if (nd.previous == 1) {
                    continue;
                }
                
                if (nd.addflag == 1) {
                    rightCount++;
                    continue;
                }
                
                for (k = 0; k < [notes count]; k++) {
                    if (abs([[notes get:k] startTime]-start) <= (end-start)/2) {
                        if (nd.number == [[notes get:k] number]) {
                            if (result == 0) {
                                result = 2;
                            }
                            rightCount++;
                            [notes remove:[notes get:k]];
                            break;
                        }
                    } else if (abs([[notes get:k] startTime]-start) <= (end-start)) {
                        if (nd.number == [[notes get:k] number]) {
                            if (result > 1 || result == 0) {
                                result = 1;
                            }
                            rightCount++;
                            [notes remove:[notes get:k]];
                            break;
                        }
                    } else if ([[notes get:k] startTime]-start > (end-start)) {
                        break;
                    }
                }
            }
            
            if ([chord judgedResult] == 0) {
                if (result == -1 || rightCount < count) {
                    [chord setJudgedResult:-1];
                    [prevChordList remove:chord];
                    [judgedResult set:[judgedResult get:0]+1 index:0];
                    [judgedResult set:[judgedResult get:1]+1 index:1];
                    
                } else if (result == 0 && curPulseTime-start > (end-start)) {
                    [chord setJudgedResult:-1];
                    [prevChordList remove:chord];
                    [judgedResult set:[judgedResult get:0]+1 index:0];
                    [judgedResult set:[judgedResult get:1]+1 index:1];
                } else if (result > 0) {
                    [chord setJudgedResult:result];
                    [prevChordList remove:chord];
                    if (result == 1) {
                        [judgedResult set:[judgedResult get:0]+1 index:0];
                        [judgedResult set:[judgedResult get:2]+1 index:2];
                    } else {
                        [judgedResult set:[judgedResult get:0]+1 index:0];
                        [judgedResult set:[judgedResult get:3]+1 index:3];
                    }
                }
            }
        }
    }
    
    return;
}

-(void)RoundStartTimes:(Array*)midiNotes {
    int j;
    MidiNote *note;
    IntArray*  starttimes = [IntArray new:100];
    int interval = 20;
    note = [midiNotes get:0];
    int tmptime = [note startTime];
    
    for (j = 0; j < [midiNotes count] - 1; j++) {
        note = [midiNotes get:j];
        if ([[midiNotes get:j+1] startTime]-tmptime <= interval/2) {
            tmptime = [[midiNotes get:j+1] startTime];
            [[midiNotes get:j+1] setStartTime:[[midiNotes get:j] startTime]];
        } else if ([[midiNotes get:j+1] startTime]-tmptime <= interval && [note duration] > 120) {
            tmptime = [[midiNotes get:j+1] startTime];
            [[midiNotes get:j+1] setStartTime:[[midiNotes get:j] startTime]];
        } else {
            tmptime = [[midiNotes get:j+1] startTime];
        }
    }
    
    [midiNotes sort:sortbytime];
    
    for (j = 0; j < [midiNotes count]; j++) {
        [starttimes add:[[midiNotes get:j] startTime]];
    }
    
    [starttimes sort];
    
    for (j = 0; j < [starttimes count] - 1; j++) {
        if ([starttimes get:j+1] - [starttimes get:j] <= interval/2) {
            [starttimes set:[starttimes get:j] index:j+1];
        }
    }
    
    j=0;
    
    for (j = 0; j < [midiNotes count]; j++) {
        note = [midiNotes get:j];
        while ([note startTime]-interval > [starttimes get:j]) {
            j++;
        }
        
        if ([note startTime] > [starttimes get:j] &&
            [note startTime] - [starttimes get:j] <= interval) {
            [note setStarttime:[starttimes get:j]];
        }
    }
    
    [midiNotes sort:sortbytime];
}

- (void)dealloc
{
    [pianoData release];
    [notes release];
    [prevChordList release];
    [curChordList release];
    [judgedResult release];
}


@end
