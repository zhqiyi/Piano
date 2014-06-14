//
//  PianoRecorder.m
//  StaveFramework
//
//  Created by zhengyw on 14-5-9.
//  Copyright (c) 2014年 yizhq. All rights reserved.
//

#import "PianoRecorder.h"

@implementation PianoRecorder

-(id)init {
    
    if ( self = [super init] ) {
        
        // Set the audio file
        NSArray *pathComponents = @[NSTemporaryDirectory(),
                                    @"__RecordTmp.m4a"];
        NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
        
        // Setup audio session
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        // Define the recorder setting
        NSDictionary* recordSetting = @{AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                        AVSampleRateKey : @(44100.0),
                                        AVNumberOfChannelsKey : @(2)};
        
        // Initiate and prepare the recorder
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL
                                                     settings:recordSetting
                                                        error:nil];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
        [_audioRecorder prepareToRecord];
        
    }
    
    return self;
}

- (BOOL) saveRecord:(NSString *)fileName {
    // user must input title name
    if (fileName == nil) {
        return FALSE;
    }
    
    //TBD: upload to cloud store
    
    // save record file
    NSArray *pathComponents = @[NSTemporaryDirectory(),
                                @"__RecordTmp.m4a"];
    
    NSURL *copyFromURL = [NSURL fileURLWithPathComponents:pathComponents];
    NSURL *copyToURL = [NSURL URLWithString:fileName];
    
    [[NSFileManager defaultManager] copyItemAtURL:copyFromURL toURL:copyToURL error:nil];
    
    return TRUE;
}

- (void) recording {
    if (!self.audioRecorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [self.audioRecorder record];
    }
}

- (void) startRecord {
    [self recording];
    
    //    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(recording) object:nil];
    //    [thread start];
}

-(void) stopRecord {
    if (self.audioRecorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:NO error:nil];
        [self.audioRecorder stop];
    }
}




#pragma mark - AVAudioRecorderDelegate & AVAudioPlayerDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag {
    
}



- (void) dealloc {
    self.audioRecorder = nil;
    [super dealloc];
}

@end
