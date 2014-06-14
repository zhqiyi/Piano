//
//  MIDIParser.h
//  PainoSpirit
//
//  Created by yizhq on 14-5-7.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AudioToolbox;


@interface MIDIParser : NSObject
- (NSArray *)parseMidiSequence:(MusicSequence *)musicSequence;
@end