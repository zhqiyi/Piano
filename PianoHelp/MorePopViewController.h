//
//  MorePopViewController.h
//  PianoHelp
//
//  Created by Jobs on 6/21/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewControllerDelegate <NSObject>

-(void)quit;

@end

@interface MorePopViewController : UIViewController
{
    
}
@property (nonatomic, weak) id<LoginViewControllerDelegate> loginDelegate;
- (IBAction)btnQuit_onclick:(id)sender;

@end
