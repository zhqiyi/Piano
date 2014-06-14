//
//  Piano.m
//  2DView
//
//  Created by zhengyw on 14-3-13.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import "Piano.h"


static int KeysPerOctave = 7;
static int MaxOctave = 7;

static int WhiteKeyWidth;  /** Width of a single white key */
static int WhiteKeyHeight; /** Height of a single white key */
static int BlackKeyWidth;  /** Width of a single black key */
static int BlackKeyHeight; /** Height of a single black key */
static int margin;         /** Margin at left and top */
static int BlackBorder;    /** The width of the black border around the keys */
static int blackKeyOffsets[10];  /** The x pixles of the black keys */

#define max(x, y) ((x) > (y) ? (x) : (y))
#define min(x, y) ((x) <= (y) ? (x) : (y))

/** @class Piano
 *
 * The Piano UIView is the panel at the top that displays the
 * piano, and highlights the piano notes during playback.
 * The main methods are:
 *
 * setMidiFile() - Set the Midi file to use for shading.  The Midi file
 *                 is needed to determine which notes to shade.
 *
 * shadeNotes() - Shade notes on the piano that occur at a given pulse time.
 *
 */
@implementation Piano


/** Initialize the Piano */
- (id)init {
    
    int screenwidth = [[UIScreen mainScreen] applicationFrame].size.height;
    
    screenwidth = screenwidth * [UIScreen mainScreen].scale;
    //   screenwidth = 600;
    screenwidth = screenwidth * 45/100;
    WhiteKeyWidth = (int)(screenwidth / (2.0 + KeysPerOctave * MaxOctave));
    if (WhiteKeyWidth % 2 != 0) {
        WhiteKeyWidth--;
    }
    margin = WhiteKeyWidth / 2;
    BlackBorder = WhiteKeyWidth / 2;
    WhiteKeyHeight = WhiteKeyWidth * 5;
    BlackKeyWidth = WhiteKeyWidth / 2;
    BlackKeyHeight = WhiteKeyHeight * 5 / 9;
    
    CGRect frame = CGRectMake(0, 0,
                              margin*2 + BlackBorder*2 + WhiteKeyWidth * KeysPerOctave * MaxOctave,
                              margin*2 + BlackBorder*3 + WhiteKeyHeight);
    self = [super initWithFrame:frame];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    //notes = nil;
    
    int nums[] = {
        WhiteKeyWidth - BlackKeyWidth/2 - 1,
        WhiteKeyWidth + BlackKeyWidth/2 - 1,
        2*WhiteKeyWidth - BlackKeyWidth/2,
        2*WhiteKeyWidth + BlackKeyWidth/2,
        4*WhiteKeyWidth - BlackKeyWidth/2 - 1,
        4*WhiteKeyWidth + BlackKeyWidth/2 - 1,
        5*WhiteKeyWidth - BlackKeyWidth/2,
        5*WhiteKeyWidth + BlackKeyWidth/2,
        6*WhiteKeyWidth - BlackKeyWidth/2,
        6*WhiteKeyWidth + BlackKeyWidth/2
    };
    for (int i = 0; i < 10; i++) {
        blackKeyOffsets[i] = nums[i];
    }
    
    gray1 = [UIColor colorWithRed:16/255.0 green:16/255.0 blue:16/255.0 alpha:1.0];
    gray2 = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1.0];
    gray3 = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    
    gray1 = [gray1 retain];
    gray2 = [gray2 retain];
    gray3 = [gray3 retain];
    
    shadeColor  = [UIColor colorWithRed:210/255.0
                                  green:205/255.0 blue:220/255.0 alpha:1.0];
    shadeColor = [shadeColor retain];
    shade2Color = [UIColor colorWithRed:150/255.0
                                  green:200/255.0 blue:220/255.0 alpha:1.0];
    shade2Color = [shade2Color retain];    
    showNoteLetters = NoteNameNone;

    
    width = margin*2 + BlackBorder*2 + WhiteKeyWidth * KeysPerOctave * MaxOctave;
    height = margin*2 + BlackBorder*2 + WhiteKeyHeight;
    
    
    return self;
}


