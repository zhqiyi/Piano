//
//  MIDIParser.m
//  PainoSpirit
//
//  Created by yizhq on 14-5-7.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import "MIDIParser.h"
#import "TrackSetting.h"

@implementation MIDIParser {
    
}

- (NSArray *)parseMidiSequence: (MusicSequence *)sequence {
    UInt32 trackCount;
    MusicSequenceGetTrackCount(*sequence, &trackCount);
    NSLog(@"the sequence contains %d tracks" , (unsigned int)trackCount);
    
    NSMutableArray *trackSettings = [NSMutableArray new];
    MusicTrack track;
    for (UInt32 i = 0; i < trackCount; i ++) {
        MusicSequenceGetIndTrack(*sequence, i, &track);
        TrackSetting *trackSetting = [self settingsForTrack:track withNumber:i];
        NSLog(@"tracksetting at index %d:\n %@", i , trackSetting);
        [trackSettings addObject:trackSetting];
    }
    return trackSettings;
}

- (TrackSetting *)settingsForTrack:(MusicTrack)track withNumber:(UInt32)trackNumber {
    TrackSetting *trackSetting = [TrackSetting new];
    trackSetting.trackNumber = trackNumber;
    
    MusicEventIterator iterator = NULL;
    NewMusicEventIterator(track, &iterator);
    
    // Values to be retrieved from event
    // Start time in quarter notes
    MusicTimeStamp timestamp = 0;
    // The MIDI message type
    MusicEventType eventType = 0;
    
    // The data contained in the message
    const void *eventData = NULL;
    UInt32 eventDataSize = 0;
    
    Boolean hasNext;
    MusicEventIteratorHasNextEvent(iterator, &hasNext);
    MIDIMetaEvent * midiMetaEvent;
    
    while (hasNext) {
        // Copy the event data into the variables we prepared earlier
        MusicEventIteratorGetEventInfo(iterator, &timestamp, &eventType, &eventData, &eventDataSize);
        
        if (eventType == kMusicEventType_Meta) {
            //            NSLog(@"\nevent type = Meta");
            midiMetaEvent = (MIDIMetaEvent*) eventData;
            
            switch (midiMetaEvent->metaEventType)
            {
                case 0x59:
                    //                    NSLog(@" (keySignature)");
                    break;
                    
                case 0x03:
                {
                    trackSetting.trackName = [[NSString alloc] initWithBytes:midiMetaEvent->data length:midiMetaEvent->dataLength encoding:NSUTF8StringEncoding];
                }
                    break;
                    
                case 0x04:
                {
                    trackSetting.instrumentName = [[NSString alloc] initWithBytes:midiMetaEvent->data length:midiMetaEvent->dataLength encoding:NSUTF8StringEncoding];
                }
                    break;
                    
                default:
                    NSLog(@"  metaeventtype = %d", midiMetaEvent->metaEventType);
                    
                    break;
            }
        }
        
        // Channel messages - control change / program change
        else if(eventType == kMusicEventType_MIDIChannelMessage) {
            MIDIChannelMessage * channelMessage = (MIDIChannelMessage *) eventData;
            
            if(channelMessage->status >> 4 == 12) {
                trackSetting.channel = channelMessage->status & 0x0f;
                trackSetting.data1 = channelMessage->data1;
                trackSetting.data2 = channelMessage->data2;
            }
        }
        
        else if (eventType == kMusicEventType_MIDINoteMessage) {
            MIDINoteMessage * noteMessage = (MIDINoteMessage*) eventData;
            //            NSLog(@"note = %d played on channel %d", noteMessage->note, noteMessage->channel);
        }
        else {
            NSLog(@"\nnot parsed midi event with type %lu", eventType);
        }
        MusicEventIteratorNextEvent(iterator);
        MusicEventIteratorHasNextEvent(iterator, &hasNext);
    }
    return trackSetting;
}




@end