//
//  ToneSignature.h
//  PainoSpirit
//
//  Created by 李洪胜 on 14-4-9.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToneSignature : NSObject {
    int tone;
	int starttime;
}

- (int) tone;
- (void) setTone:(int)tone;
- (int) starttime;
- (void) setStarttime:(int)starttime;
- (id) initWithTone:(int)tone andStarttime:(int)starttime;
//- (id) initWithTone:(Byte)tone andStarttime:(int)starttime;
@end