/** Set the MidiFile to use.
 *  Save the list of midi notes. Each midi note includes the note Number
 *  and StartTime (in pulses), so we know which notes to shade given the
 *  current pulse time.
 */
- (void)setMidiFile:(MidiFile*)midifile withOptions:(MidiOptions*)options {
    [notes release]; notes = nil;
    useTwoColors = NO;
    if (midifile == nil) {
        return;
    }

    maxShadeDuration = [[midifile time] quarter] * 2;
    Array *tracks = [midifile changeMidiNotes:options];
    MidiTrack *track = [MidiFile combineToSingleTrack:tracks];
    notes = [[track notes] retain];

    /* We want to know which track the note came from.
     * Use the 'channel' field to store the track.
     */
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *t = [tracks get:tracknum];
        for (int i = 0; i < [[t notes] count]; i++) {
            MidiNote *note = [[t notes] get:i];
            [note setChannel:tracknum];
        }
    }

    /* When we have exactly two tracks, we assume this is a piano song,
     * and we use different colors for highlighting the left hand and
     * right hand notes.
     */
    useTwoColors = NO;
    if ([tracks count] == 2) {
        useTwoColors = YES;
    }

    showNoteLetters = options->showNoteLetters;
    shadeNumber = -1;
    
    
    [track release];
    [tracks release];
}

/** Set the colors to use for shading */
- (void)setShade:(UIColor*)s1 andShade2:(UIColor*)s2 {
    shadeColor = s1;
    shade2Color = s2;
}

/** Draw a line with the given color */
static void drawLine(UIColor *color, int x1, int y1, int x2, int y2) {
    //    UIBezierPath *path = [UIBezierPath bezierPath];
    //    [path setLineWidth:1];
    //    [path moveToPoint:CGPointMake(x1, y1)];
    //    [path moveToPoint:CGPointMake(x2, y2)];
    //    [color setStroke];
    //    [path stroke];
    
    CGContextRef     context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, x1, y1);
    CGContextAddLineToPoint(context, x2 ,y2);
    
    CGContextStrokePath(context);
    
}

/** Draw the outline of a 12-note (7 white note) piano octave */
- (void)drawOctaveOutline {
    int right = WhiteKeyWidth * KeysPerOctave;
    
    /* Draw the bounding rectangle, from C to B */
    drawLine(gray1, 0, 0, 0, WhiteKeyHeight);
    drawLine(gray1, right, 0, right, WhiteKeyHeight);
    // drawLine(gray1, 0, WhiteKeyHeight, right, WhiteKeyHeight);
    
    drawLine(gray3, right-1, 0, right-1, WhiteKeyHeight);
    drawLine(gray3, 1, 0, 1, WhiteKeyHeight);
    
    /* Draw the line between E and F */
    drawLine(gray1, 3*WhiteKeyWidth, 0, 3*WhiteKeyWidth, WhiteKeyHeight);
    drawLine(gray3, 3*WhiteKeyWidth - 1, 0, 3*WhiteKeyWidth - 1, WhiteKeyHeight);
    drawLine(gray3, 3*WhiteKeyWidth + 1, 0, 3*WhiteKeyWidth + 1, WhiteKeyHeight);
    
    /* Draw the sides/bottom of the black keys */
    for (int i = 0; i < 10; i += 2) {
        int x1 = blackKeyOffsets[i];
        int x2 = blackKeyOffsets[i+1];
        
        drawLine(gray1, x1, 0, x1, BlackKeyHeight);
        drawLine(gray1, x2, 0, x2, BlackKeyHeight);
        drawLine(gray1, x1, BlackKeyHeight, x2, BlackKeyHeight);
        
        drawLine(gray2, x1-1, 0, x1-1, BlackKeyHeight+1);
        drawLine(gray2, x2+1, 0, x2+1, BlackKeyHeight+1);
        drawLine(gray2, x1-1, BlackKeyHeight+1, x2+1, BlackKeyHeight+1);
        
        drawLine(gray3, x1-2, 0, x1-2, BlackKeyHeight+2);
        drawLine(gray3, x2+2, 0, x2+2, BlackKeyHeight+2);
        drawLine(gray3, x1-2, BlackKeyHeight+2, x2+2, BlackKeyHeight+2);
    }
    
    /* Draw the bottom-half of the white keys */
    for (int i = 1; i < KeysPerOctave; i++) {
        if (i == 3) {
            continue;  /* We draw the line between E and F above */
        }
        drawLine(gray1, i*WhiteKeyWidth, BlackKeyHeight, i*WhiteKeyWidth, WhiteKeyHeight);
        drawLine(gray2, i*WhiteKeyWidth - 1, BlackKeyHeight+1, i*WhiteKeyWidth - 1, WhiteKeyHeight);
        drawLine(gray3, i*WhiteKeyWidth + 1, BlackKeyHeight+1, i*WhiteKeyWidth + 1, WhiteKeyHeight);
        
    }
}

