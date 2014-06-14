//
//  SFCountdownView.h
//  Pod
//
//  Created by Thomas Winkler on 10/02/14.
//  Copyright (c) 2014 SimpliFlow. All rights reserved.
//

#import <UIKit/UIKit.h>

static const int kDefaultCountdownFrom = 5;

@class SFCountdownView;

@protocol SFCountdownViewDelegate <NSObject>

@required
- (void) countdownFinished:(SFCountdownView *)view;

@end

@interface SFCountdownView : NSObject{
    UIView *parent;
}

@property (nonatomic, assign) int countdownFrom;
@property (nonatomic, assign) NSString* finishText;

// appearance settings
@property (nonatomic, assign) UIColor* countdownColor;
@property (nonatomic, assign) NSString* fontName;

@property (nonatomic, assign) id<SFCountdownViewDelegate> delegate;

- (id)initWithParentView:(UIView*)view;
- (void) updateAppearance;
- (void) start;
- (void) stop;

@end
