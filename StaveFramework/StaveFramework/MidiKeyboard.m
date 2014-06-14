//
//  MidiKeyboard.m
//  MidiLineTest
//
//  Created by zhengyw on 14-5-16.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import <CoreMIDI/CoreMIDI.h>
#import "MidiKeyboard.h"


static void	MyMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon)
{
    //Reads the source/device's name which is allocated in the MidiSetupWithSource function.
    const char *source = connRefCon;
    
    //Extracting the data from the MIDI packets receieved.
    MIDIPacket *packet = (MIDIPacket *)pktlist->packet;
	Byte note = packet->data[1] & 0x7F;
    Byte velocity = packet->data[2] & 0x7F;
    
    for (int i=0; i < pktlist->numPackets; i++) {
        
		Byte midiStatus = packet->data[0];
		Byte midiCommand = midiStatus >> 4;
        
		if ((midiCommand == 0x09) || //note on
			(midiCommand == 0x08)) { //note off
            
            NSLog(@"%s - NOTE : %d | %d", source, note, velocity);
            
            
            NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
            [info setObject:[NSNumber numberWithInteger:note] forKey:kNAMIDI_NoteKey];
            [info setObject:[NSNumber numberWithInteger:velocity] forKey:kNAMIDI_VelocityKey];
            NSNotification* notification = [NSNotification notificationWithName:kNAMIDIDatas object:nil userInfo:info];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
		} else {
            
            NSLog(@"%s - CNTRL  : %d | %d", source, note, velocity);
        }
        
        //After we are done reading the data, move to the next packet.
        packet = MIDIPacketNext(packet);
        
	}
}

static void MyMIDINotifyProc (const MIDINotification  *message, void *refCon) {
    NSNotification* notification = [NSNotification notificationWithName:kNAMIDINotification
                                                                 object:[NSNumber numberWithShort:message->messageID]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


@implementation MidiKeyboard

- (id)init
{
    self = [super init];
    return self;
}

- (void) listSources
{
    unsigned long sourceCount = MIDIGetNumberOfSources();
    for (int i=0; i<sourceCount; i++) {
        MIDIEndpointRef source = MIDIGetSource(i);
        CFStringRef endpointName = NULL;
        MIDIObjectGetStringProperty(source, kMIDIPropertyName, &endpointName);
        char endpointNameC[255];
        CFStringGetCString(endpointName, endpointNameC, 255, kCFStringEncodingUTF8);
        NSLog(@"Source %d - %s", i, endpointNameC);
    }
}

- (BOOL)setupMIDI {
    
    BOOL result = FALSE;
    
    [self listSources];
    
	MIDIClientRef client = 0;
	MIDIClientCreate(CFSTR("NNAudio MIDI Handler"), MyMIDINotifyProc, nil, &client);
	
	MIDIPortRef inPort = 0;
	MIDIInputPortCreate(client, CFSTR("Input port"), MyMIDIReadProc, nil, &inPort);
	
	unsigned long sourceCount = MIDIGetNumberOfSources();
	for (int i = 0; i < sourceCount; ++i) {
		MIDIEndpointRef src = MIDIGetSource(i);
		CFStringRef endpointName = NULL;
		OSStatus nameErr = MIDIObjectGetStringProperty(src, kMIDIPropertyName, &endpointName);
		if (noErr == nameErr) {
            NSLog(@"MIDI source %d: %@", i, endpointName);
		}
		MIDIPortConnectSource(inPort, src, NULL);
        result = TRUE;
	}
    
    return result;
}


@end
