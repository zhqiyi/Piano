//
//  SheetMusicPlay.m
//  PainoSpirit
//
//  Created by zhengyw on 14-4-24.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import <Foundation/NSString.h>
#import "AccidSymbol.h"
#import "Array.h"
#import "BarSymbol.h"
#import "BlankSymbol.h"
#import "ChordSymbol.h"
#import "ClefMeasures.h"
#import "ClefSymbol.h"
#import "KeySignature.h"
#import "LyricSymbol.h"
#import "MidiFile.h"
#import "MusicSymbol.h"
#import "RestSymbol.h"
#import "Staff.h"
#import "Stem.h"
#import "SymbolWidths.h"
#import "TimeSignature.h"
#import "TimeSigSymbol.h"
#import "WhiteNote.h"
#import "SheetMusic.h"
#import "SheetMusicPlayer.h"



int LeftMargins = 4;   /** The left margin, in pixels */
int TitleHeights = 14; /** The height for the title on the first page */


@implementation SheetMusicPlayer

@synthesize delegate;
@synthesize endIndex;
@synthesize updateStaffsFlag;

/** Create a new SheetMusic control.
 * MidiFile is the parsed midi file to display.
 * SheetMusic Options are the menu options that were selected.
 *
 * - Apply all the Menu Options to the MidiFile tracks.
 * - Calculate the key signature
 * - For each track, create a list of MusicSymbols (notes, rests, bars, etc)
 * - Vertically align the music symbols in all the tracks
 * - Partition the music notes into horizontal staffs
 */
-(id)initWithOptions:(MidiOptions*)options andType:(int) type {
    
    self = [super initWithFrame:CGRectMake(0, 0, 10, 10)];
    
    /** add by yizhq start */
    smOption = options;
    /** add by yizhq end */
    types = type;
    shadePrevPulseTime = -1;
    shadeCurrentPulseTime = -1;
    zoomFlag = FALSE;
    updateStaffsFlag = FALSE;
    zoom = 1.0f;
    
    [self setColors:options->colors andShade:options->shadeColor andShade2:options->shade2Color];
    
    return self;
}


/** Set the note colors to use */
- (void)setColors:(Array*)newcolors andShade:(UIColor*)s andShade2:(UIColor*)s2  {

    shadeColor = s;
    shade2Color = s2;
}


/* Set the zoom level to display at (1.0 == 100%).
 * Recalculate the SheetMusic width and height based on the
 * zoom level.  Then redraw the SheetMusic.
 */
- (void)setZoom:(float)value {
    zoom = value;
    CGRect rect = [self frame];
    CGSize size = rect.size;
    float width = 0;
    float height = 0;
    if (staffs != nil) {
        for (int i = 0; i < [staffs count]; i++) {
            Staff *staff = [staffs get:i];
            width = maxs(width, [staff width] * zoom);
            height += ([staff height] * zoom);
        }
    }

    size.width = (int)width + 2;
    size.height = ((int)height) + LeftMargins;
    rect.size.width = size.width;
    rect.size.height = size.height;
    
    self.frame = rect;
    zoomFlag = TRUE;
}

- (void) setStaffs:(Array *)staff
{
    if (staffs != nil) {
        [staffs release];
        staffs = nil;
    }
    
    if (staff != nil) {
        staffs = [staff retain];
    }
    

        [self setZoom:zoom];
}


/** Draw the SheetMusic.
 * If drawing to the screen, scale the graphics by the current zoom factor.
 * If printing, scale the graphics by the paper page size.
 * Get the vertical start and end points of the clip area.
 * Only draw Staffs which lie inside the clip area.
 */
- (void)drawRect:(CGRect)rect {

    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [[UIColor whiteColor] setFill];
    [path fill];
    
    
    [[UIColor blackColor] setFill];
    

    CGRect clip;
    CGContextScaleCTM (context, zoom, zoom);
    
    clip = CGRectMake((int)(rect.origin.x / zoom),
                      (int)(rect.origin.y / zoom),
                      (int)(rect.size.width / zoom),
                      (int)(rect.size.height / zoom) );

    if (staffs == nil) return;
    
    int ypos = TitleHeights;
    
    for (int i =0; i < [staffs count]; i++) {
        Staff *staff = [staffs get:i];
        if ((ypos + [staff height] < clip.origin.y) || (ypos > clip.origin.y + clip.size.height)) {
            /* Staff is not in the clip, don't need to draw it */
        }
        else {

            CGContextTranslateCTM (context, 0, ypos);
            
//            [staff drawRect:context InRect:clip];
            [staff drawRect:context InRect:clip withOptions:smOption];
            
 //           NSLog(@"aaaaaaaaaaa %i", shadeCurrentPulseTime);
            if (shadePrevPulseTime != -1 && shadeCurrentPulseTime !=-10) {
                [staff shadeNotes:context withColor:shadeColor];
                
            }
            
            //[staff cleanShadeNote];
            CGContextTranslateCTM (context, 0, -ypos);
        }
        
        ypos += [staff height];
    }
    
    CGContextScaleCTM (context, (1.0/zoom), (1.0/zoom));

}

- (BOOL) isStartUpdate:(Staff*) staff withPulseTime:(int) currentPulseTime
{
    BOOL ret = FALSE;
    if (staff == nil) return FALSE;
    
    Array *symbols = [staff symbols];
    int pos = [symbols count]/2;

    
    if ([[symbols get:pos] isKindOfClass:[BarSymbol class]]) {
        pos +=1;
    }
    id <MusicSymbol> start = [symbols get:pos];
    
    pos += 1;
    if ([[symbols get:pos] isKindOfClass:[BarSymbol class]]) {
        pos +=1;
    }
    id <MusicSymbol> end = [symbols get:pos];
    
    if (([start startTime] <= currentPulseTime) && (currentPulseTime <= [end startTime]))
    {
        ret = TRUE;
    }
    
    return ret;
}

/** Shade all the chords played at the given pulse time.
 *  Loop through all the staffs and call staff.shadeNotes().
 *  If scrollGradually is true, scroll gradually (smooth scrolling)
 *  to the shaded notes.
 */
- (void)shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime {

    shadeCurrentPulseTime = currentPulseTime;
    shadePrevPulseTime = prevPulseTime;
    
    
    
    for (int i = 0; i < [staffs count]; i++) {
        Staff *staff = [staffs get:i];
        
        int x_shade = 0;
        [staff calcShadeNotes:currentPulseTime withPrev:prevPulseTime andX:&x_shade];

        
        //通知SheetMusicPlay开始可以更新曲谱了
        if (i == 0) {

                BOOL result = [self isStartUpdate:staff withPulseTime:currentPulseTime];
                if (result && updateStaffsFlag) {
                    updateStaffsFlag = FALSE;
                    [delegate updateStaffs:types];
                }
        }
    }

	[self setNeedsDisplay];
}


- (NSString*) description {
    NSString *result = [NSString stringWithFormat:@"SheetMusicPlay staffs=%d\n", [staffs count]];
    for (int i = 0; i < [staffs count]; i++) {
        Staff *staff = [staffs get:i];
		result = [result stringByAppendingString:[staff description]];
    }
    result = [result stringByAppendingString:@"End SheetMusicPlay\n"];
    return result;
}

- (void)dealloc {
    [staffs release];
    [super dealloc];
}


@end
