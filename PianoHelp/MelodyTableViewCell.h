//
//  MelodyTableViewCell.h
//  PianoHelp
//
//  Created by Jobs on 14-5-19.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "MelodyButton.h"

@protocol MelodyTableViewCellDelegate <NSObject>

@optional
-(void)updateMelodyState;

@end

@class Melody;

@interface MelodyTableViewCell : BaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labNum;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnFavorite;
@property (weak, nonatomic) IBOutlet UIButton *btnTask;
@property (weak, nonatomic) IBOutlet UIButton *btnBuy;
@property (weak, nonatomic) IBOutlet MelodyButton *btnView;
@property (weak, nonatomic) IBOutlet UILabel *labBuy;

@property (strong, nonatomic) Melody *melody;
@property (nonatomic) BOOL isInSearch;
@property (weak, nonatomic) id<MelodyTableViewCellDelegate> updateDelegate;

- (IBAction)btnFavorite_click:(id)sender;
- (IBAction)btnTask_click:(id)sender;
- (IBAction)btnBuy_click:(id)sender;
- (IBAction)btnView_click:(id)sender;


@end
