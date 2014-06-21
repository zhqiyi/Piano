/*
 * Copyright (c) 2009-2011 Madhav Vaidyanathan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */


#import "Staff.h"
#import "SheetMusic.h"
#import "AccidSymbol.h"
#import "BarSymbol.h"
#import "LyricSymbol.h"

#define max(x,y) ((x) > (y) ? (x) : (y))

/** @class Staff
 * The Staff is used to draw a single Staff (a row of measures) in the 
 * SheetMusic Control. A Staff needs to draw
 * - The Clef
 * - The key signature
 * - The horizontal lines
 * - A list of MusicSymbols
 * - The left and right vertical lines
 *
 * The height of the Staff is determined by the number of pixels each
 * MusicSymbol extends above and below the staff.
 *
 * The vertical lines (left and right sides) of the staff are joined
 * with the staffs above and below it, with one exception.
 * The last track is not joined with the first track.
 */
@implementation Staff


/** Create a new staff with the given list of music symbols,
 * and the given key signature.  The clef is determined by
 * the clef of the first chord symbol. The track number is used
 * to determine whether to join this left/right vertical sides
 * with the staffs above and below. The MidiOptions are used
 * to check whether to display measure numbers or not.
 */
- (id)initWithSymbols:(Array*)musicsymbols andKey:(KeySignature*)key
     andOptions:(MidiOptions*)options
     andTrack:(int)trknum andTotalTracks:(int)total andSheet:(void *)s {

    /** add by yizhq start */
    self->sheetmusic = s;
    keysigWidth = [SheetMusic keySignatureWidth:key];
    symbols = [musicsymbols retain];
    tracknum = trknum;
    totaltracks = total;
    showMeasures = (options->showMeasures && tracknum == 0);
    measureLength  = [options->time measure];
    int clef = [self findClef];
    clefsym = [[ClefSymbol alloc] initWithClef:clef andTime:0 isSmall:NO];
    keys = [[key getSymbols:clef] retain];
    [self calculateWidth:options->scrollVert];
    [self calculateHeight];
    [self calculateStartEndTime];

    [self fullJustify];
    
    isEnd = FALSE;
    return self;
}

/** Return the width of the staff */
- (int)width {
    return width;
}

/** Return the height of the staff */
- (int)height {
    return height;
}

/** Return the track number of this staff (starting from 0) */
- (int)track {
    return tracknum;
}

/** Return the starting time of the staff, the start time of
 *  the first symbol.  This is used during playback, to
 *  automatically scroll the music while playing.
 */
- (int)startTime {
    return starttime;
}

/** Return the ending time of the staff, the endtime of
 *  the last symbol.  This is used during playback, to
 *  automatically scroll the music while playing.
 */
- (int)endTime {
    return endtime;
}

- (void)setEndTime:(int)value {
    endtime = value;
}

- (int)tracknum {
    return tracknum;
}

/** add by sunlie start */
-(Array*)symbols {
    return symbols;
}

-(void)setHeight:(int)h {
    height = h;
}
/** add by sunlie end */

-(void)setIsEnd:(BOOL)b
{
    isEnd = b;
}


/** Find the initial clef to use for this staff.  Use the clef of
 * the first ChordSymbol.
 */
- (int)findClef {
    int i;
    for (i = 0;  i < [symbols count]; i++) {
        NSObject *m = [symbols get:i];
        if ([m isMemberOfClass:[ChordSymbol class]]) {
        /* if ([m respondsToSelector:@selector(hasTwoStems)]) { */
            ChordSymbol *c = (ChordSymbol*) m;
            return [c clef];
        }
    }
    return Clef_Treble;
}

/** Calculate the height of this staff.  Each MusicSymbol contains the
 * number of pixels it needs above and below the staff.  Get the maximum
 * values above and below the staff.
 */
- (void) calculateHeight {
    int above = 0;
    int below = 0;

    int i;
    for (i = 0; i < [symbols count]; i++) {
        id <MusicSymbol> s = [symbols get:i];
        above = max(above, [s aboveStaff]);
        below = max(below, [s belowStaff]);
    }
    above = max(above, [clefsym aboveStaff]);
    below = max(below, [clefsym belowStaff]);
    ytop = above + NoteHeight;
    height = NoteHeight*5 + ytop + below;
    if (showMeasures || lyrics != nil) {
        height += NoteHeight * 3/2;
    }

    /* Add some extra vertical space between the last track
     * and first track.
     */
    if (tracknum == totaltracks-1)
        height += NoteHeight * 3;
    
    
}

