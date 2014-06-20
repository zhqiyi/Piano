//
//  SFCountdownView.h
//  Pod
//
//  Created by Thomas Winkler on 10/02/14.
//  Copyright (c) 2014 SimpliFlow. All rights reserved.
//

#import "SFCountdownView.h"

@interface SFCountdownView ()

@property (nonatomic) NSTimer* timer;
@property (nonatomic) UILabel* countdownLabel;
@property (nonatomic) int currentCountdownValue;

@end

#define COUNTDOWN_LABEL_FONT_SCALE_FACTOR 0.3

@implementation SFCountdownView



- (id)initWithParentView:(UIView*)view
{
    parent = view;
    return self;
}


- (void) updateAppearance
{
    // countdown label
    float fontSize = parent.bounds.size.width * COUNTDOWN_LABEL_FONT_SCALE_FACTOR;
    
    self.countdownLabel = [[UILabel alloc] init];
    [self.countdownLabel setFont:[UIFont fontWithName:self.fontName size:fontSize]];
    [self.countdownLabel setTextColor:self.countdownColor];
    self.countdownLabel.textAlignment = NSTextAlignmentCenter;
    
    self.countdownLabel.opaque = YES;
    self.countdownLabel.alpha = 0.0;
    [parent addSubview: self.countdownLabel];
    
    self.countdownLabel.frame = CGRectMake(312, 300, 400, 200);
    
 //   [self.countdownLabel setCenter:parent.center];
}


#pragma mark - start/stopping
- (void) start
{
    [self stop];
    self.currentCountdownValue = self.countdownFrom;
    self.countdownLabel.alpha = 1.0;
    self.countdownLabel.text = [NSString stringWithFormat:@"%d", self.countdownFrom];
    [self animate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(animate)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void) stop
{
    if (self.timer && [self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - animation stuff

- (void) animate
{
    [UIView animateWithDuration:0.9 animations:^{
    
        CGAffineTransform transform = CGAffineTransformMakeScale(2.5, 2.5);
        self.countdownLabel.transform = transform;
        self.countdownLabel.alpha = 0;
        
    } completion:^(BOOL finished) {
        if (finished) {
            
             if (self.currentCountdownValue == 0) {
                 [self stop];
                 if (self.delegate) {
                     [self.delegate countdownFinished:self];
                     self.countdownLabel.text = nil;
                 }
                 
             } else {

                self.countdownLabel.transform = CGAffineTransformIdentity;
                self.countdownLabel.alpha = 1.0;
                
                self.currentCountdownValue--;
                if (self.currentCountdownValue == 0) {
                    self.countdownLabel.text = self.finishText;
                } else {
                    self.countdownLabel.text = [NSString stringWithFormat:@"%d", self.currentCountdownValue ];
                }
            }
        }
    }];
}

#pragma mark - custom getters
- (NSString*)finishText
{
    if (!_finishText) {
        _finishText = @"Go";
    }
    
    return _finishText;
}

- (int) countdownFrom
{
    if (_countdownFrom == 0) {
        _countdownFrom = kDefaultCountdownFrom;
    }
    
    return _countdownFrom;
}

- (UIColor*)countdownColor
{
    if (!_countdownColor) {
        _countdownColor = [UIColor blackColor];
    }
    
    return _countdownColor;
}

- (NSString *)fontName
{
    if (!_fontName) {
        _fontName = @"HelveticaNeue-Medium";
    }
    
    return _fontName;
}



@end
