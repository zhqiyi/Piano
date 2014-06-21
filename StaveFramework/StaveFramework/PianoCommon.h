//
//  PianoCommon.h
//  StaveFramework
//
//  Created by zhengyw on 14-5-26.
//  Copyright (c) 2014年 yizhq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChordSymbol.h"

@protocol MidiPlayerDelegate
@optional
- (void) endSongs;
- (void) endSongsResult:(int) good andRight:(int) right andWrong:(int) wrong;
@end

@protocol SheetShadeDelegate
@optional
- (void) sheetShade:(int) staffIndex andChordIndex:(int)chordIndex andChordSymbol:(ChordSymbol*)chord;
@end


@protocol SheetMusicsDelegate
@optional
- (void) splitMeasure:(int) from andTo:(int)to;
- (void) handModel:(int)value;
- (void) SparringMute:(int)value;
- (void) beatMute:(int)value;
@end


@interface PianoCommon : NSObject


+ (NSString*)getDeviceVersion;


@end
