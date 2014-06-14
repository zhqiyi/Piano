//
//  TrackSetting.h
//  PainoSpirit
//
//  Created by yizhq on 14-5-7.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TrackSetting : NSObject
@property(nonatomic) UInt8 channel;
@property(nonatomic) UInt8 data1;
@property(nonatomic) UInt8 data2;
@property(nonatomic, strong) NSString *trackName;
@property(nonatomic, strong) NSString *instrumentName;
@property(nonatomic) UInt32 trackNumber;
@end
