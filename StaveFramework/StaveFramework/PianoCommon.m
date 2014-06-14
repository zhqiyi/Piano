//
//  PianoCommon.m
//  StaveFramework
//
//  Created by zhengyw on 14-5-26.
//  Copyright (c) 2014年 yizhq. All rights reserved.
//

#include <sys/sysctl.h>
#import "PianoCommon.h"

@implementation PianoCommon



+ (NSString*)getDeviceVersion
{
    size_t size;
    sysctlbyname("hw.machine",NULL,&size, NULL,0);
    
    char* machine = (char*)malloc(size);
    sysctlbyname("hw.machine",machine, &size, NULL,0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    NSLog(@"platform = %@", platform);
    
    return platform;
}


@end
