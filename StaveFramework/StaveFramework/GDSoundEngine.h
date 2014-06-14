//
//  GDSoundEngine2.h
//  PainoSpirit
//
//  Created by yizhq on 14-5-7.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    stopped   = 1,   /** Currently stopped */
    playing   = 2,   /** Currently playing music */
    paused    = 3,   /** Currently paused */
    initStop  = 4,   /** Transitioning from playing to stop */
    initPause = 5,   /** Transitioning from playing to pause */
};

@interface GDSoundEngine : NSObject

- (void) playPressed;
- (void) stopPressed;
- (void) loadMIDIFile:(NSString *)filepath;
- (void) cleanup;
@end
