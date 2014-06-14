//
//  Piano.h
//  2DView
//
//  Created by zhengyw on 14-3-13.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Array.h"
#import "MidiFile.h"

@interface Piano : UIView {
    Array *notes;          /** The midi notes, for shading. */
    int maxShadeDuration;  /** The maximum duration we'll shade a note for */
    BOOL useTwoColors;     /** If true, use two colors for highlighting */
    int showNoteLetters;   /** Display the letter for each piano note */
    UIColor *shadeColor;   /** The color to use for shading */
    UIColor *shade2Color;  /** The color for left-hand shading */
    UIColor *gray1, *gray2, *gray3; /** Gray colors for drawing black/gray lines */
    UIColor *white;        /** The white color for the keys */

    int shadeNumber;
    UIColor *shadeColorEx;
    
    int height;
    int width;
}

-(id)init;
-(void)setMidiFile:(MidiFile*)file withOptions:(MidiOptions*)opt;
-(void)setShade:(UIColor*)s1 andShade2:(UIColor*)s2;
-(void)shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime;
-(void)drawOctaveOutline;
-(void)drawOutline;
-(void)drawBlackKeys;
-(void)drawBlackBorder;
-(void)shadeOneNote:(int)notenumber withColor:(UIColor*) c;
-(int)nextStartTime:(int)index;
-(void)fillRect:(CGRect)rect withColor:(UIColor*)color;
-(void)dealloc;
@end
