//
//  SheetMusicPlay.h
//  PainoSpirit
//
//  Created by zhengyw on 14-4-27.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SheetMusicPlayer.h"
#import "SheetMusicDelegate.h"

@interface SheetMusicPlay : UIView <SheetMusicDelegate> {
    Array* staffs;            /** The array of Staffs to display (from top to bottom) */
    SheetMusicPlayer *player1;
    SheetMusicPlayer *player2;
    int trackCount;
    int currentPulseTimes;
}


-(id)initWithStaffs:(Array*) staff andTrackCount:(int) count andOptions:(MidiOptions*)options;
-(void) setCurrentPulseTime:(int)currentPulseTime;
-(void) shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime;
-(void)setZoom:(float)value;

@end
