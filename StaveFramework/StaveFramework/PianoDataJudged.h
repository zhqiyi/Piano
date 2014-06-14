//
//  PianoDataJudged.h
//  PainoSpirit
//
//  Created by 李洪胜 on 14-4-10.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSTimer.h>
#import <Foundation/NSData.h>
#import "Array.h"
#import "TimeSignature.h"
#import "MidiNote.h"
#import "Staff.h"
#import "MusicSymbol.h"
#import "ChordSymbol.h"
#import "MidiFile.h"

@interface PianoDataJudged : NSObject {
    Array* pianoData;
    Array* notes;
    struct timeval beginTime;
    TimeSignature *timesig;
    Array* prevChordList;
    Array* curChordList;
    double pulsesPerMsec;
    IntArray* judgedResult;     //0: total count 1: wrong count  2:right count 3: good count:
}

-(IntArray*)judgedResult;
-(void)setJudgedResult:(IntArray*)j;
-(struct timeval)beginTime;
-(void)setBeginTime:(struct timeval)b;
-(TimeSignature*)timesig;
-(void)setTimesig:(TimeSignature*)t;
-(double)pulsesPerMsec;
-(void)setPulsesPerMsec:(double)p;

-(id)init;
-(void)setPianoData:(NSMutableArray*)data;
-(void)parseData;
-(void)FindChords:(int)curPulseTime andPrevPulseTime:(int)prevPulseTime andStaffs:(Array*)staffs;
-(void)judgedPianoPlay:(int)curPulseTime andPrevPulseTime:(int)prevPulseTime andStaffs:(Array*)staffs andMidifile:(MidiFile *)midifile;
-(void)RoundStartTimes:(Array*)midiNotes;
@end
