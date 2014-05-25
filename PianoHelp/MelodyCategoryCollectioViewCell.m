//
//  MelodyCategoryCollectioViewCell.m
//  PianoHelp
//
//  Created by Jobs on 14-5-22.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "MelodyCategoryCollectioViewCell.h"
#import "MelodyCategory.h"

@implementation MelodyCategoryCollectioViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) updateContent:(id)obj
{
    MelodyCategory *category = (MelodyCategory*)obj;
    if(category.name)
        self.labTitle.text = category.name;
    if(category.cover)
    {
        self.imageViewBG.image = [UIImage imageNamed:category.cover];
    }
    if(category.buy)
    {
        self.imageViewBuy.hidden = YES;
    }
}

@end