/** Calculate the width of this staff */
-(void)calculateWidth:(BOOL)scrollVert {
    if (scrollVert) {
        width = PageWidth;
        return;
    }
    width = keysigWidth;
    for (int i = 0; i < [symbols count]; i++) {
        id <MusicSymbol> s = [symbols get:i];
        width += [s width];
    }
}


/** Calculate the start and end time of this staff. */
- (void)calculateStartEndTime {
    starttime = endtime = 0;
    if ([symbols count] == 0) {
        return;
    }
    starttime = [(id <MusicSymbol>)[symbols get:0] startTime];
    for (int i = 0; i < [symbols count]; i++) {
        NSObject <MusicSymbol> *m = [symbols get:i];
        if (endtime < [m startTime]) {
            endtime = [m startTime];
        }
        
        if ([m isKindOfClass:[ChordSymbol class]]) {
            ChordSymbol *c = (ChordSymbol*) m;
            if (endtime < [c endTime]) {
                endtime = [c endTime];
            }
        }
    }
}


/** Full-Justify the symbols, so that they expand to fill the whole staff. */
- (void)fullJustify {
    if (width != PageWidth)
        return;

    int totalwidth = keysigWidth;
    int totalsymbols = 0;
    int i = 0;

    while (i < [symbols count]) {
        id <MusicSymbol> symbol = [symbols get:i];
        int start = [symbol startTime];
        totalsymbols++;
        totalwidth += [symbol width];
        i++;

        while (i < [symbols count]) {
            symbol = [symbols get:i];
            if ([symbol startTime] != start) {
                break;
            }
            totalwidth += [symbol width];
            i++;
        }
    }

    int extrawidth = (PageWidth - totalwidth - 1) / totalsymbols;
    if (extrawidth > NoteHeight*2) {
        extrawidth = NoteHeight*2;
    }
    i = 0;
    while (i < [symbols count]) {
        id <MusicSymbol> symbol = [symbols get:i];
        int start = [symbol startTime];
        [symbol setWidth:[symbol width] + extrawidth];
        i++;
        while (i < [symbols count]) {
            id <MusicSymbol> symbol = [symbols get:i];
            if ([symbol startTime] != start) {
                break;
            }
            i++;
        }
    }
}


/** Add the lyric symbols that occur within this staff.
 *  Set the x-position of the lyric symbol.
 */
-(void)addLyrics:(Array*)tracklyrics {
    if (tracklyrics == nil || [tracklyrics count] == 0) {
        return;
    }
    lyrics = [Array new:5];
    int xpos = 0;
    int symbolindex = 0;
    for (int i = 0; i < [tracklyrics count]; i++) {
        LyricSymbol *lyric = (LyricSymbol*)[tracklyrics get:i];
        if ([lyric startTime] < starttime) {
            continue;
        }
        if ([lyric startTime] > endtime) {
            break;
        }
        /* Get the x-position of this lyric */
        while (symbolindex < [symbols count] &&
               [(id<MusicSymbol>)[symbols get:symbolindex] startTime] < [lyric startTime]) {
            xpos += [(id<MusicSymbol>)[symbols get:symbolindex] width];
            symbolindex++;
        }
        [lyric setX:xpos];
        if (symbolindex < [symbols count] &&
            ([[symbols get:symbolindex] isKindOfClass:[BarSymbol class]])) {

            [lyric setX: [lyric x] + NoteWidth];
        }
        [lyrics add:lyric];
    }
    if ([lyrics count] == 0) {
        lyrics = nil;
    }
}

/** Draw the lyrics */
-(void)drawLyrics:(CGContextRef)context {
    /* Skip the left side Clef symbol and key signature */
    int xpos = keysigWidth;
    int ypos = height - NoteHeight*3/2;

    for (int i = 0; i < [lyrics count]; i++) {
        LyricSymbol *lyric = [lyrics get:i];
        CGPoint point = CGPointMake(xpos + [lyric x], ypos);
        [[lyric text] drawAtPoint:point withAttributes:[SheetMusic fontAttributes]];
    }
}



