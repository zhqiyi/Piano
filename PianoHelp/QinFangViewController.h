//
//  QinFangViewController.h
//  PianoHelp
//
//  Created by Jobs on 14-5-15.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QinFangViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIButton *btnTask;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayModel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)btnModel_click:(id)sender;
- (IBAction)btnScope_click:(id)sender;

@end
