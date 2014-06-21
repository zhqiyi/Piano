//
//  SearchViewController.h
//  PianoHelp
//
//  Created by Jobs on 14-5-14.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MelodyViewController.h"

@interface SearchViewController : MelodyViewController <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end
