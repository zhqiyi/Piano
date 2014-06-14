//
//  RecognitionData.h
//  PainoSpirit
//
//  Created by zyw on 14-5-28.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChordSymbol.h"

@interface RecognitionData : NSObject {
    int staffIndex;
    int chordIndex;
	ChordSymbol *chord;
}

-(id) initWithStaffIndex:(int)index1 andChordIndex:(int)index2 andChordSymbol:(ChordSymbol*)symbol;

-(int)getStaffIndex;
-(int)getChordIndex;
-(ChordSymbol*)getChordSymbol;

@end