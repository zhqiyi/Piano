//
//  PianoRecorder.h
//  StaveFramework
//
//  Created by zhengyw on 14-5-9.
//  Copyright (c) 2014年 yizhq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface PianoRecorder : NSObject<AVAudioRecorderDelegate>


-(id) init;
-(void) startRecord;
-(void) stopRecord;
-(BOOL) saveRecord:(NSString*)fileName;



@property (nonatomic, readwrite, strong) AVAudioRecorder* audioRecorder;


@end
