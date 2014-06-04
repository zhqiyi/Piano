//
//  MelodyDetailViewController.m
//  PianoHelp
//
//  Created by Jobs on 14-5-25.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "MelodyDetailViewController.h"
#import "SectionPopViewController.h"

@interface MelodyDetailViewController ()
{
    
}
@property (nonatomic,weak) UIButton *btnCurrent;
@end

@implementation MelodyDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if(IS_RUNNING_IOS7)
    {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"popoverSectionSegue"])
    {
        SectionPopViewController *vc = [segue destinationViewController];
        vc.parentVC = self;
        self.popVC = ((UIStoryboardPopoverSegue*)segue).popoverController;
    }
}


- (IBAction)btnBack_click:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setCurrentButtonState:(id)sender
{
    [self.btnCurrent setSelected:NO];
    UIButton *btn = (UIButton*)sender;
    [btn setSelected:YES];
    self.btnCurrent = btn;
}

- (IBAction)btnSection_click:(id)sender
{
    [self setCurrentButtonState:sender];
}

- (IBAction)btnHand_click:(id)sender
{
    [self setCurrentButtonState:sender];
}

- (IBAction)btnPeiLianYin_click:(id)sender
{
    [self setCurrentButtonState:sender];}

- (IBAction)btnHint_click:(id)sender
{
    [self setCurrentButtonState:sender];
}

- (IBAction)btnTryListen_click:(id)sender
{
    [self setCurrentButtonState:sender];
}

- (IBAction)btnRePlay_click:(id)sender {
}

- (IBAction)btnPlay_click:(id)sender {
}

- (IBAction)btnSudu_click:(id)sender {
}

- (IBAction)xiaoJieSlider_valueChanged:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [self.btnXiaoJieTiaoZhuan setTitle:[NSString stringWithFormat:@"% 1.1f", slider.value] forState:UIControlStateNormal];
}

- (IBAction)suduSlider_valueChanged:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [self.btnSuDu setTitle:[NSString stringWithFormat:@"% 1.1f", slider.value] forState:UIControlStateNormal];
}
@end
