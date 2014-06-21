//
//  FavoriteTableViewCell.h
//  PianoHelp
//
//  Created by Jobs on 14-5-30.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "MelodyButton.h"

@interface FavoriteTableViewCell : BaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labAuthor;
@property (weak, nonatomic) IBOutlet UILabel *labScore;
@property (weak, nonatomic) IBOutlet UIButton *btnRank;
@property (weak, nonatomic) IBOutlet MelodyButton *btnPlay;

@end
