/*
 * Copyright (c) 2011-2012 Madhav Vaidyanathan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */

#include <sys/time.h>
#include <unistd.h>
#import "MidiPlayer.h"
#import "Array.h"

/* A note about changing the volume:
 * MidiSheetMusic does not support volume control in Mac OS X 10.4
 * and earlier, because the NSSound setVolume method does not exist
 * in those earlier versions. In the code below, we check if the NSSound
 * class supports the setVolume method, using respondsToSelector.
 */

#if MAC_OS_X_VERSION_MAX_ALLOWED < MAC_OS_X_VERSION_10_5
@interface NSSound(NSVolume)

- (void)setVolume:(float)x;

@end
#endif


/** @class MidiPlayer
 *
 * The MidiPlayer is the panel at the top used to play the sound
 * of the midi file.  It consists of:
 *
 * - The Rewind button
 * - The Play/Pause button
 * - The Stop button
 * - The Fast Forward button
 * - The Playback speed bar
 * - The Volume bar
 *
 * The sound of the midi file depends on
 * - The MidiOptions (taken from the menus)
 *   Which tracks are selected
 *   How much to transpose the keys by
 *   What instruments to use per track
 * - The tempo (from the Speed bar)
 * - The volume
 *
 * The MidiFile.changeSound() method is used to create a new midi file
 * with these options.  The NSSound class is used for
 * playing, pausing, and stopping the sound.
 *
 * For shading the notes during playback, the method
 * Staff.shadeNotes() is used.  It takes the current 'pulse time',
 * and determines which notes to shade.
 */
@implementation MidiPlayer


@synthesize peripheral, midiData;
@synthesize sensor;
@synthesize sheetPlay;
@synthesize delegate;

-(void) changeVolume:(double)value
{
    return;
}

/** Resize an image */
+ (UIImage*) resizeImage:(UIImage*)origImage toSize:(CGSize)newsize {
//    NSImage *image = [[NSImage alloc] initWithSize:newsize];
//    [image lockFocus];
//    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
//    [origImage setScalesWhenResized:YES];
//    [origImage setSize:newsize];
//    [origImage compositeToPoint:NSZeroPoint operation:NSCompositeCopy];
//    [image unlockFocus];
//    [origImage release];
//    [image setFlipped:YES];
//    return image;
    return nil;
}


/** Load the play/pause/stop button images */
+ (void)loadImages {
//    float buttonheight = [[NSFont labelFontOfSize:[NSFont labelFontSize]] capHeight] * 3;
//    NSSize imagesize;
//    imagesize.width = buttonheight;
//    imagesize.height = buttonheight;
//    if (rewindImage == NULL) {
//        NSString *name = [[NSBundle mainBundle] pathForResource:@"rewind" ofType:@"png"];
//        rewindImage = [[NSImage alloc] initWithContentsOfFile:name];
//        rewindImage = [MidiPlayer resizeImage:rewindImage toSize:imagesize];
//    }
//    if (playImage == NULL) {
//        NSString *name = [[NSBundle mainBundle] pathForResource:@"play" ofType:@"png"];
//        playImage = [[NSImage alloc] initWithContentsOfFile:name];
//        playImage = [MidiPlayer resizeImage:playImage toSize:imagesize];
//    }
//    if (pauseImage == NULL) {
//        NSString *name = [[NSBundle mainBundle] pathForResource:@"pause" ofType:@"png"];
//        pauseImage = [[NSImage alloc] initWithContentsOfFile:name];
//        pauseImage = [MidiPlayer resizeImage:pauseImage toSize:imagesize];
//    }
//    if (stopImage == NULL) {
//        NSString *name = [[NSBundle mainBundle] pathForResource:@"stop" ofType:@"png"];
//        stopImage = [[NSImage alloc] initWithContentsOfFile:name];
//        stopImage = [MidiPlayer resizeImage:stopImage toSize:imagesize];
//    }
//    if (fastFwdImage == NULL) {
//        NSString *name = [[NSBundle mainBundle] pathForResource:@"fastforward" ofType:@"png"];
//        fastFwdImage = [[NSImage alloc] initWithContentsOfFile:name];
//        fastFwdImage = [MidiPlayer resizeImage:fastFwdImage toSize:imagesize];
//    }
//    if (volumeImage == NULL) {
//        NSString *name = [[NSBundle mainBundle] pathForResource:@"volume" ofType:@"png"];
//        volumeImage = [[NSImage alloc] initWithContentsOfFile:name];
//        volumeImage = [MidiPlayer resizeImage:volumeImage toSize:imagesize];
//    }
}

