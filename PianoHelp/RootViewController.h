//
//  RootViewController.h
//  PianoHelp
//
//  Created by Jobs on 14-5-12.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController

@property (nonatomic,weak) UIButton *lastClickButton;

@property (weak, nonatomic) IBOutlet UIButton *btnMelody;
@property (weak, nonatomic) IBOutlet UIButton *btnQinFang;
@property (weak, nonatomic) IBOutlet UIButton *btnShop;
@property (weak, nonatomic) IBOutlet UIButton *btnShow;

@property (weak, nonatomic) IBOutlet UIView *melodyContainerView;
@property (weak, nonatomic) IBOutlet UIView *qinFangContainerView;
@property (weak, nonatomic) IBOutlet UIView *shopContainerView;
@property (weak, nonatomic) IBOutlet UIView *showContainerView;

- (IBAction)buttonToolbar_click:(id)sender;
@end
