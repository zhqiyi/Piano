//
//  BaseTableViewCell.h
//  PianoHelp
//
//  Created by Jobs on 14-5-19.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BaseTableViewCell <NSObject>

@optional
-(void) updateContent:(id)obj;

@end

@interface BaseTableViewCell : UITableViewCell<BaseTableViewCell>

@end
