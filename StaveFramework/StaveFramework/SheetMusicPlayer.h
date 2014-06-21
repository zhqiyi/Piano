//
//  SheetMusicPlay.h
//  PainoSpirit
//
//  Created by zhengyw on 14-4-24.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import "Array.h"
#import "TimeSignature.h"
#import "KeySignature.h"
#import "ClefMeasures.h"
#import "MidiFile.h"
#import "SymbolWidths.h"
#import "MusicSymbol.h"
#import "Staff.h"
#import "SheetMusicDelegate.h"

#define maxs(x,y) ((x) > (y) ? (x) : (y))

@interface SheetMusicPlayer : UIView {
    
    Array* staffs;            /** The array of Staffs to display (from top to bottom) */
    float zoom;               /** The zoom level to draw at (1.0 == 100%) */
    int   types;
    UIColor *shadeColor;      /** The color for shading */
    UIColor *shade2Color;     /** The color for shading left-hand piano */
    CGContextRef pContext;
    int shadeCurrentPulseTime;
    int shadePrevPulseTime;
    BOOL zoomFlag;
    /** add by yizhq start */
    MidiOptions *smOption;
    /** add by yizhq end */
}

-(id)initWithOptions:(MidiOptions*)options andType:(int) type;
-(void)setZoom:(float)value;

-(void) drawRect:(CGRect) rect;
-(void) setStaffs:(Array*) staff;
-(void) shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime;

@property (nonatomic, assign) id <SheetMusicDelegate> delegate;
@property BOOL updateStaffsFlag;
@property int endIndex;

@end
