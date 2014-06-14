/*
 * Copyright (c) 2007-2011 Madhav Vaidyanathan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */
#import <UIKit/UIKit.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSZone.h>
#import <Foundation/NSException.h>
#import "Array.h"
#import "TimeSignature.h"


/* THe possible values for showNoteLetters */
enum { 
     NoteNameNone = 0, NoteNameLetter, NoteNameFixedDoReMi, NoteNameMovableDoReMi, NoteNameFixedNumber, NoteNameMovableNumber
};

/** @struct MidiOptions
 *
 * The MidiOptions class contains the available options for
 * modifying the sheet music and sound. These options are
 * collected from the menu/dialog settings, and then are passed
 * to the SheetMusic and MidiPlayer classes.
 */
struct _MidiOptions {
    /* Sheet Music options */
    __unsafe_unretained IntArray *tracks;        /** Which tracks to display (true = display) */
    BOOL scrollVert;         /** Whether to scroll vertically or horizontally */
    int numtracks;           /** Total number of tracks */
    BOOL largeNoteSize;      /** Display large or small note sizes */
    BOOL twoStaffs;          /** Combine tracks into two staffs ? */
    int showNoteLetters;     /** Show the name (A, A#, etc) next to the notes */
    BOOL showLyrics;         /** Show the lyrics */
    BOOL showMeasures;       /** Show the measure numbers for each staff */
    int shifttime;           /** Shift note starttimes by the given amount */
    int transpose;           /** Shift note key up/down by given amount */
    int key;                 /** Use the given KeySignature (notescale) */
    __unsafe_unretained TimeSignature *time;     /** Use the given time signature */
    int combineInterval;     /** Combine notes within given time interval (msec) */
    __unsafe_unretained Array* colors;           /** The note colors to use */
    __unsafe_unretained UIColor* shadeColor;     /** The color to use for shading */
    __unsafe_unretained UIColor* shade2Color;    /** The color to use for shading the left hand piano */

    /* Sound options */
    __unsafe_unretained IntArray *mute;          /** Which tracks to mute (true = mute) */
    int  tempo;              /** The tempo, in microseconds per quarter note */
    int  pauseTime;          /** Start the midi music at the given pause time */
    __unsafe_unretained IntArray *instruments;   /** The instruments to use per track */
    BOOL useDefaultInstruments;   /** If true, don't change instruments */
    BOOL playMeasuresInLoop;      /** Play the selected measures in a loop */
    int  playMeasuresInLoopStart; /** Start measure to play in loop */
    int  playMeasuresInLoopEnd;   /** End measure to play in loop */

};
typedef struct _MidiOptions MidiOptions;


