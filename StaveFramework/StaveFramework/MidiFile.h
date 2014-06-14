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
#import "MidiEvent.h"
#import "MidiNote.h"
#import "MidiTrack.h"
#import "MidiFileReader.h"
#import "MidiOptions.h"
#import "MidiFileException.h"
#import "BeatSignature.h"
#import "ToneSignature.h"
#import "ControlData.h"


/* The list of Midi Events */
#define EventNoteOff         0x80
#define EventNoteOn          0x90
#define EventKeyPressure     0xA0
#define EventControlChange   0xB0
#define EventProgramChange   0xC0
#define EventChannelPressure 0xD0
#define EventPitchBend       0xE0
#define SysexEvent1          0xF0
#define SysexEvent2          0xF7
#define MetaEvent            0xFF

/* The list of Meta Events */
#define MetaEventSequence      0x0
#define MetaEventText          0x1
#define MetaEventCopyright     0x2
#define MetaEventSequenceName  0x3
#define MetaEventInstrument    0x4
#define MetaEventLyric         0x5
#define MetaEventMarker        0x6
#define MetaEventEndOfTrack    0x2F
#define MetaEventTempo         0x51
#define MetaEventSMPTEOffset   0x54
#define MetaEventTimeSignature 0x58
#define MetaEventKeySignature  0x59


@interface MidiFile : NSObject {
    NSString* filename;      /** The Midi file name */
    Array* events;           /** Array< Array<MidiEvent>> : the raw midi events */
    Array *tracks;           /** The tracks (MidiTrack) of the midifile that have notes */
    u_short trackmode;       /** 0 (single track), 1 (simultaneous tracks) 2 (independent tracks) */
    TimeSignature* timesig;  /** The time signature */
    int quarternote;         /** The number of pulses per quarter note */
    int totalpulses;         /** The total length of the song, in pulses */
    BOOL trackPerChannel;    /** True if we've split each channel into a track */
    /** add by sunlie start */
    Array* beatarray;        /** The beat signature */
    Array* tonearray;        /** The tone signature */
    Array* controlList;   /** The control data list(33) */
    Array* controlList2;  /** control data for connect line (9) */
    Array* controlList3;  /** control data for connect jumped notes (14)*/
    Array* controlList4;  /** control data for eight (15)*/
    Array* controlList5;  /** control data for pedal (64) */
    Array* controlList6;  /** control data for pa (20)*/
    Array* controlList7;  /** control data for zhuangshi (21)*/
    /** add by sunlie end */
}

-(Array*)tracks;
-(TimeSignature*)time;
-(NSString*)filename;
-(NSString*)description;
-(int)totalpulses;
/** add by sunlie start */
-(Array*)beatarray;
-(Array*)tonearray;
/** add by sunlie end */
-(id)initWithFile:(NSString*)path;
-(Array*)readTrack:(MidiFileReader*)file;
-(IntArray*)guessMeasureLength;
-(BOOL)changeSound:(MidiOptions *)options oldMidi:(MidiFile *)midifile toFile:(NSString*)filename;//modify by yizhq 
-(Array*)applyOptionsToEvents:(MidiOptions *)options;
-(Array*)applyOptionsPerChannel:(MidiOptions *)options;
-(Array*)changeMidiNotes:(MidiOptions*)options;
-(int)endTime;
-(void)initOptions:(MidiOptions*)options;
-(BOOL)hasLyrics;
/** add by yizhq start */
-(void)rightHandMute:(MidiOptions*)options andState:(BOOL)state;
-(void)leftHandMute:(MidiOptions*)options andState:(BOOL)state;
-(BOOL)getRightHadnMuteState:(MidiOptions*)options;
-(BOOL)getLeftHadnMuteState:(MidiOptions*)options;
/** add by yizhq end */

+(void)findHighLowNotes:(Array*)notes withMeasure:(int)measurelen startIndex:(int)startindex
                        fromStart:(int)starttime toEnd:(int)endtime withHigh:(int*)high
                        andLow:(int*)low;

+(void)findExactHighLowNotes:(Array*)notes startIndex:(int)startindex
                        withStart:(int)starttime withHigh:(int*)high
                        andLow:(int*)low; 

+(Array*)splitTrack:(MidiTrack *)track withMeasure:(int)measurelen;
+(Array*)splitChannels:(MidiTrack *)track withEvents:(Array*)events;
+(MidiTrack*) combineToSingleTrack:(Array *)tracks;

+(Array*) combineToTwoTracks:(Array *)tracks withMeasure:(int)measurelen;
+(void)checkStartTimes:(Array *)tracks;
+(void)roundStartTimes:(Array *)tracks toInterval:(int)millisec  withTime:(TimeSignature*)time;
+(void)roundDurations:(Array *)tracks withQuarter:(int)quarternote;
+(void)shiftTime:(Array*)tracks byAmount:(int)amount;
+(void)transpose:(Array*)tracks byAmount:(int)amount;
+(BOOL)hasMultipleChannels:(MidiTrack*) track;
+(NSArray*) instrumentNames;

+(int)getTrackLength:(Array*)events;
+(BOOL)writeToFile:(NSString*)filename withEvents:(Array*)eventlists
           andMode:(int)trackmode andQuarter:(int)quarter andMidifile:(MidiFile *)midifile;//modify by yizhq
+(Array*)cloneMidiEvents:(Array*)origlist;
+(void) addTempoEvent:(Array*)eventlist withTempo:(int)tempo;
+(Array*)startAtPauseTime:(int)pauseTime withEvents:(Array*)list;
+(NSString*)titleName:(NSString*)filename;

//取得小节数
-(int)getMeasureCount;
//取得文件时长 单位：毫秒
-(int)getMidiFileTimes;

@end



