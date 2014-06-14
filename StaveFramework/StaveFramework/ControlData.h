//
//  ControlData.h
//  PainoSpirit
//
//  Created by 李洪胜 on 14-4-9.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ControlData : NSObject {
    int number;
	int cvalue;
	int starttime;
    int endtime;
}

- (int) number;
- (void) setNumber:(int)n;
- (int) cvalue;
- (void) setCValue:(int)v;
- (int) starttime;
- (void) setStarttime:(int)s;
- (int) endtime;
- (void) setEndtime:(int)e;

-(id) initWithNumber:(int)number andValue:(int)value andStarttime:(int)starttime andEndtime:(int)endtime;

-(id) copyWithZone:(NSZone*)zone;

@end