/** Create a new MidiPlayer, displaying the play/stop buttons, the
 *  speed bar, and volume bar.  The midifile and sheetmusic are initially null.
 */
- (id)init {
//    [MidiPlayer loadImages];
//    float buttonheight = [[NSFont labelFontOfSize:[NSFont labelFontSize]] capHeight] * 4;
//    NSRect frame = NSMakeRect(0, 0, buttonheight * 27, buttonheight * 2);
//    self = [super initWithFrame:frame];
//    [self setAutoresizingMask:NSViewWidthSizable];

    midifile = nil;
    sheet = nil;
    memset(&options, 0, sizeof(MidiOptions));
    playstate = stopped;
    gettimeofday(&startTime, NULL);
    startPulseTime = 0;
    currentPulseTime = 0;
    prevPulseTime = -10;
    timer = nil;
    pianoData = nil;
    sensor = nil;
	recognition = nil;
    midiHandler = [[MidiKeyboard alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveData:) name:kNAMIDIDatas object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(midiStatus:) name:kNAMIDINotification object:nil];
    
    
//    sound = nil;
    /* add by yizhq start */
    sound = [[GDSoundEngine alloc] init];
    /* add by yizhq end */
 
//    /* Create the rewind button */
//    frame = NSMakeRect(buttonheight/4, 0, 1.5*buttonheight, 2*buttonheight);
//    rewindButton = [[NSButton alloc] initWithFrame:frame];
//    [self addSubview:rewindButton];
//    [rewindButton setImage:rewindImage];
//    [rewindButton setToolTip:@"Rewind"];
//    [rewindButton setAction:@selector(rewind:)];
//    [rewindButton setTarget:self];
//    [rewindButton setBezelStyle:NSRoundedBezelStyle];
//
//    /* Create the play button */
//    frame.origin.x += buttonheight + buttonheight/2;
//    playButton = [[NSButton alloc] initWithFrame:frame];
//    [self addSubview:playButton];
//    [playButton setImage:playImage];
//    [playButton setToolTip:@"Play"];
//    [playButton setAction:@selector(playPause:)];
//    [playButton setTarget:self];
//    [playButton setBezelStyle:NSRoundedBezelStyle];
//
//    /* Create the stop button */
//    frame.origin.x += buttonheight + buttonheight/2;
//    stopButton = [[NSButton alloc] initWithFrame:frame];
//    [self addSubview:stopButton];
//    [stopButton setImage:stopImage];
//    [stopButton setToolTip:@"Stop"];
//    [stopButton setAction:@selector(stop:)];
//    [stopButton setTarget:self];
//    [stopButton setBezelStyle:NSRoundedBezelStyle];
//
//    /* Create the fast forward button */
//    frame.origin.x += buttonheight + buttonheight/2;
//    fastFwdButton = [[NSButton alloc] initWithFrame:frame];
//    [self addSubview:fastFwdButton];
//    [fastFwdButton setImage:fastFwdImage];
//    [fastFwdButton setToolTip:@"Fast Forward"];
//    [fastFwdButton setAction:@selector(fastForward:)];
//    [fastFwdButton setTarget:self];
//    [fastFwdButton setBezelStyle:NSRoundedBezelStyle];
//
//    /* Create the Speed bar */
//    frame.origin.x += 2*buttonheight;
//    frame.origin.y = buttonheight/2;
//    frame.size.height = buttonheight;
//    frame.size.width = buttonheight * 2;
//    NSButton *label = [[NSButton alloc] initWithFrame:frame];
//    [label setTitle:@"Speed: "];
//    [label setBordered:NO];
//    [label setAlignment:NSRightTextAlignment];
//    [self addSubview:label]; 
//    [label release];
//
//    frame.origin.x += buttonheight*2 + 2;
//    frame.size.width = buttonheight * 4;
//    speedBar = [[NSSlider alloc] initWithFrame:frame];
//    [speedBar setMinValue:1];
//    [speedBar setMaxValue:100];
//    [speedBar setDoubleValue:100];
//    [self addSubview:speedBar]; 
//
//    /* Create the volume bar */
//    frame.origin.x += buttonheight*4 + buttonheight/2;
//    frame.origin.y = 0;
//    frame.size.width = 1.5 *buttonheight;
//    frame.size.height = 2*buttonheight;
//    NSButton *volumeLabel = [[NSButton alloc] initWithFrame:frame]; 
//    [self addSubview:volumeLabel];
//    [volumeLabel setImage:volumeImage];
//    [volumeLabel setToolTip:@"Adjust Volume"];
//    [volumeLabel setBordered:NO]; 
//    [volumeLabel release];
//
//    frame.origin.x += buttonheight*2 + 2;
//    frame.origin.y = buttonheight/2;
//    frame.size.width = buttonheight * 4;
//    frame.size.height = buttonheight;
//    volumeBar = [[NSSlider alloc] initWithFrame:frame];
//    [volumeBar setMinValue:1];
//    [volumeBar setMaxValue:100];
//    [volumeBar setDoubleValue:100];
//    [volumeBar setAction:@selector(changeVolume:)];
//    [volumeBar setTarget:self];
//    [self addSubview:volumeBar];
    
     return self;
}