/** Draw the measure numbers for each measure */
-(void)drawMeasureNumbers:(CGContextRef)context {
    /* Skip the left side Clef symbol and key signature */
    int xpos = keysigWidth;
    int ypos = height - NoteHeight*3/2;

    for (int i = 0; i < [symbols count]; i++) {
        NSObject<MusicSymbol> *s = [symbols get:i];
        if ([s isKindOfClass:[BarSymbol class]]) {
            int measure = 1 + [s startTime] / measureLength;
            CGPoint point = CGPointMake(xpos + NoteWidth, ypos);
            NSString *num = [NSString stringWithFormat:@"%d", measure];
            [num drawAtPoint:point withAttributes:[SheetMusic fontAttributes]];
        }
        xpos += [s width];
    }
}

/** add by yizhq start */
/** Draw the five horizontal lines of the staff */
- (void)drawHorizLines:(CGContextRef)context withOptions:(MidiOptions *)options{
    int line = 1;
    int y = ytop - 1;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (options->staveModel == 1) {
        [[UIColor grayColor] setFill];
    }else{
        [[UIColor blackColor] setFill];
    }
    for (line = 1; line <= 5; line++) {
        [path moveToPoint:CGPointMake(LeftMargin, y)];
        [path addLineToPoint:CGPointMake(width-1, y)];
        y += LineWidth + LineSpace;
    }
    [path stroke];
}
/** add by yizhq end */
/** Draw the five horizontal lines of the staff */
- (void)drawHorizLines:(CGContextRef)context {
    int line = 1;
    int y = ytop - 1;

    UIBezierPath *path = [UIBezierPath bezierPath];
    for (line = 1; line <= 5; line++) {
        [path moveToPoint:CGPointMake(LeftMargin, y)];
        [path addLineToPoint:CGPointMake(width-1, y)];
        y += LineWidth + LineSpace;
    }
    [path stroke];
//    [[UIColor blackColor] setStroke];
}

/** Draw the vertical lines at the far left and far right sides. */
- (void)drawEndLines:(CGContextRef)context {
    /* Draw the vertical lines from 0 to the height of this staff,
     * including the space above and below the staff, with two exceptions:
     * - If this is the first track, don't start above the staff.
     *   Start exactly at the top of the staff (ytop - LineWidth)
     * - If this is the last track, don't end below the staff.
     *   End exactly at the bottom of the staff.
     */
    int ystart, yend;
    if (tracknum == 0)
        ystart = ytop - LineWidth;
    else
        ystart = 0;

    if (tracknum == (totaltracks-1))
        yend = ytop + 4 * NoteHeight;
    else
        yend = height;

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(LeftMargin, ystart)];
    [path addLineToPoint:CGPointMake(LeftMargin, yend)];
    
    if (isEnd) {
        [path moveToPoint:CGPointMake(width-5, ystart)];
        [path addLineToPoint:CGPointMake(width-5, yend)];
    }
    
    [path moveToPoint:CGPointMake(width-1, ystart)];
    [path addLineToPoint:CGPointMake(width-1, yend)];
    [path stroke];
}

-(UIColor *)colorWithHexValue:(NSUInteger)hexValue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:((hexValue >> 16) & 0x00000FF)/255.0f green:((hexValue >> 8) & 0x00000FF)/255.0f blue:(hexValue & 0x00000FF)/255.0f alpha:alpha ];
}

