/*
 * Copyright (c) 2011 Madhav Vaidyanathan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */

#import <Foundation/NSTimer.h>
#import <Foundation/NSData.h>
#import "SheetMusic.h"
#import "MidiFile.h"
#import "Piano.h"
#import "GDSoundEngine.h"
#import "SerialGATT.h"
#import "PianoDataJudged.h"
#import "SheetMusicPlay.h"
#import "PianoRecognition.h"
#import "MidiKeyboard.h"
#import "PianoCommon.h"

/* Possible playing states */
//enum {
//    stopped   = 1,   /** Currently stopped */
//    playing   = 2,   /** Currently playing music */
//    paused    = 3,   /** Currently paused */
//    initStop  = 4,   /** Transitioning from playing to stop */
//    initPause = 5,   /** Transitioning from playing to pause */
//};

enum {
    PlayModel1   = 1,   /** 识谱模式 */
    PlayModel2   = 2,   /** 弹奏模式 */
    PlayModel3   = 3    /** 挑战模式 */
};




@interface MidiPlayer : NSObject<BTSmartSensorDelegate, SheetShadeDelegate> {
//    NSButton* rewindButton;     /** The rewind button */
//    NSButton* playButton;       /** The play/pause button */
//    NSButton* stopButton;       /** The stop button */
//    NSButton* fastFwdButton;    /** The fast forward button */
//    NSSlider* speedBar;         /** The slider for controlling the playback speed */
//    NSSlider* volumeBar;        /** The slider for controlling the volume */

    int playstate;              /** The playing state of the Midi Player */
    MidiFile *midifile;         /** The midi file to play */
    MidiOptions options;        /** The sound options for playing the midi file */
    NSString *tempSoundFile;    /** The temporary midi file currently being played */
    double pulsesPerMsec;       /** The number of pulses per millisec */
    SheetMusic *sheet;          /** The sheet music to highlight while playing */

    
    Piano *piano;               /** The piano to shade while playing */
    NSTimer *timer;             /** Timer used to update the sheet music while playing */
//    UISound *sound;           /** The sound player */
    /* add by yizhq start */
    GDSoundEngine *sound;       /** The sound player */
    NSString *tempSoundFile4Play;    /** The temporary midi file currently being played */
    /* add by yizhq end */
    struct timeval startTime;   /** Absolute time when music started playing */
    double startPulseTime;      /** Time (in pulses) when music started playing */
    double currentPulseTime;    /** Time (in pulses) music is currently at */
    double prevPulseTime;       /** Time (in pulses) music was last at */
    double doubleValue;
    
    PianoDataJudged *pianoData;
    Array* staffs;
    NSMutableArray *arrPacket;
    int len;
    
	PianoRecognition *recognition;
    MidiKeyboard *midiHandler;
    int playModel;
}

-(id)init;
-(void)setMidiFile:(MidiFile*)file withOptions:(MidiOptions*)opt andSheet:(SheetMusic*)sheet;
-(void)setPiano:(Piano*)p;
-(void)reshade:(NSTimer*)timer;
-(void)playPause;
-(void)stop;
-(void)rewind;
-(void)fastForward;
-(void)changeVolume:(double) value;
-(void)changeSpeed:(double) value;
-(void)timerCallback:(NSTimer*)timer;
-(void)restartPlayMeasuresInLoop;
-(void)replay:(NSTimer*)timer;
-(BOOL)isFlipped;
-(void)deleteSoundFile;
-(void)doStop;
-(void)dealloc;

//跳转小节
-(BOOL)jumpMeasure:(int)number;
-(void)playByType:(int)type;

/** add by yizhq start */
-(void)playJumpSection:(int)startSectionNumber;
-(void)clearJumpSection;
/** add by yizhq end */

@property (strong, nonatomic) SheetMusicPlay *sheetPlay;
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) SerialGATT *sensor;
@property (nonatomic, assign) id <MidiPlayerDelegate> delegate;

@property (strong, nonatomic) UILabel *midiData;

@end


