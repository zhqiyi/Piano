//
//  MelodyDetailViewController.h
//  PianoHelp
//
//  Created by Jobs on 14-5-25.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "BaseViewController.h"

@interface MelodyDetailViewController : BaseViewController

@property (nonatomic) NSInteger iPlayMode;
@property (weak, nonatomic) IBOutlet UIButton *btnXiaoJieTiaoZhuan;
@property (weak, nonatomic) IBOutlet UIButton *btnSuDu;
@property (weak, nonatomic) UIPopoverController *popVC;

- (IBAction)btnBack_click:(id)sender;
- (IBAction)btnSection_click:(id)sender;
- (IBAction)btnHand_click:(id)sender;
- (IBAction)btnPeiLianYin_click:(id)sender;
- (IBAction)btnHint_click:(id)sender;
- (IBAction)btnTryListen_click:(id)sender;
- (IBAction)btnRePlay_click:(id)sender;
- (IBAction)btnPlay_click:(id)sender;
- (IBAction)btnSudu_click:(id)sender;

- (IBAction)xiaoJieSlider_valueChanged:(id)sender;
- (IBAction)suduSlider_valueChanged:(id)sender;

@end
