//
//  MusicPlayers.h
//  StaveFramework
//
//  Created by zhengyw on 14-5-12.
//  Copyright (c) 2014年 yizhq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface MusicPlayers : NSObject<AVAudioPlayerDelegate>


- (BOOL) play:(NSString*)fileName;
- (void) stop;

@property (nonatomic, readwrite, strong) AVAudioPlayer* audioPlayer;

@end
