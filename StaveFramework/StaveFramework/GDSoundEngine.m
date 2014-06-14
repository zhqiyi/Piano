//
//  GDSoundEngine2.m
//  PainoSpirit
//
//  Created by yizhq on 14-5-7.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

static void CheckError(OSStatus error, const char *operation) {
    if (error == noErr) return;
    char errorString[20];
    // See if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) &&
        isprint(errorString[3]) && isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else {
        // No, format it as an integer
        sprintf(errorString, "%d", (int)error);
        fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
        exit(1);
    }
}


#define BANK_FILE_NAME @"gls"


#import "GDSoundEngine.h"
#import "MIDIParser.h"
#import "TrackSetting.h"

@import AVFoundation; 

@interface GDSoundEngine ()

@property (nonatomic) AudioUnit ioUnit;
@property (nonatomic) AudioUnit mixerUnit;

@property (nonatomic) AUNode ioNode;
@property (nonatomic) AUNode  mixerNode;

@property (nonatomic) AUGraph graph;
@property (nonatomic)  MusicPlayer player;
@property (nonatomic)  MusicSequence sequence;

@property (nonatomic, strong) NSMutableArray *samplerNodes;
@property (nonatomic, strong) NSArray *trackSettings;
@end

@implementation GDSoundEngine

- (id)init
{
    if ( self = [super init] ) {
        
    }
    
    return self;
}

- (void)createAndStartGraph {
    OSStatus result;
    result = NewAUGraph (&_graph);
    CheckError(result, "Unable to create an AUGraph object.");
    
    AudioComponentDescription componentDescription = {0};
    
    // output device (speakers)
    componentDescription.componentType = kAudioUnitType_Output;
    componentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    result = AUGraphAddNode(_graph, &componentDescription, &_ioNode);
    CheckError(result, "Unable to add ioNode");
    
    
    // Add the mixer unit to the graph
    componentDescription.componentType = kAudioUnitType_Mixer;
    componentDescription.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    
    result = AUGraphAddNode (_graph, &componentDescription, &_mixerNode);
    CheckError(result, "Unable to add mixerNode");
    
    result = AUGraphOpen(_graph);
    CheckError(result, "Unable to open graph");
    
    result = AUGraphNodeInfo(_graph, _ioNode, 0, &_ioUnit);
    CheckError(result, "Unable to obtain the reference to ioNode");
    
    result = AUGraphNodeInfo(_graph, _mixerNode, 0, &_mixerUnit);
    CheckError(result, "Unable to obtain the reference to the mixerNode");
    
    result = AUGraphConnectNodeInput(_graph, _mixerNode, 0, _ioNode, 0);
    CheckError(result, "Unable to connect ioUnit");
    
    result = AudioUnitInitialize(_mixerUnit);
    CheckError(result, "unable to initialize mixer unit");
    
    // Define the number of input busses
    UInt32 busCount   = _trackSettings.count;
    
    result = AudioUnitSetProperty (
                                   _mixerUnit,
                                   kAudioUnitProperty_ElementCount,
                                   kAudioUnitScope_Input,
                                   0,
                                   &busCount,
                                   sizeof (busCount)
                                   );
    CheckError(result, "Unable to set mixer unit bus count");
    
    _samplerNodes = [NSMutableArray new];
    for (TrackSetting *trackSetting in _trackSettings) {
        AUNode samplerNode = [self createSamplerNodeForTrackSetting:trackSetting];
        result = AUGraphConnectNodeInput(_graph, samplerNode, 0, _mixerNode, [_trackSettings indexOfObject:trackSetting]);
        CheckError(result, "Unable to obtain the reference to the ioUnit");
        [_samplerNodes addObject:[NSValue valueWithPointer:samplerNode]];
    }
    
    AUGraphInitialize (_graph);
    AUGraphStart (_graph);
    
    CAShow (_graph);
}

- (AUNode)createSamplerNodeForTrackSetting: (TrackSetting *)trackSetting {
    OSStatus result;
    AudioComponentDescription componentDescription = {};
    componentDescription.componentManufacturer     = kAudioUnitManufacturer_Apple;
    componentDescription.componentType = kAudioUnitType_MusicDevice;
    componentDescription.componentSubType = kAudioUnitSubType_Sampler;
    
    AudioUnit samplerUnit;
    AUNode samplerNode;
    result = AUGraphAddNode (_graph, &componentDescription, &samplerNode);
    CheckError(result, "unable to add the sampler node to the graph");
    result = AUGraphNodeInfo(_graph, samplerNode, 0, &samplerUnit);
    CheckError(result, "unable to obtain reference to sampler unit");
    NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:BANK_FILE_NAME ofType:@"dls"]];
    if (trackSetting.trackNumber != 3 )
        [self loadFromDLSOrSoundFont:presetURL withBank:kAUSampler_DefaultMelodicBankMSB withPatch:0 withSampler:samplerUnit];
    else
        [self loadFromDLSOrSoundFont:presetURL withBank:kAUSampler_DefaultMelodicBankMSB withPatch:114 withSampler:samplerUnit];
    return samplerNode;
}

