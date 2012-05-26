//
//  RootViewController.m
//  PianoHelp
//
//  Created by Jobs on 14-5-12.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "RootViewController.h"
#import "MelodyCategoryViewController.h"
#import "MelodyCategory.h"

@interface RootViewController ()

@end

@implementation RootViewController

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
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ditu.png"]];
    imageView.frame = CGRectMake(0, 0, 1024, 768);
    [self.view addSubview:imageView];
    
    self.lastClickButton = self.btnMelody;
    [self.lastClickButton setSelected:YES];
    self.title = @"首页";
    UIImage *image = [UIImage imageNamed:@"daohangtiao.png"];
    self.topToolbar.backgroundColor = [UIColor colorWithPatternImage:image];
//    
//    MelodyCategoryViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MelodyCategoryViewController"];
//    [self addChildViewController:vc];
//    [self.contentView addSubview:vc.view];
    //if(!IS_RUNNING_IOS7)
    {
        for (UIView *subView in self.topToolbar.subviews)
        {
            if([subView isKindOfClass:[UIImageView class]])
            {
                [subView removeFromSuperview];
            }
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;

    if(!IS_RUNNING_IOS7)
    {
        self.navigationController.navigationBar.tintColor = nil;
    }
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
    if([[segue identifier] isEqualToString:@"pushMelodyLevel"])
    {
        MelodyCategoryViewController *vc = [segue destinationViewController];
        vc.levelIndent = 1;
        vc.title = ((MelodyCategory*)sender).name;
        vc.parentCategory = sender;
        ///vc.navigationController.navigationBar.hidden = NO;
    }
}


- (IBAction)buttonToolbar_click:(id)sender
{
    if(self.lastClickButton)
    {
        [self.lastClickButton setSelected:NO];
    }
    self.lastClickButton = sender;
    [self.lastClickButton setSelected:YES];
    if(sender == self.btnMelody)
    {
        self.melodyContainerView.hidden = NO;
        self.qinFangContainerView.hidden = YES;
        self.shopContainerView.hidden = YES;
        self.showContainerView.hidden = YES;
    }
    else if(sender ==  self.btnQinFang)
    {
        self.qinFangContainerView.hidden = NO;
        self.melodyContainerView.hidden = YES;
        self.shopContainerView.hidden = YES;
        self.showContainerView.hidden = YES;
    }
    else if(sender == self.btnShop)
    {
        self.melodyContainerView.hidden = YES;
        self.qinFangContainerView.hidden = YES;
        self.shopContainerView.hidden = NO;
        self.showContainerView.hidden = YES;
    }
    else if(sender == self.btnShow)
    {
        self.melodyContainerView.hidden = YES;
        self.qinFangContainerView.hidden = YES;
        self.shopContainerView.hidden = YES;
        self.showContainerView.hidden = NO;
    }
}


@end
