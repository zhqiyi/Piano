//
//  MusicPlayers.m
//  StaveFramework
//
//  Created by zhengyw on 14-5-12.
//  Copyright (c) 2014年 yizhq. All rights reserved.
//

#import "MusicPlayers.h"

@implementation MusicPlayers

- (BOOL) play:(NSString*)fileName {
    if (fileName == nil) FALSE;
    
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:NO error:nil];
        self.audioPlayer = nil;
    }
    
    NSURL *url = [NSURL URLWithString:fileName];
    self.audioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil] autorelease];
    [self.audioPlayer setDelegate:self];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [self.audioPlayer play];
    
    return TRUE;
}

-(void) stop {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
    }
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
    
}

- (void) dealloc {
    self.audioPlayer = nil;
    [super dealloc];
}

@end