/** add by yizhq start */
-(void)drawRect:(CGContextRef)context InRect:(CGRect)clip withOptions:(MidiOptions *)options{
    
    SheetMusic *sheet = (SheetMusic *)(self->sheetmusic);
    if (options->staveModel == 1) {
        CGContextSetRGBStrokeColor(context, 200/255.0, 200/255.0, 200/255.0, 1);
        [sheet setColors4Section:FALSE];
    }else{
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
        [sheet setColors4Section:TRUE];
    }
    
    
    [self drawHorizLines:context];
    [self drawEndLines:context];
    
    if (showMeasures) {
        [self drawMeasureNumbers:context];
    }
    if (lyrics != nil) {
        [self drawLyrics:context];
    }
    
    int xpos = LeftMargin + 5;
    
    /* Draw the left side Clef symbol */
    CGContextTranslateCTM (context, xpos, 0.0);
    [clefsym draw:context atY:ytop];
    CGContextTranslateCTM (context, -xpos, 0.0);
    
    xpos += [clefsym width];
    
    /* Draw the key signature */
    int i;
    for (i = 0; i < [keys count]; i++) {
        AccidSymbol *a = [keys get:i];
        CGContextTranslateCTM (context, xpos, 0.0);
        [a draw:context atY:ytop];
        CGContextTranslateCTM (context, -xpos, 0.0);
        
        xpos += [a width];
    }

    BOOL endFlag = FALSE;
    for (i = 0; i < [symbols count]; i++) {

        id <MusicSymbol> s = [symbols get:i];
        if (options->staveModel == 1) {
            if (endFlag == FALSE) {
                if (options->startSecTime != 0) {
                    if (options->startSecTime <= [s startTime] && [s startTime] <= options->endSecTime) {
                        CGContextSetRGBStrokeColor(context, 0/255.0, 0/255.0, 0/255.0, 1);
                        [sheet setColors4Section:TRUE];
                    }else{
                        CGContextSetRGBStrokeColor(context, 200/255.0, 200/255.0, 200/255.0, 1);
                        [sheet setColors4Section:FALSE];
                    }
                }else{
                    if ([s startTime] <= options->endSecTime) {
                        CGContextSetRGBStrokeColor(context, 0/255.0, 0/255.0, 0/255.0, 1);
                                                [sheet setColors4Section:TRUE];
                    }else{
                        CGContextSetRGBStrokeColor(context, 200/255.0, 200/255.0, 200/255.0, 1);
                                                [sheet setColors4Section:FALSE];
                    }
                }
            }else{
                //结束后第一个symbol
                if([s startTime] >= options->startSecTime && [s startTime] < options->endSecTime){
                    CGContextSetRGBStrokeColor(context, 0/255.0, 0/255.0, 0/255.0, 1);
                                            [sheet setColors4Section:TRUE];
                }else{
                    CGContextSetRGBStrokeColor(context, 200/255.0, 200/255.0, 200/255.0, 1);
                                            [sheet setColors4Section:FALSE];
                }
                endFlag = FALSE;
            }

        }else{
            CGContextSetRGBStrokeColor(context, 0/255.0, 0/255.0, 0/255.0, 1);
        }

        if ([s isKindOfClass:[BarSymbol class]]) {
            BarSymbol *b = (BarSymbol*)s;
            [b setTotalTracks:totaltracks];
            [b setStraffHeight:height];
            [b setTrackNum:tracknum];
            endFlag = TRUE;
        }
        
        if ((xpos <= clip.origin.x + clip.size.width + 50) &&
            (xpos + [s width] + 50 >= clip.origin.x)) {
            CGContextTranslateCTM (context, xpos, 0.0);
            [s draw:context atY:ytop];
            CGContextTranslateCTM (context, -xpos, 0.0);
        }

        xpos += [s width];
    }
    
    CGContextSetRGBStrokeColor(context, 0/255.0, 0/255.0, 0/255.0, 1);
    [self drawHorizLines:context];
    [self drawEndLines:context];
}
/** add by yizhq start */