- (void)setPiano:(Piano*)p {
    piano = [p retain];
}

/** The MidiFile and/or SheetMusic has changed. Stop any playback sound,
 *  and store the current midifile and sheet music.
 */
- (void)setMidiFile:(MidiFile*)file withOptions:(MidiOptions*)opt andSheet:(SheetMusic*)s {

    /* If we're paused, and using the same midi file, redraw the
     * highlighted notes.
     */
    BOOL isLine = [midiHandler setupMIDI];
    isLine = TRUE; //add by test by zyw
    if(sensor != nil || isLine) {
        sensor.delegate = self;
        pianoData = [[PianoDataJudged alloc] init];
        arrPacket =[[NSMutableArray alloc] init];
    }

    if ((midifile == file && midifile != nil && playstate == paused)) {
        if (sheet != nil) {
            [sheet release];
        }
        sheet = [s retain];
        memcpy(&options, opt, sizeof(MidiOptions));

//        [sheet shadeNotes:(int)currentPulseTime withPrev:-10 gradualScroll:NO];
        [sheetPlay shadeNotes:(int)currentPulseTime withPrev:-10];
        [NSTimer scheduledTimerWithTimeInterval:0.2
                 target:self selector:@selector(reshade:) userInfo:nil repeats:NO];
    }
    else {
        [self stop];
        if (sheet != nil) {
            [sheet release];
        }
        sheet = [s retain];
        memcpy(&options, opt, sizeof(MidiOptions));
        if (midifile != nil) {
            [midifile release];
        }
        midifile = [file retain];
    }
    
    
    if (isLine) {
        if (recognition != nil) {
            [recognition release];
        }
        staffs = [sheet getStaffs];
        recognition = [[PianoRecognition alloc] initWithStaff:staffs andMidiFile:midifile andOptions:&options];
        recognition.endDelegate = self.delegate;
	recognition.sheetShadeDelegate = self;
    }

    int dd = [midifile getMeasureCount];
    int cc = [midifile getMidiFileTimes];
    
//    NSLog(@"dd is %i ff %i", dd, cc);
    
    
}

