//
//  ToneSignature.m
//  PainoSpirit
//
//  Created by 李洪胜 on 14-4-9.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import "ToneSignature.h"

@implementation ToneSignature

- (int) tone {
    return tone;
}

- (void) setTone:(int)t {
    tone = t;
}

- (void) setStarttime:(int)s {
    starttime = s;
}

- (int) starttime {
    return starttime;
}

- (id) initWithTone:(int)t andStarttime:(int)s {
//- (id) initWithTone:(Byte)t andStarttime:(int)s {
    if (t > 7 || t < -7 || s < 0) {
        return nil;
    }
    
    [self setTone:t];
    [self setStarttime:s];
    
    return self;
}

@end