/** Draw this staff. Only draw the symbols inside the clip area. */
- (void)drawRect:(CGContextRef)context InRect:(CGRect)clip {
    int xpos = LeftMargin + 5;

    /* Draw the left side Clef symbol */
    CGContextTranslateCTM (context, xpos, 0.0);
    [clefsym draw:context atY:ytop];
    CGContextTranslateCTM (context, -xpos, 0.0);

    xpos += [clefsym width];

    /* Draw the key signature */
    int i;
    for (i = 0; i < [keys count]; i++) {
        AccidSymbol *a = [keys get:i];
        CGContextTranslateCTM (context, xpos, 0.0);
        [a draw:context atY:ytop];
        CGContextTranslateCTM (context, -xpos, 0.0);
        
        xpos += [a width];
    }


    /* Draw the actual notes, rests, bars.  Draw the symbols one 
     * after another, using the symbol width to determine the
     * x position of the next symbol.
     *
     * For fast performance, only draw symbols that are in the clip area.
     */
    for (i = 0; i < [symbols count]; i++) {
        id <MusicSymbol> s = [symbols get:i];
        if ([s isKindOfClass:[BarSymbol class]]) {
            BarSymbol *b = (BarSymbol*)s;
            [b setTotalTracks:totaltracks];
            [b setStraffHeight:height];
            [b setTrackNum:tracknum];
        }
        
        if ((xpos <= clip.origin.x + clip.size.width + 50) &&
            (xpos + [s width] + 50 >= clip.origin.x)) {
            CGContextTranslateCTM (context, xpos, 0.0);
            [s draw:context atY:ytop];
            CGContextTranslateCTM (context, -xpos, 0.0);
        }
        xpos += [s width];
    }
    [self drawHorizLines:context];
    [self drawEndLines:context];

    if (showMeasures) {
        [self drawMeasureNumbers:context];
    }
    if (lyrics != nil) {
        [self drawLyrics:context];
    }
}

- (void)cleanShadeNote
{
    shadeXpos = 0;
    shadeCurr = nil;
}


- (void) shadeNotes:(CGContextRef)context withColor: (UIColor *)color {
    
    NSLog(@"======== shadeNotes");
    if (shadeCurr == nil) return;
    
    CGContextTranslateCTM (context, shadeXpos, 0);
    
    [color setFill];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:
                          CGRectMake(0, 0, [shadeCurr width], [self height]) ];
    [path fill];
    
    
    CGContextTranslateCTM (context, -shadeXpos, 0);
    
    
    
}


/** Shade all the chords played in the given time.
 *  Un-shade any chords shaded in the previous pulse time.
 *  Store the x coordinate location where the shade was drawn.
 */