/** If we're paused, reshade the sheet music and piano. */
- (void)reshade:(NSTimer*)arg {
    if (playstate == paused) {
        [sheetPlay shadeNotes:(int)currentPulseTime withPrev:-10];
//        [sheet shadeNotes:(int)currentPulseTime withPrev:-10 gradualScroll:NO];
        [piano shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
    }
    [arg invalidate];
}


/** Delete the temporary midi sound file */
- (void)deleteSoundFile {
    if (tempSoundFile == nil) {
        return;
    }
    [self stop];
    const char *cfile = [tempSoundFile cStringUsingEncoding:NSUTF8StringEncoding];
    unlink(cfile);
    [tempSoundFile release];
    tempSoundFile = nil;
}
    

/** Return the number of tracks selected in the MidiOptions.
 *  If the number of tracks is 0, there is no sound to play.
 */
- (int)numberTracks {
    int count = 0;
    for (int i = 0; i < [options.tracks count]; i++) {
        if ([options.tracks get:i] && ![options.mute get:i]) {
            count += 1;
        }
    }
    return count;
}


/** Create a new midi sound data with all the MidiOptions incorporated.
 *  Store the new midi sound into the file tempSoundFile.
 */
- (void)createMidiFile {
    [tempSoundFile release];
    tempSoundFile = nil;
    /** modify by yizhq for change speed from 20 ~ 280 start */
    //    double inverse_tempo = 1.0 / [[midifile time] tempo];
    //    double inverse_tempo_scaled = inverse_tempo * doubleValue / 100.0;
    //    options.tempo = (int)(1.0 / inverse_tempo_scaled);
    options.tempo = (int)(60000 / doubleValue * 1000);
//    NSLog(@"tempo is %i", options.tempo);
    /** modify by yizhq for change speed from 20 ~ 280 end */
    pulsesPerMsec = [[midifile time] quarter] * (1000.0 / options.tempo);
    
    NSString *tempPath = NSTemporaryDirectory();
    tempSoundFile = [NSString stringWithFormat:@"%@/temp.mid", tempPath];
    
    //tempSoundFile = [[midifile filename] stringByAppendingString:@".MSM.mid"];
    tempSoundFile = [tempSoundFile retain];
    if ([midifile changeSound:&options oldMidi:midifile toFile:tempSoundFile] == NO) {//modify by yizhq
        /* Failed to write to tempSoundFile */
        [tempSoundFile release]; tempSoundFile = nil;
    }
}


-(void)playByType:(int)type
{
    playModel = type;
    switch(playModel) {
        case PlayModel1:
            [self playModel1];
            break;
        case PlayModel2:
            [self playPause];
            break;
        case PlayModel3:
            [self playPause];
            break;
        default:
            break;
    }
}


/** 
 *  识谱模式演奏
 */
- (void)playModel1 {
    if (midifile == nil || sheet == nil) {
        return;
    }
    else if (playstate == initStop || playstate == initPause) {
        return;
    }
    else if (playstate == playing) {
        playstate = initPause;
        return;
    }
    else if (playstate == stopped || playstate == paused) {
 
        options.pauseTime = 0;
        startPulseTime = options.shifttime;
        currentPulseTime = options.shifttime;
        prevPulseTime = options.shifttime - [[midifile time] quarter];
        
//        staffs = [sheet getStaffs];
        [self createMidiFile];
        playstate = playing;
        (void)gettimeofday(&startTime, NULL);
        
        if (arrPacket != nil) {
            [arrPacket removeAllObjects];
        }
        
        if (recognition != nil) {
	        [recognition setBeginTime:startTime];
	        [recognition setPulsesPerMsec:pulsesPerMsec];
        }

        return;
    }
}


- (void) sheetShade:(int) staffIndex andChordIndex:(int)chordIndex andChordSymbol:(ChordSymbol*)chord
{
    NSLog(@"====sheetShade === staff index = [%d] chord Index = [%d]", staffIndex, chordIndex);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [sheet shadeNotesByModel1:staffIndex andChordIndex:chordIndex andChord:chord];
    });
    
    
}
/** add by yizhq start */
-(void)playJumpSection:(int)startSectionNumber{
    if (options.staveModel == 1) {
        if (startSectionNumber < 0) {
            return;
        }
        int startSec = startSectionNumber;
        [self jumpMeasure:startSec - 1];
    }
}
/** add by yizhq end */
/** The callback for the play/pause button (a single button).
 *  If we're stopped or pause, then play the midi file.
 *  If we're currently playing, then initiate a pause.
 *  (The actual pause is done when the timer is invoked).
 */
