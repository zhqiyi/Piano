//
//  BeatSignature.h
//  PainoSpirit
//
//  Created by yizhq on 14-4-7.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeatSignature : NSObject{
    int _numerator;      /** Numerator of beat signature */
    int _denominator;    /** Denominator of the beat signature */
    int _starttime;      /** starttime of the beat signature */
}

- (void) setNumerator:(int)numerator;
- (int) numerator;

- (void) setDenominator:(int)denominator;
- (int) denominator;

- (void) setStarttime:(int)starttime;
- (int) starttime;

- (id) initWithNumerator:(int)numerator andDenominator:(int)denominator andStarttime:(int)starttime;

@end
