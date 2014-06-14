//
//  RecognitionData.m
//  PainoSpirit
//
//  Created by zyw on 14-5-28.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import "RecognitionlData.h"

@implementation RecognitionData

-(id) initWithStaffIndex:(int)index1 andChordIndex:(int)index2 andChordSymbol:(ChordSymbol*)symbol
{
    staffIndex = index1;
    chordIndex = index2;
    chord = symbol;
    return self;
}

-(int)getStaffIndex
{
    return staffIndex;
}

-(int)getChordIndex
{
    return chordIndex;
}

-(ChordSymbol*)getChordSymbol
{
    return chord;
}


@end