- (void)playPause {
//    if (midifile == nil || sheet == nil || [self numberTracks] == 0) {modify by yizhq
    if (midifile == nil || sheet == nil) {
        return;
    }
    else if (playstate == initStop || playstate == initPause) {
        return;
    }
    else if (playstate == playing) {
        playstate = initPause;
        return;
    }
    else if (playstate == stopped || playstate == paused) {
        /* The startPulseTime is the pulse time of the midi file when
         * we first start playing the music.  It's used during shading.
         */
        if (options.playMeasuresInLoop) {
            /* If we're playing measures in a loop, make sure the
             * currentPulseTime is somewhere inside the loop measures.
             */
            double nearEndTime = currentPulseTime + pulsesPerMsec*50;
            int measure = (int)(nearEndTime / [[midifile time] measure]);
            if ((measure < options.playMeasuresInLoopStart) ||
                (measure > options.playMeasuresInLoopEnd)) {

                currentPulseTime = options.playMeasuresInLoopStart * 
                                   [[midifile time] measure];
            }
            startPulseTime = currentPulseTime;
            options.pauseTime = (int)(currentPulseTime - options.shifttime);
        }
        else if (playstate == paused) {
            startPulseTime = currentPulseTime;
            options.pauseTime = (int)(currentPulseTime - options.shifttime);
        }
        else {
            options.pauseTime = 0;
            startPulseTime = options.shifttime;
            currentPulseTime = options.shifttime;
            prevPulseTime = options.shifttime - [[midifile time] quarter];
        }
        
        staffs = [sheet getStaffs];
        
        [self createMidiFile];
//        [sound release];
//        sound = [[NSSound alloc] initWithContentsOfFile:tempSoundFile byReference:NO];
//        if ([sound respondsToSelector:@selector(setVolume:)] ) {
//            [sound setVolume:[volumeBar doubleValue] / 100.0];
//        }
//        [sound play];
        /* add by yizhq start */
//        [sound loadMIDIFile:[midifile filename]];
        [sound loadMIDIFile:tempSoundFile];
        [sound playPressed];
        playstate = playing;
        /* add by yizhq end */
        
        
        
        (void)gettimeofday(&startTime, NULL);
        
        
        if (timer != nil) {
            [timer invalidate];
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                 target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES];
//        [playButton setImage:pauseImage];
//        [playButton setToolTip:@"Pause"];
        
        if (pianoData != nil) {
            [pianoData setBeginTime:startTime];
            [pianoData setPulsesPerMsec:pulsesPerMsec];
            
            [pianoData judgedPianoPlay:currentPulseTime andPrevPulseTime:prevPulseTime andStaffs:staffs andMidifile:midifile];
        }
        


        [sheetPlay shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
//        [sheet shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime gradualScroll:YES];
        [piano shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
        return;
    }
}


/** The callback for the Stop button.
 *  If paused, clear the sound settings and state.
 *  Else, initiate a stop (the actual stop is done in the timer).
 */
- (void)stop {
    if (midifile == nil || sheet == nil || playstate == stopped) {
        return;
    }
    if (playstate == initPause || playstate == initStop || playstate == playing) {
        /* Wait for the timer to finish */
        playstate = initStop;
        usleep(400 * 1000);
        [self doStop];
    }
    else if (playstate == paused) {
        [self doStop];
    }
}

/** Perform the actual stop, by stopping the sound,
 *  removing any shading, and clearing the state.
 */
- (void)doStop {
    playstate = stopped;
//    [sound stop];
//    [sound release]; sound = nil;
    /* add by yizhq start */
    [sound stopPressed];
//    [sound release];sound = nil;
    /* add by yizhq end */
    [self deleteSoundFile];

    /* Remove all shading by redrawing the music */
    sheet.hidden = NO;
    piano.hidden = NO;

    startPulseTime = 0;
    currentPulseTime = 0;
    prevPulseTime = 0;
//    [playButton setImage:playImage];
//    [playButton setToolTip:@"Play"];
    return;
}


-(void)Pause {
    playstate = paused;
    [sound stopPressed];
    [self deleteSoundFile];
    return;
}

/** Rewind the midi music back one measure.
 *  The music must be in the paused state.
 *  When we resume in playPause, we start at the currentPulseTime.
 *  So to rewind, just decrease the currentPulseTime,
 *  and re-shade the sheet music.
 */
- (void)rewind {
    if (midifile == nil || sheet == nil || playstate != paused) {
        return;
    }

    /* Remove any highlighted notes */
    [sheetPlay shadeNotes:-10 withPrev:(int)currentPulseTime];
//    [sheet shadeNotes:-10 withPrev:(int)currentPulseTime gradualScroll:NO];
    [piano shadeNotes:-10 withPrev:(int)currentPulseTime];

    prevPulseTime = currentPulseTime;
    currentPulseTime -= [[midifile time] measure];
    if (currentPulseTime < options.shifttime) {
        currentPulseTime = options.shifttime;
    }
    [piano shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
//    [sheet shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime gradualScroll:NO];
    [sheetPlay shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
}

- (BOOL) jumpMeasure:(int)number
{
    if (number < 0) return FALSE;
    
    if (midifile == nil || sheet == nil) {
        return FALSE;
    }
    if (playstate != paused && playstate != stopped) {
        return FALSE;
    }
    playstate = paused;
    

    /* Remove any highlighted notes */
    [sheetPlay shadeNotes:-10 withPrev:(int)currentPulseTime];
    [piano shadeNotes:-10 withPrev:(int)currentPulseTime];
    
    prevPulseTime = currentPulseTime;
    currentPulseTime = [[midifile time] measure]*number;
    
    
    if (currentPulseTime > [midifile totalpulses]) {
        currentPulseTime -= [[midifile time] measure];
    }
    
    [sheetPlay setCurrentPulseTime:currentPulseTime];
    
    [piano shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
    //[sheetPlay shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
    [sheet shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime gradualScroll:YES];
    
    
    return TRUE;
}


/** Fast forward the midi music by one measure.
 *  The music must be in the paused/stopped state.
 *  When we resume in playPause, we start at the currentPulseTime.
 *  So to fast forward, just increase the currentPulseTime,
 *  and re-shade the sheet music.
 */
- (void)fastForward {
    if (midifile == nil || sheet == nil) {
        return;
    }
    if (playstate != paused && playstate != stopped) {
        return;
    }
    playstate = paused;

    /* Remove any highlighted notes */
    [sheetPlay shadeNotes:-10 withPrev:(int)currentPulseTime];
//    [sheet shadeNotes:-10 withPrev:(int)currentPulseTime gradualScroll:NO];
    [piano shadeNotes:-10 withPrev:(int)currentPulseTime];

    prevPulseTime = currentPulseTime;
    currentPulseTime += [[midifile time] measure];
    if (currentPulseTime > [midifile totalpulses]) {
        currentPulseTime -= [[midifile time] measure];
    }
    [piano shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
//    [sheet shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime gradualScroll:NO];
    [sheetPlay shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
}


/** The callback for the timer. If the midi is still playing,
 *  update the currentPulseTime and shade the sheet music.
 *  If a stop or pause has been initiated (by someone clicking
 *  the stop or pause button), then stop the timer.
 */
- (void)timerCallback:(NSTimer*)arg {
    if (midifile == nil || sheet == nil) {
        [timer invalidate]; timer = nil;
        playstate = stopped;
        return;
    }
    else if (playstate == stopped || playstate == paused) {
        /* This case should never happen */
        [timer invalidate]; timer = nil;
        return;
    }
    else if (playstate == initStop) {
        [timer invalidate]; timer = nil;
        return;
    } 
    else if (playstate == playing) {
        struct timeval now;
        gettimeofday(&now, NULL);
        long msec = (now.tv_sec - startTime.tv_sec)*1000 +
                    (now.tv_usec - startTime.tv_usec)/1000;
        prevPulseTime = currentPulseTime;
        currentPulseTime = startPulseTime + msec * pulsesPerMsec;

        /* If we're playing in a loop, stop and restart */
        if (options.playMeasuresInLoop) {
            int measure = (int)(currentPulseTime / [[midifile time] measure]);
            if (measure > options.playMeasuresInLoopEnd) {
                [self restartPlayMeasuresInLoop];
                return;
            }
        }

        /* Stop if we've reached the end of the song */
        /** modify by yizhq start */
        int totalTime = 0;
        if (options.staveModel == 1) {
            totalTime = options.endSecTime;
        }else{
            totalTime = [midifile totalpulses];
        }
//        if (currentPulseTime > [midifile totalpulses]) {
        if (currentPulseTime > totalTime) {
        /** modify by yizhq end */
            [timer invalidate]; timer = nil;
            
            if (pianoData != nil) {
                [pianoData judgedPianoPlay:-10 andPrevPulseTime:prevPulseTime andStaffs:staffs andMidifile:midifile];
            }
        
//            NSLog(@"dddddddddddddddd");
            [sheetPlay shadeNotes:-10 withPrev:(int)currentPulseTime];
//            [sheet shadeNotes:-10 withPrev:(int)currentPulseTime gradualScroll:NO];
            
            [self doStop];
            
            if (delegate != nil) {
                [delegate endSongs];
            }
            
            if (pianoData != nil) {
                
                IntArray *result = [pianoData judgedResult];
                
                if (delegate != nil) {
                    [delegate endSongsResult:[result get:3] andRight:[result get:2]
                                    andWrong:[result get:1]];
                }
                
                int ff = ([result get:2] + [result get:3])/([result get:0]*1.0) * 100;
                NSString *score = [NSString stringWithFormat:@"Score %i", ff];

                NSString *message = [NSString stringWithFormat:@"wrong:%d right:%d good:%d sum:%d",[result get:1],[result get:2], [result get:3], [result get:0]];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:score message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",
                                          nil];
                [alertView show];
            }
            

            return;
        }
        
        if (pianoData != nil) {
            [pianoData judgedPianoPlay:currentPulseTime andPrevPulseTime:prevPulseTime andStaffs:staffs andMidifile:midifile];
        }
        
        [sheetPlay shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
//        [sheet shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime gradualScroll:YES];
        [piano shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
        return;
    }
    else if (playstate == initPause) {
        [timer invalidate]; timer = nil;
        struct timeval now;
        gettimeofday(&now, NULL);
        long msec = (now.tv_sec - startTime.tv_sec)*1000 + 
                    (now.tv_usec - startTime.tv_usec)/1000;

//        [sound stop];
//        [sound release]; sound = nil;
        /* add by yizhq start */
        [sound stopPressed];
//        [sound release];sound = nil;
        /* add by yizhq end */
        prevPulseTime = currentPulseTime;
        currentPulseTime = startPulseTime + msec * pulsesPerMsec;
        [sheetPlay shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
//        [sheet shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime gradualScroll:YES];
        [piano shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
        prevPulseTime = currentPulseTime - [[midifile time] measure];
//        [playButton setImage:playImage];
//        [playButton setToolTip:@"Play"];
        playstate = paused;
        return;
    }
}

/** The "Play Measures in a Loop" feature is enabled, and we've reached
 *  the last measure. Stop the sound, and then start playing again.
 */
-(void)restartPlayMeasuresInLoop {
    [timer invalidate]; timer = nil;
    [self doStop];
    [NSTimer scheduledTimerWithTimeInterval:0.4
                 target:self selector:@selector(replay:) userInfo:nil repeats:NO];
}

-(void)replay:(NSTimer*)arg {
    [self playPause];
}

/** Callback for volume bar.  Adjust the volume if the midi sound
 *  is currently playing.
 */
- (void)changeSpeed:(double)value {
    doubleValue = value;
}

/** This view uses flipped coordinates, where upper-left corner is (0,0) */
- (BOOL)isFlipped {
    return YES;
}


//bluetooth recv data
-(void) serialGATTCharValueUpdated:(NSString *)UUID value:(NSData *)data
{
    Byte *buffers = (Byte *)[data bytes];
    for(int i = 0; i < data.length; i++)
    {
        NSNumber *num = [[NSNumber alloc] initWithInt:buffers[i]];
//        NSLog(@"MidiPlayer rece num is %x", [num intValue]);
        [arrPacket addObject: num];
    }

    len += data.length;
    if (len %3 == 0) {
        if (playstate == playing) {
            [pianoData setTimesig:[midifile time]];
            [pianoData setPianoData:arrPacket];
            
        }
        [arrPacket removeAllObjects];
        len = 0;
    }
}

-(void) setConnect
{
    NSLog(@"disconnect");
}

-(void)setDisconnect
{
    NSLog(@"disconnect");
}



-(void)byModel1{
//    [recognition setTimesig:[midifile time]];
    
    [recognition setPianoData:arrPacket];
    int count = [recognition getCurChordSymolNoteCount];
    int c = [recognition getNotesCount];
    NSLog(@"====current chord symbol note count [%d] rece data count[%d] aaaa %d", count, c, [recognition getCurrIndex]);
    if (count == c) {
        [recognition recognitionPlayByLine];
    }
    
}

-(void)byModel2 {
    [pianoData setTimesig:[midifile time]];
    [pianoData setPianoData:arrPacket];
    [arrPacket removeAllObjects];
    
}
//MidiKeyboard recevice data
- (void)receiveData:(NSNotification*)notification
{
    int notePlayed = [[notification.userInfo objectForKey:kNAMIDI_NoteKey] intValue];
    int velocity = [[notification.userInfo objectForKey:kNAMIDI_VelocityKey] intValue];
    NSLog(@"=====MidiKeyboard Recevice data NoteNumber[%d], Velocity[%d]", notePlayed, velocity);
    
    if (velocity == 0) return;
    
    [arrPacket removeAllObjects];
    NSNumber *num1 = [[NSNumber alloc] initWithInt:0x90];
    [arrPacket addObject: num1];
    
    NSNumber *num2 = [[NSNumber alloc] initWithInt:notePlayed];
    [arrPacket addObject: num2];
    
    NSNumber *num3 = [[NSNumber alloc] initWithInt:velocity];
    [arrPacket addObject: num3];
    
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSString *data1 = [NSString stringWithFormat:@"ndata : %d | %d", notePlayed, velocity];
//        [self.midiData setText:data1];
//    });
    
    if (playstate == playing) {
        switch(playModel) {
            case PlayModel1:
                [self byModel1];
                break;
            case PlayModel2:
                [self byModel2];
                break;
            case PlayModel3:
                [self byModel2];
                break;
        }
    }
    
}

- (void)midiStatus:(NSNotification*)notification
{
    int messageID = [[notification.userInfo objectForKey:@"kNAMIDINotification"] intValue];
    NSLog(@"MidiKeyboard Notify, MessageID=%d", messageID);
}


- (void)dealloc {
    [self deleteSoundFile];
//    [playButton release]; 
//    [stopButton release];
//    [rewindButton release];
//    [fastFwdButton release];
//    [speedBar release];
//    [volumeBar release];
    [midifile release];
    [sheet release]; 
    [piano release];
    [sound release];
    [pianoData release];
    [arrPacket release];
    [midiHandler release];
    if (recognition != nil)
    {
        [recognition release];
    }
    [tempSoundFile release];
    if (timer != nil) {
        [timer invalidate];
    }
    
    [super dealloc];
}

@end


