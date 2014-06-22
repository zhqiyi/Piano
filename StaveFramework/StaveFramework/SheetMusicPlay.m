//
//  SheetMusicPlay.m
//  PainoSpirit
//
//  Created by zhengyw on 14-4-27.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import "SheetMusicPlay.h"

@implementation SheetMusicPlay


-(id)initWithStaffs:(Array*) staff andTrackCount:(int) count andOptions:(MidiOptions*)options
{
    self = [super initWithFrame:CGRectMake(0, 0, 10, 10)];
    
    staffs = staff;
    trackCount = count;
    currentPulseTimes = 0;
    
    player1 = [[SheetMusicPlayer alloc ] initWithOptions:options andType:1];
    player2 = [[SheetMusicPlayer alloc ] initWithOptions:options andType:2];
    player1.delegate = self;
    player2.delegate = self;
    
    [self initViews];
    
    return self;
}

-(void) initViews
{
    
    float margin = 20;
    
    [self setCurrentPulseTime:0];
    
    CGRect rect = [player1 frame];
    int height = 250;
    int width = rect.size.width;
    
    [player1 setFrame:CGRectMake(0, 0, width, height)];
    [player2 setFrame:CGRectMake(0, height + margin, width, height)];
    
    [self addSubview:player1];
    [self addSubview:player2];
}

-(int)getCurrentPulseTimeAtStaffIndex
{
    int ret = -1;
    for(int i = 0; i < [staffs count]; i++)
    {
        Staff *staff = [staffs get:i];
        if (currentPulseTimes >=[staff startTime] &&
            currentPulseTimes <= [staff endTime]) {
            ret = i;
            break;
        }
    }
    
    return ret;
}



-(void)setCurrentPulseTime:(int)currentPulseTime
{
    currentPulseTimes = currentPulseTime;
    
    int index = [self getCurrentPulseTimeAtStaffIndex];
    if (index == -1) return;
    
    if ((index + trackCount) <= [staffs count])
    {
        Array *player1Staffs = [Array new:trackCount];
        for(int i = index; i < (index+trackCount); i++) {
            Staff *staff = [[staffs get:i] retain];
            [player1Staffs add:staff];
            player1.endIndex = i;
        }
        [player1 setStaffs:player1Staffs];
        
        [player1Staffs release];
        [player1 setNeedsDisplay];
    }
    
    if ((index + trackCount*2) <= [staffs count])
    {
        Array *player2Staffs = [Array new:trackCount];
        for(int i = (index + trackCount); i < index + trackCount*2; i++) {
            Staff *staff = [[staffs get:i] retain];
            [player2Staffs add:staff];
            player2.endIndex = i;
        }
        
        player2.updateStaffsFlag = TRUE;
        [player2 setStaffs:player2Staffs];
        [player2Staffs release];
        [player2 setNeedsDisplay];
    }
}

-(void)setZoom:(float)value
{
    [player1 setZoom:value];
    [player2 setZoom:value];
}

-(void) shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime
{
    [player1 shadeNotes:currentPulseTime withPrev:prevPulseTime];
    [player2 shadeNotes:currentPulseTime withPrev:prevPulseTime];
}

//SheetMusicDeletegate
-(void) updateStaffs:(int)type
{
    //0,1;2,3;4,5;6,7;8,9;10,11;
    int start = maxs(player2.endIndex, player1.endIndex)+1;
    int end = start + trackCount;
//    NSLog(@"the type is %i start is %i end is %i", type, start, end);
    if (type == 1) {// 更新第2view
        
        if (end <= [staffs count])
        {
            Array *player2Staffs = [Array new:trackCount];
            for(int i = start; i < end; i++) {
                Staff *staff = [[staffs get:i] retain];
                [player2Staffs add:staff];
                player2.endIndex = i;
            }
            
            player2.updateStaffsFlag = TRUE;
            [player2 setStaffs:player2Staffs];
            [player2Staffs release];
        }
        
    } else if (type == 2) {//更新第1个view
        
        if (end <= [staffs count])
        {
            Array *player1Staffs = [Array new:trackCount];
            for(int i = start; i < end; i++) {
                Staff *staff = [[staffs get:i] retain];
                [player1Staffs add:staff];
                player1.endIndex = i;
            }
            
            player1.updateStaffsFlag = TRUE;
            [player1 setStaffs:player1Staffs];
            [player1Staffs release];
        }
    }
}


-(void) dealloc
{
    [player1 release];
    [player2 release];
    
    [super dealloc];
}

@end
