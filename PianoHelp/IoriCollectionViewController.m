//
//  IoriCollectionViewController.m
//  PianoHelp
//
//  Created by Jobs on 14-6-9.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "IoriCollectionViewController.h"
#import "GridLayout.h"

@interface IoriCollectionViewController ()

@end

@implementation IoriCollectionViewController

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
    [self.collectionView setCollectionViewLayout:[[GridLayout alloc] init]];

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