/** Draw an outline of the piano for 7 octaves */
- (void)drawOutline {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (int octave = 0; octave < MaxOctave; octave++) {
        //trans = [NSAffineTransform transform];
        
        CGContextTranslateCTM (context, (octave * WhiteKeyWidth * KeysPerOctave) , 0);
        
        //        [trans translateXBy:(octave * WhiteKeyWidth * KeysPerOctave) yBy:0];
        //        [trans concat];
        [self drawOctaveOutline];
        //        trans = [NSAffineTransform transform];
        //        [trans translateXBy:-(octave * WhiteKeyWidth * KeysPerOctave) yBy:0];
        //        [trans concat];
        CGContextTranslateCTM (context, -(octave * WhiteKeyWidth * KeysPerOctave) , 0);
    }
}

/* Draw the Black keys */
- (void)drawBlackKeys {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect;
    for (int octave = 0; octave < MaxOctave; octave++) {
        CGContextTranslateCTM (context, octave * WhiteKeyWidth * KeysPerOctave, 0);
        
        for (int i = 0; i < 10; i += 2) {
            int x1 = blackKeyOffsets[i];
            int x2 = blackKeyOffsets[i+1];
            rect = CGRectMake(x1, 0, BlackKeyWidth, BlackKeyHeight);
            [self fillRect:rect withColor:gray1];
            rect = CGRectMake(x1+1, BlackKeyHeight - BlackKeyHeight/8,
                              BlackKeyWidth-2, BlackKeyHeight/8);
            [self fillRect:rect withColor:gray2];
        }
        CGContextTranslateCTM (context, -(octave * WhiteKeyWidth * KeysPerOctave), 0);
    }
}


/* Draw the black border area surrounding the piano keys.
 * Also, draw gray outlines at the bottom of the white keys.
 */
- (void)drawBlackBorder {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect;
    
    int PianoWidth = WhiteKeyWidth * KeysPerOctave * MaxOctave;
    rect = CGRectMake(margin, margin, PianoWidth + BlackBorder*2, BlackBorder-2);
    [self fillRect:rect withColor:gray1];
    rect = CGRectMake(margin, margin, BlackBorder, WhiteKeyHeight + BlackBorder*3);
    [self fillRect:rect withColor:gray1];
    rect = CGRectMake(margin, margin + BlackBorder + WhiteKeyHeight,
                      BlackBorder*2 + PianoWidth, BlackBorder*2);
    [self fillRect:rect withColor:gray1];
    rect = CGRectMake(margin + BlackBorder + PianoWidth, margin,
                      BlackBorder, WhiteKeyHeight + BlackBorder*3);
    [self fillRect:rect withColor:gray1];
    
    drawLine(gray2, margin + BlackBorder, margin + BlackBorder - 1,
             margin + BlackBorder + PianoWidth, margin + BlackBorder - 1);
    
    CGContextTranslateCTM (context, margin + BlackBorder , margin + BlackBorder);
    
    for (int i = 0; i < KeysPerOctave * MaxOctave; i++) {
        rect = CGRectMake(i*WhiteKeyWidth + 1, WhiteKeyHeight + 2,
                          WhiteKeyWidth - 2, BlackBorder/2);
        [self fillRect:rect withColor:gray2];
    }
    
    CGContextTranslateCTM (context, -(margin + BlackBorder) , -(margin + BlackBorder));
}


