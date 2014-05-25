//
//  MelodyCategoryCollectioViewCell.h
//  PianoHelp
//
//  Created by Jobs on 14-5-22.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MelodyCategoryCollectioViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageViewBG;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBuy;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;


-(void) updateContent:(id)obj;

@end