- (int) calcShadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime andX:(int *)x_shade {
    //NSAffineTransform *trans;
    
    /* If there's nothing to unshade, or shade, return */
    if ((starttime > prevPulseTime || endtime < prevPulseTime) &&
        (starttime > currentPulseTime || endtime < currentPulseTime)) {
        shadeCurr = nil;
        return -1;
    }

    /* Skip the left side Clef symbol and key signature */
//    int xpos = keysigWidth;
    shadeXpos = keysigWidth;

//    id <MusicSymbol> curr = nil;
//    ChordSymbol* prevChord = nil;
//    int prev_xpos = 0;
    shadeCurr = nil;
    
    /* Loop through the symbols.
     * Unshade symbols where startTime <= prevPulseTime < end
     * Shade symbols where startTime <= currentPulseTime < end
     */
    for (int i = 0; i < [symbols count]; i++) {
        shadeCurr = [symbols get:i];
        if ([shadeCurr isKindOfClass:[BarSymbol class]]) {
            shadeXpos += [shadeCurr width];
            continue;
        }

        int start = [shadeCurr startTime];
        int end = 0;
        if (i+2 < [symbols count] && [[symbols get:i+1] isKindOfClass:[BarSymbol class]]) {
            end = [(id <MusicSymbol>)[symbols get:i+2] startTime];
        }
        else if (i+1 < [symbols count]) {
            end = [(id <MusicSymbol>)[symbols get:i+1] startTime];
        }
        else {
            end = endtime;
        }

        /* If we've past the previous and current times, we're done. */
        if ((start > prevPulseTime) && (start > currentPulseTime)) {
            if (*x_shade == 0) {
                *x_shade = shadeXpos;
            }
            return -1;
        }
        /* If shaded notes are the same, we're done */
        if ((start <= currentPulseTime) && (currentPulseTime < end) &&
            (start <= prevPulseTime) && (prevPulseTime < end)) {

            *x_shade = shadeXpos;
            return -1;
        }

//        BOOL redrawLines = FALSE;
//
//        /* If symbol is in the previous time, draw a white background */
//        if ((start <= prevPulseTime) && (prevPulseTime < end)) {
////            trans = [NSAffineTransform transform];
////            [trans translateXBy:xpos-2 yBy:-2];
////            [trans concat];
//            CGContextTranslateCTM (context, xpos-2, -2);
//            
//            [[UIColor whiteColor] setFill];
//            UIBezierPath *path = [UIBezierPath bezierPathWithRect:
//                CGRectMake(0, 0, [curr width]+4, [self height] + 4) ];
//            [path fill];
////            trans = [NSAffineTransform transform];
////            [trans translateXBy:-(xpos-2) yBy:2];
////            [trans concat];
//            CGContextTranslateCTM (context, -(xpos-2), 2);
//            
////            trans = [NSAffineTransform transform];
////            [trans translateXBy:xpos yBy:0.0];
////            [trans concat];
//            CGContextTranslateCTM (context, xpos, 0);
//            
//            [curr draw:context atY:ytop];
////            trans = [NSAffineTransform transform];
////            [trans translateXBy:-xpos yBy:0.0];
////            [trans concat];
//            CGContextTranslateCTM (context, -xpos, 0);
//            
//            
//            redrawLines = YES;
//        }

        /* If symbol is in the current time, draw a shaded background */
        if ((start <= currentPulseTime) && (currentPulseTime < end)) {
            *x_shade = shadeXpos;
            return 1;
//            trans = [NSAffineTransform transform];
//            [trans translateXBy:xpos yBy:0.0];
//            [trans concat];
//            CGContextTranslateCTM (context, xpos, 0);
//
//            NSLog(@"------------ xpos is %i-------------", xpos);
//            [color setFill];
//            UIBezierPath *path = [UIBezierPath bezierPathWithRect:
//                 CGRectMake(0, 0, [curr width], [self height]) ];
//            [path fill];
//            [curr draw:context atY:ytop];
////            trans = [NSAffineTransform transform];
////            [trans translateXBy:-xpos yBy:0.0];
////            [trans concat];
//            CGContextTranslateCTM (context, -xpos, 0);
//
//            
//            redrawLines = YES;
        }

        /* If either a gray or white background was drawn, we need to redraw
         * the horizontal staff lines, and redraw the stem of the previous chord.
         */
//        if (redrawLines) {
//            int line = 1;
//            int y = ytop - LineWidth;
//
////            trans = [NSAffineTransform transform];
////            [trans translateXBy:xpos-2  yBy:0.0];
////            [trans concat];
//            CGContextTranslateCTM (context, xpos-2, 0);
//            
//            UIBezierPath *path = [UIBezierPath bezierPath];
//            [path setLineWidth:1];
//            for (line = 1; line <= 5; line++) {
//                [path moveToPoint:CGPointMake(0, y)];
//                [path addLineToPoint:CGPointMake([curr width]+4, y)];
//                y += LineWidth + LineSpace;
//            }
//            [path stroke];
////            trans = [NSAffineTransform transform];
////            [trans translateXBy:-(xpos-2) yBy:0.0];
////            [trans concat];
//            CGContextTranslateCTM (context, -(xpos-2), 0);
//
//            if (prevChord != nil) {
////                trans = [NSAffineTransform transform];
////                [trans translateXBy:prev_xpos yBy:0.0];
////                [trans concat];
//                CGContextTranslateCTM (context, prev_xpos, 0);
//                
//                [prevChord draw:context atY:ytop];
////                trans = [NSAffineTransform transform];
////                [trans translateXBy:-prev_xpos yBy:0.0];
////                [trans concat];
//                CGContextTranslateCTM (context, -prev_xpos, 0);
//                
//                if (showMeasures) {
//                    [self drawMeasureNumbers:context];
//                }
//                if (lyrics != nil) {
//                    [self drawLyrics:context];
//                }
//            }
//        }
//
//        if ([curr isKindOfClass:[ChordSymbol class]]) {
//            ChordSymbol *chord = (ChordSymbol*)curr;
//            if ([chord stem] != nil && ![[chord stem] receiver]) {
//                prevChord = (ChordSymbol*) curr;
//                prev_xpos = xpos;
//            }
//        }
        shadeXpos += [shadeCurr width];
    }
    return -1;
}


- (int)setShadeNotesModel1:(int)value withChordSymbol:(ChordSymbol*)symbol andX:(int *)x_shade
{
    if (x_shade == nil || symbol == nil) {
        shadeCurr = nil;
        return -1;
    }

    NSLog(@"===setShadeNotesModel1 ddddd");
    shadeCurr = symbol;
    shadeXpos = keysigWidth;

    for (int i = 0; i < value; i++) {
        id <MusicSymbol> s = [symbols get:i];
//        if ([s isKindOfClass:[ChordSymbol class]]) {
            shadeXpos += [s width];
//        }
    }
    
    *x_shade = shadeXpos;
    return 1;
}


