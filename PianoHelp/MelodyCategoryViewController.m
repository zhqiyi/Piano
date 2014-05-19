//
//  MelodyCategoryViewController.m
//  PianoHelp
//
//  Created by Jobs on 14-5-15.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "MelodyCategoryViewController.h"

@interface MelodyCategoryViewController ()

@end

@implementation MelodyCategoryViewController

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
//    self.view.frame = CGRectMake(self.view.frame.origin.x,
//                                 self.view.frame.origin.y,
//                                 self.view.frame.size.width,
//                                 660);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.levelIndent == 0)
    {
        self.navigationController.navigationBar.hidden = YES;
        self.navigationController.toolbar.hidden = NO;
    }
    else if(self.levelIndent == 1)
    {
        self.navigationController.navigationBar.hidden = NO;
        self.navigationController.toolbar.hidden = YES;
        self.title = @"教材曲谱";
    }

    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    UICollectionViewCell *cell = nil;
    if(self.levelIndent == 0)
    {
        cell = [cv dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    }
    else
    {
        cell = [cv dequeueReusableCellWithReuseIdentifier:@"cellIdentifier1" forIndexPath:indexPath];
    }
    
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    MelodyCategoryViewController *vc  = [self.storyboard instantiateViewControllerWithIdentifier:@"MelodyCategoryViewController"];
//    vc.levelIndent = 1;
//    [self.parentViewController.navigationController pushViewController:vc animated:YES];
    if(self.levelIndent == 0)
        [self.parentViewController performSegueWithIdentifier:@"pushMelodyLevel" sender:nil];
    else if (self.levelIndent == 1)
    {
        [self performSegueWithIdentifier:@"pushMelody" sender:nil];
    }
}


@end
