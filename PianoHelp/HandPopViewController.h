//
//  HandPopViewController.h
//  PianoHelp
//
//  Created by luo on 14-6-21.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaveFramework/PianoCommon.h"
@class MelodyDetailViewController;

@interface HandPopViewController : UIViewController


@property (weak, nonatomic) MelodyDetailViewController *parentVC;
@property (nonatomic, assign) id <SheetMusicsDelegate> shd;

- (IBAction)btnLeft:(UIButton *)sender;
- (IBAction)btnRight:(UIButton *)sender;
- (IBAction)btnLeftRight_onclick:(id)sender;

@end