- (void)dealloc {
    [symbols release];
    [clefsym release];
    [keys release];
    [super dealloc];
}

- (NSString*)description {
    NSString *s = [NSString stringWithFormat:@"Staff clef=%@\n", [clefsym description]];
    s = [s stringByAppendingString:@"  Keys:\n"];
    for (int i = 0; i < [keys count]; i++) {
        AccidSymbol *a = [keys get:i];
        s = [s stringByAppendingString:@"    "];
        s = [s stringByAppendingString:[a description]];
        s = [s stringByAppendingString:@"\n"]; 
    }
    s = [s stringByAppendingString:@"  Symbols:\n"];
    for (int i = 0; i < [symbols count]; i++) {
        id sym = [symbols get:i];
        s = [s stringByAppendingString:@"    "];
        s = [s stringByAppendingString:[sym description]];
        s = [s stringByAppendingString:@"\n"];
    }
    s = [s stringByAppendingString:@"End Staff\n"];
    return s;
}
/** add by yizhq start */
-(void) createEightVeIndex
{
//    int i,j,idx;
//    int flag;
//    IntArray *tmpList = [IntArray new:300];// how much?
//    eightVeIndex = [IntArray new:300];//how much?
//    i = -1;
//    flag = 0;
//    
//    for (idx = 0; idx <= [symbols count]; idx++) {
//        i++;
//        if([[symbols get:i] isKindOfClass:[ChordSymbol class]])
//        {
//            ChordSymbol *chord = (ChordSymbol *)[symbols get:i];
//            if ([chord ] && flag==0) {
//                flag = 1;
//                tmpList.add(i);
//            }
//        }
//    }
}
//public void createEightVeIndex() {
//    int i, j;
//    int flag;
//    ListInt tmpList = new ListInt();
//    eightVeIndex = new ListInt();
//    i = -1;
//    flag = 0;
//    for (MusicSymbol s : symbols) {
//        i++;
//        if (s instanceof ChordSymbol) {
//            ChordSymbol chord = (ChordSymbol) s;
//            if (chord.getEightVeFlag()==1 && flag==0) {
//                flag = 1;
//                tmpList.add(i);
//            }
//            else if (chord.getEightVeFlag()==0 && flag==1) {
//                flag = 0;
//                tmpList.add(i);
//            }
//        }
//    }
//    if (flag==1) {
//        tmpList.add(i);
//    }
//    
//    if (tmpList.size()>0) {
//        eightVeIndex.add(tmpList.get(0));
//        j = 1;
//        while (j+1 < tmpList.size()) {
//            if ( tmpList.get(j+1) - tmpList.get(j) < 4 ) {
//                for (i = tmpList.get(j)+1; i<tmpList.get(j+1); i++) {
//                    if (symbols.get(i) instanceof ChordSymbol) {
//                        ChordSymbol chord = (ChordSymbol)(symbols.get(i));
//                        if (chord.getStem().getEnd().getNumber()<72) {
//                            break;
//                        }
//                    }
//                }
//                if (i == tmpList.get(j+1)) {
//                    for (i = tmpList.get(j)+1; i<tmpList.get(j+1); i++) {
//                        if (symbols.get(i) instanceof ChordSymbol) {
//                            ChordSymbol chord = (ChordSymbol)(symbols.get(i));
//                            chord.setEightVeFlag(1);
//                        }
//                    }
//                }
//                else {
//                    eightVeIndex.add(tmpList.get(j));
//                    eightVeIndex.add(tmpList.get(j+1));
//                }
//            }
//            else {
//                eightVeIndex.add(tmpList.get(j));
//                eightVeIndex.add(tmpList.get(j+1));
//            }
//            j = j+2;
//        }
//    }
//    if (tmpList.size()<=2) {
//        eightVeIndex.add(tmpList.get(0));
//        eightVeIndex.add(tmpList.get(1));
//    }
//    
//    return;
//}
/** add by yizhq end*/
@end