-(OSStatus) loadFromDLSOrSoundFont: (NSURL *)bankURL withBank: (UInt8) bank withPatch: (int)presetNumber withSampler: (AudioUnit) sampler {
    OSStatus result;
    
    AUSamplerBankPresetData bpdata;
    bpdata.bankURL  = (__bridge CFURLRef) bankURL;
    bpdata.bankMSB  = bank;
    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
    bpdata.presetID = (UInt8) presetNumber;
    
    result = AudioUnitSetProperty(sampler,
                                  kAUSamplerProperty_LoadPresetFromBank,
                                  kAudioUnitScope_Global,
                                  0,
                                  &bpdata,
                                  sizeof(bpdata));
    
    CheckError(result, "unable to set the property on the sampler");
    return result;
}

- (void)playPressed{
    [self startAudioSequence];
}

- (void)stopPressed{
    [self stopAudioSequence];
}

- (void)startAudioSequence {
    [self configureSequence];
    NewMusicPlayer(&_player);
    
    MusicPlayerSetSequence(self.player, _sequence);
    MusicPlayerPreroll(self.player);
    MusicPlayerStart(self.player);
}

- (void)stopAudioSequence {
    MusicPlayerStop(_player);
}

- (void)configureSequence {
    MusicSequenceSetAUGraph(_sequence, _graph);
    
    UInt32 numberOfTracks = 0;
    MusicSequenceGetTrackCount(_sequence, &numberOfTracks);
    for (UInt32 i = 0; i < numberOfTracks; i ++) {
        MusicTrack track;
        MusicSequenceGetIndTrack(_sequence, i, &track);
        AUNode samplerNode;
        NSValue *value = _samplerNodes[i];
        [value getValue:&samplerNode];
        MusicTrackSetDestNode(track, samplerNode);
        
        MusicTimeStamp trackLen;
        MusicTrackGetProperty(track, kSequenceTrackProperty_TrackLength, &trackLen, 0);
        MusicTrackLoopInfo loopInfo = { 8, 0 };
        MusicTrackSetProperty(track, kSequenceTrackProperty_LoopInfo, &loopInfo, sizeof(loopInfo));
    }
}

- (void) loadMIDIFile:(NSString *)filepath; {
//    NSURL* url = [[NSBundle mainBundle] URLForResource:filepath withExtension:@"mid"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:filepath];
    NewMusicSequence(&_sequence);
    MusicSequenceFileLoad(_sequence, (__bridge CFURLRef)url, 0,0);
    
    MIDIParser *midiParser = [MIDIParser new];
    self.trackSettings = [midiParser parseMidiSequence:&_sequence];
    
    [self setupAudioSession];
    [self createAndStartGraph];
}

- (void)setSolo:(BOOL)solo trackIndex:(UInt32)trackIndex {
    MusicTrack track;
    MusicSequenceGetIndTrack(_sequence, trackIndex, &track);
    MusicTrackSetProperty(track, kSequenceTrackProperty_SoloStatus, &solo, sizeof(solo));
}

- (void) setMute:(BOOL) mute trackIndex:(UInt32)trackIndex {
    MusicTrack track;
    MusicSequenceGetIndTrack(_sequence, trackIndex, &track);
    MusicTrackSetProperty(track, kSequenceTrackProperty_MuteStatus, &mute, sizeof(mute));
}

- (BOOL) setupAudioSession {
    
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    // Assign the Playback category to the audio session. This category supports
    //    audio output with the Ring/Silent switch in the Silent position.
    NSError *audioSessionError = nil;
    [mySession setCategory: AVAudioSessionCategoryPlayback error: &audioSessionError];
    if (audioSessionError != nil) {NSLog (@"Error setting audio session category."); return NO;}
    
    // Activate the audio session
    [mySession setActive: YES error: &audioSessionError];
    if (audioSessionError != nil) {NSLog (@"Error activating the audio session."); return NO;}
    
    return YES;
}

-(void) cleanup
{
    CheckError(MusicPlayerStop(self.player), "MusicPlayerStop");
    
    UInt32 trackCount;
    CheckError(MusicSequenceGetTrackCount(self.sequence, &trackCount), "MusicSequenceGetTrackCount");
    MusicTrack track;
    for(int i = 0;i < trackCount; i++)
    {
        CheckError(MusicSequenceGetIndTrack (self.sequence,0,&track), "MusicSequenceGetIndTrack");
        CheckError(MusicSequenceDisposeTrack(self.sequence, track), "MusicSequenceDisposeTrack");
    }
    
    CheckError(DisposeMusicPlayer(self.player), "DisposeMusicPlayer");
    CheckError(DisposeMusicSequence(self.sequence), "DisposeMusicSequence");
    CheckError(DisposeAUGraph(self.graph), "DisposeAUGraph");
}

@end
