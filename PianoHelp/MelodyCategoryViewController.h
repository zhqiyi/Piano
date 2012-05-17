//
//  MelodyCategoryViewController.h
//  PianoHelp
//
//  Created by Jobs on 14-5-15.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface MelodyCategoryViewController : BaseViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSInteger levelIndent;
@end