/** Draw the note letters (A, A#, Bb, etc) underneath each white note */
- (void)drawNoteLetters {
    NSArray *letters;
    if (showNoteLetters == NoteNameLetter) {
        letters = [NSArray arrayWithObjects:
                   @"C", @"D", @"E", @"F", @"G", @"A", @"B", nil
                   ];
    }
    else if (showNoteLetters == NoteNameFixedNumber) {
        letters = [NSArray arrayWithObjects:
                   @"1", @"3", @"5", @"6", @"8", @"10", @"12", nil
                   ];
    }
    else {
        return;
    }
    //        NSGraphicsContext *gc = [NSGraphicsContext currentContext];
    //        [gc setShouldAntialias:YES];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
    
    /* Set the font attribute */
    UIFont *font = [UIFont boldSystemFontOfSize:12.0];
    NSArray *keys = [NSArray arrayWithObjects:
                     NSFontAttributeName, NSForegroundColorAttributeName, nil];
    NSArray *values = [NSArray arrayWithObjects:font, [UIColor whiteColor], nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    //        NSAffineTransform *trans;
    //
    //        trans = [NSAffineTransform transform];
    //        [trans translateXBy:(margin + BlackBorder) yBy:(margin + BlackBorder)];
    //        [trans concat];
    CGContextTranslateCTM(context, (margin + BlackBorder), (margin + BlackBorder));
    for (int octave = 0; octave < MaxOctave; octave++) {
        for (int i = 0; i < KeysPerOctave; i++) {
            CGPoint point = CGPointMake((octave*KeysPerOctave + i) * WhiteKeyWidth + WhiteKeyWidth/3,
                                        WhiteKeyHeight + BlackBorder * 3/4);
            NSString *letter = [letters objectAtIndex:i];
            [letter drawAtPoint:point withAttributes:dict];
        }
    }
    //        trans = [NSAffineTransform transform];
    //        [trans translateXBy:-(margin + BlackBorder) yBy:-(margin + BlackBorder)];
    //        [trans concat];
    CGContextTranslateCTM(context, -(margin + BlackBorder), -(margin + BlackBorder));
    [[UIColor blackColor] set];
    //        [gc setShouldAntialias:NO];
    CGContextSetShouldAntialias(context, NO);
}


/** Draw the Piano */
- (void)drawRect:(CGRect)rect {

    //    UIGraphicsPushContext(pContext);
    //    [context setShouldAntialias:NO];
    UIColor *blue = [UIColor colorWithRed:80.f/255.f
                                    green:150.f/255.f
                                     blue:225.f/255.f
                                    alpha:1];
    
    
    /* Draw a border line at the top */
    drawLine(blue, 0, 0, [self frame].size.width, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
        CGContextClearRect(context, rect);
    
    
    CGContextTranslateCTM (context, (margin + BlackBorder), (margin + BlackBorder));
    CGRect backrect = CGRectMake(0, 0,
                                 WhiteKeyWidth * KeysPerOctave * MaxOctave,
                                 WhiteKeyHeight);
    [self fillRect:backrect withColor:[UIColor whiteColor]];
    [[UIColor blackColor] setFill];
    [self drawBlackKeys];
    [self drawOutline];
    
    
    if (shadeNumber != -1) {
        [self shadeOneNote:shadeNumber withColor:shadeColorEx];
    }
    
    
    CGContextTranslateCTM (context, -(margin + BlackBorder), -(margin + BlackBorder));
    
    [self drawBlackBorder];
    //    if (showNoteLetters != NoteNameNone) {
    //        [self drawNoteLetters];
    //    }
    //    [gc setShouldAntialias:YES];
}


/** Fill in a rectangle with the given color */
- (void)fillRect:(CGRect)rect withColor:(UIColor*)color {
    
    [color setFill];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [path fill];

//    [self setNeedsDisplayInRect:rect];
}

/* Shade the given note with the given brush.
 * We only draw notes from notenumber 24 to 96.
 * (Middle-C is 60).
 */
- (void)shadeOneNote:(int)notenumber withColor:(UIColor*)color {
        int octave = notenumber / 12;
        int notescale = notenumber % 12;
    
        octave -= 2;
        if (octave < 0 || octave >= MaxOctave)
            return;

    
    
    
//        NSAffineTransform *trans;
//        trans = [NSAffineTransform transform];
//        [trans translateXBy:(octave * WhiteKeyWidth * KeysPerOctave) yBy:0];
//        [trans concat];
CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM (context, (octave * WhiteKeyWidth * KeysPerOctave), 0);
    
        int x1, x2, x3;
    
        int bottomHalfHeight = WhiteKeyHeight - (BlackKeyHeight+3);
    
        /* notescale goes from 0 to 11, from C to B. */
        switch (notescale) {
        case 0: /* C */
            x1 = 2;
            x2 = blackKeyOffsets[0] - 2;
            [self fillRect:CGRectMake(x1, 0, x2 - x1, BlackKeyHeight+3) withColor:color];
            [self fillRect:CGRectMake(x1, BlackKeyHeight+3, WhiteKeyWidth-3, bottomHalfHeight) withColor:color];
            break;
        case 1: /* C# */
            x1 = blackKeyOffsets[0];
            x2 = blackKeyOffsets[1];
            [self fillRect:CGRectMake(x1, 0, x2 - x1, BlackKeyHeight) withColor:color];
            if (color == gray1) {
                [self fillRect:CGRectMake(x1+1, BlackKeyHeight - BlackKeyHeight/8,
                                BlackKeyWidth-2, BlackKeyHeight/8)
                                withColor:gray2];
            }
            break;
        case 2: /* D */
            x1 = WhiteKeyWidth + 2;
            x2 = blackKeyOffsets[1] + 3;
            x3 = blackKeyOffsets[2] - 2;
            [self fillRect:CGRectMake(x2, 0, x3 - x2, BlackKeyHeight+3) withColor:color];
            [self fillRect:CGRectMake(x1, BlackKeyHeight+3, WhiteKeyWidth-3, bottomHalfHeight) withColor:color];
            break;
        case 3: /* D# */
            x1 = blackKeyOffsets[2];
            x2 = blackKeyOffsets[3];
            [self fillRect:CGRectMake(x1, 0, BlackKeyWidth, BlackKeyHeight) withColor:color];
            if (color == gray1) {
                [self fillRect:CGRectMake(x1+1, BlackKeyHeight - BlackKeyHeight/8,
                                           BlackKeyWidth-2, BlackKeyHeight/8)
                                           withColor:gray2];
            }
            break;
        case 4: /* E */
            x1 = WhiteKeyWidth * 2 + 2;
            x2 = blackKeyOffsets[3] + 3;
            x3 = WhiteKeyWidth * 3 - 1;
            [self fillRect:CGRectMake(x2, 0, x3 - x2, BlackKeyHeight+3) withColor:color];
            [self fillRect:CGRectMake(x1, BlackKeyHeight+3, WhiteKeyWidth-3, bottomHalfHeight) withColor:color];
            break;
        case 5: /* F */
            x1 = WhiteKeyWidth * 3 + 2;
            x2 = blackKeyOffsets[4] - 2;
            x3 = WhiteKeyWidth * 4 - 2;
            [self fillRect:CGRectMake(x1, 0, x2 - x1, BlackKeyHeight+3) withColor:color];
            [self fillRect:CGRectMake(x1, BlackKeyHeight+3, WhiteKeyWidth-3, bottomHalfHeight) withColor:color];
            break;
        case 6: /* F# */
            x1 = blackKeyOffsets[4];
            x2 = blackKeyOffsets[5];
            [self fillRect:CGRectMake(x1, 0, BlackKeyWidth, BlackKeyHeight) withColor:color];
            if (color == gray1) {
                [self fillRect:CGRectMake(x1+1, BlackKeyHeight - BlackKeyHeight/8,
                                           BlackKeyWidth-2, BlackKeyHeight/8)
                                           withColor:gray2];
            }
            break;
        case 7: /* G */
            x1 = WhiteKeyWidth * 4 + 2;
            x2 = blackKeyOffsets[5] + 3;
            x3 = blackKeyOffsets[6] - 2;
            [self fillRect:CGRectMake(x2, 0, x3 - x2, BlackKeyHeight+3) withColor:color];
            [self fillRect:CGRectMake(x1, BlackKeyHeight+3, WhiteKeyWidth-3, bottomHalfHeight) withColor:color];
            break;
        case 8: /* G# */
            x1 = blackKeyOffsets[6];
            x2 = blackKeyOffsets[7];
            [self fillRect:CGRectMake(x1, 0, BlackKeyWidth, BlackKeyHeight) withColor:color];
            if (color == gray1) {
                [self fillRect:CGRectMake(x1+1, BlackKeyHeight - BlackKeyHeight/8,
                                           BlackKeyWidth-2, BlackKeyHeight/8)
                                           withColor:gray2];
            }
            break;
        case 9: /* A */
            x1 = WhiteKeyWidth * 5 + 2;
            x2 = blackKeyOffsets[7] + 3;
            x3 = blackKeyOffsets[8] - 2;
            [self fillRect:CGRectMake(x2, 0, x3 - x2, BlackKeyHeight+3) withColor:color];
            [self fillRect:CGRectMake(x1, BlackKeyHeight+3, WhiteKeyWidth-3, bottomHalfHeight) withColor:color];
            break;
        case 10: /* A# */
            x1 = blackKeyOffsets[8];
            x2 = blackKeyOffsets[9];
            [self fillRect:CGRectMake(x1, 0, BlackKeyWidth, BlackKeyHeight) withColor:color];
            if (color == gray1) {
                [self fillRect:CGRectMake(x1+1, BlackKeyHeight - BlackKeyHeight/8,
                                           BlackKeyWidth-2, BlackKeyHeight/8)
                                           withColor:gray2];
            }
            break;
        case 11: /* B */
            x1 = WhiteKeyWidth * 6 + 2;
            x2 = blackKeyOffsets[9] + 3;
            x3 = WhiteKeyWidth * KeysPerOctave - 1;
            [self fillRect:CGRectMake(x2, 0, x3 - x2, BlackKeyHeight+3) withColor:color];
            [self fillRect:CGRectMake(x1, BlackKeyHeight+3, WhiteKeyWidth-3, bottomHalfHeight) withColor:color];
            break;
        default:
            break;
        }
//        trans = [NSAffineTransform transform];
//        [trans translateXBy:-(octave * WhiteKeyWidth * KeysPerOctave) yBy:0];
//        [trans concat];
    CGContextTranslateCTM (context, -(octave * WhiteKeyWidth * KeysPerOctave), 0);
    

}

/** Find the symbol with the startTime closest to the given time.
 *  Return the index of the symbol.  Use a binary search method.
 */
- (int)findClosestStartTime:(int)pulseTime {
    int left = 0;
    int right = [notes count] - 1;

    while (right - left > 1) {
        int i = (right + left)/2;
        if ([[notes get:left] startTime] == pulseTime)
            break;
        else if ([[notes get:i] startTime] <= pulseTime)
           left = i;
        else
            right = i;
    }
    while (left >= 1 && ([[notes get:left-1] startTime] == [[notes get:left] startTime])) {
        left--;
    }
    return left;
}


/** Return the next startTime that occurs after the MidiNote
 *  at offset i.  If all the subsequent notes have the same
 *  startTime, then return the largest endTime.
 */
- (int)nextStartTime:(int)i {
    int start = [(MidiNote*)[notes get:i] startTime];
    int end = [(MidiNote*)[notes get:i] endTime];

    while (i < [notes count]) {
        if ([[notes get:i] startTime] > start) {
            return [(MidiNote*)[notes get:i] startTime];
        }
        int end2 = [(MidiNote*)[notes get:i] endTime];
        end = max(end, end2);
        i++;
    }
    return end;
}


/** Return the next startTime that occurs after the MidiNote
 *  at offset i, that is also in the same track/channel.
 */
- (int)nextStartTimeSameTrack:(int)i {
    int start = [(MidiNote*)[notes get:i] startTime];
    int end = [(MidiNote*)[notes get:i] endTime];
    int track = [(MidiNote*)[notes get:i] channel];

    while (i < [notes count]) {
        if ([(MidiNote*)[notes get:i] channel] != track) {
            i++;
            continue;
        }
        if ([(MidiNote*)[notes get:i] startTime] > start) {
            return [(MidiNote*)[notes get:i] startTime];
        }
        int end2 = [(MidiNote*)[notes get:i] endTime];
        end = max(end, end2);
        i++;
    }
    return end;
}


/** Find the Midi notes that occur in the current time.
 *  Shade those notes on the piano displayed.
 *  Un-shade the those notes played in the previous time.
 */
- (void)shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime {
    if (notes == nil || [notes count] == 0) {
        return;
    }
//    if (![self canDraw]) {
//        return;
//    }
//    [self lockFocus];
//
//    NSGraphicsContext *gc = [NSGraphicsContext currentContext];
//    [gc setShouldAntialias:NO];
//
//    NSAffineTransform *trans = [NSAffineTransform transform];
//    [trans translateXBy:(margin + BlackBorder) yBy:(margin + BlackBorder)];
//    [trans concat];

    
    /* Loop through the Midi notes.
     * Unshade notes where startTime <= prevPulseTime < next startTime
     * Shade notes where startTime <= currentPulseTime < next startTime
     */
    int lastShadedIndex = [self findClosestStartTime:(prevPulseTime - maxShadeDuration*2)];
    for (int i = lastShadedIndex; i < [notes count]; i++) {
        int start = [(MidiNote*)[notes get:i] startTime];
        int end = [(MidiNote*)[notes get:i] endTime];
        int notenumber = [(MidiNote*)[notes get:i] number];

        shadeNumber = notenumber;
        
        int nextStart = [self nextStartTime:i];
        int nextStartTrack = [self nextStartTimeSameTrack:i];
        end = max(end, nextStartTrack);
        end = min(end, start + maxShadeDuration-1);

        /* If we've past the previous and current times, we're done. */
        if ((start > prevPulseTime) && (start > currentPulseTime)) {
            break;
        }

        /* If shaded notes are the same, we're done */
        if ((start <= currentPulseTime) && (currentPulseTime < nextStart) &&
            (currentPulseTime < end) &&
            (start <= prevPulseTime) && (prevPulseTime < nextStart) &&
            (prevPulseTime < end)) {
            break;
        }

        /* If the note is in the current time, shade it */
        if ((start <= currentPulseTime) && (currentPulseTime < end)) {
            if (useTwoColors) {
                if ([(MidiNote*)[notes get:i] channel] == 1) {
                    shadeColorEx = shade2Color;
//                    [self shadeOneNote:notenumber withColor:shade2Color];
                }
                else {
                    shadeColorEx = shadeColor;
//                    [self shadeOneNote:notenumber withColor:shadeColor];
                }
                [self setNeedsDisplay];
            }
            else {
                shadeColorEx = shadeColor;
//                [self shadeOneNote:notenumber withColor:shadeColor];
                [self setNeedsDisplay];
            }
        }

        /* If the note is in the previous time, un-shade it, draw it white. */
        else if ((start <= prevPulseTime) && (prevPulseTime < end)) {
            int num = notenumber % 12;
            if (num == 1 || num == 3 || num == 6 || num == 8 || num == 10) {
                shadeColorEx = gray1;
//                [self shadeOneNote:notenumber withColor:gray1] ;
            }
            else {
                shadeColorEx = [UIColor whiteColor];;
//                [self shadeOneNote:notenumber withColor:[UIColor whiteColor]];
            }
            [self setNeedsDisplay];
        }
    }
//    trans = [NSAffineTransform transform];
//    [trans translateXBy:-(margin + BlackBorder) yBy:-(margin + BlackBorder)];
//    [trans concat];
//    [[NSGraphicsContext currentContext] flushGraphics];
//    [[NSGraphicsContext currentContext] setShouldAntialias:NO];
//    [self unlockFocus];

    
    
}

/** Use flipped coordinates */
- (BOOL)isFlipped {
    return YES;
}

- (void)dealloc {
        [notes release]; notes = nil;
        [gray1 release]; gray1 = nil;
        [gray2 release]; gray1 = nil;
        [gray3 release]; gray1 = nil;
        [super dealloc];
}

@end



