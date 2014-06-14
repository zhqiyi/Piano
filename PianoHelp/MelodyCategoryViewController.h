//
//  MelodyCategoryViewController.h
//  PianoHelp
//
//  Created by Jobs on 14-5-15.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class MelodyCategory;

@interface MelodyCategoryViewController : BaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSInteger levelIndent;
@property (nonatomic, strong) MelodyCategory *parentCategory;
@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;

- (IBAction)btnBack_onclick:(id)sender;

@end
