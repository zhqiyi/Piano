//
//  ControlData.m
//  PainoSpirit
//
//  Created by 李洪胜 on 14-4-9.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import "ControlData.h"

@implementation ControlData

- (int) number {
    return number;
}

- (void) setNumber:(int)n {
    number = n;
}

- (int) cvalue {
    return cvalue;
}

- (void) setCValue:(int)v {
    cvalue = v;
}
- (int) starttime {
    return starttime;
}
- (void) setStarttime:(int)s {
    starttime = s;
}

- (int) endtime {
    return endtime;
}

- (void) setEndtime:(int)e {
    endtime = e;
}

-(id) initWithNumber:(int)n andValue:(int)v andStarttime:(int)s andEndtime:(int)e{
    number = n;
    cvalue = v;
    starttime = s;
    endtime = e;
    return self;
}

-(id) copyWithZone:(NSZone*)zone {
    
    ControlData *c = [[ControlData alloc] initWithNumber:number andValue:cvalue andStarttime:starttime andEndtime:endtime];

    return c;
}

@end