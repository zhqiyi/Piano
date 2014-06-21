//
//  RootViewController.h
//  PianoHelp
//
//  Created by Jobs on 14-5-12.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface RootViewController : BaseViewController

@property (nonatomic,weak) UIButton *lastClickButton;

@property (weak, nonatomic) IBOutlet UIButton *btnMelody;
@property (weak, nonatomic) IBOutlet UIButton *btnQinFang;
@property (weak, nonatomic) IBOutlet UIButton *btnShop;
@property (weak, nonatomic) IBOutlet UIButton *btnShow;

@property (weak, nonatomic) IBOutlet UIView *melodyContainerView;
@property (weak, nonatomic) IBOutlet UIView *qinFangContainerView;
@property (weak, nonatomic) IBOutlet UIView *shopContainerView;
@property (weak, nonatomic) IBOutlet UIView *showContainerView;
@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (weak, nonatomic) IBOutlet UIToolbar *topToolbar;

- (IBAction)buttonToolbar_click:(id)sender;
@end
