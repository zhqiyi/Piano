//
//  PianoRecognition.h
//  PainoSpirit
//
//  Created by zyw on 14-5-26.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSTimer.h>
#import <Foundation/NSData.h>
#import "Array.h"
#import "TimeSignature.h"
#import "Staff.h"
#import "MusicSymbol.h"
#import "ChordSymbol.h"
#import "RecognitionlData.h"
#import "PianoRecognition.h"
#import "PianoCommon.h"

@interface PianoRecognition : NSObject {
    NSMutableArray* symbolDatas;
    int currIndex;
    
    Array* pianoData;
    Array* notes;
    int quarter;        /** Number of pulses per quarter note */
    struct timeval beginTime;
    int staffIndex;
    int chordIndex;
    int numtracks;     /** Total number of tracks */
    int leftAndRight;  //1:right 2:left
    double pulsesPerMsec;
}

-(id)initWithStaff:(Array*)staffs WithtMidiFile:(MidiFile*)file andOptions:(MidiOptions*)options;
-(id)initWithtMidiFile:(MidiFile*)file andOptions:(MidiOptions*)options;

-(NSMutableArray*)getChordSymbolDatas;
-(int)getCurrIndex;
-(void)setCurrIndex:(int)index;

-(void)setBeginTime:(struct timeval)b;
-(void)setPianoData:(NSMutableArray*)data;
-(void)setPulsesPerMsec:(double)p;

-(int)getCurChordSymolNoteCount;
-(BOOL)recognitionPlay:(Array*)staffs;
-(void)recognitionPlayByLine;
-(int)getNotesCount;
@property (nonatomic, assign) id <MidiPlayerDelegate> endDelegate;
@property (nonatomic, assign) id <SheetShadeDelegate> sheetShadeDelegate;

@end
