//
//  MelodyDetailViewController.m
//  PianoHelp
//
//  Created by Jobs on 14-5-25.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "MelodyDetailViewController.h"
#import "SectionPopViewController.h"
#import "HandPopViewController.h"
#import "SoundPopViewController.h"

@interface MelodyDetailViewController ()
{
    BOOL isHitAnimating;
}
@property (nonatomic,weak) UIButton *btnCurrent;
@property (strong, nonatomic) SFCountdownView *sfCountdownView;
@end

@implementation MelodyDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.fileName == nil) return;
    
    midifile = [[MidiFile alloc] initWithFile:self.fileName];
    [midifile initOptions:&options];
    
    //set measure count
    self.sliderXiaoJie.maximumValue = [midifile getMeasureCount];
    self.sliderSpeed.value = 60000000/[[midifile time] tempo];
    [self.btnSuDu setTitle:[NSString stringWithFormat:@"%d", (int)self.sliderSpeed.value] forState:UIControlStateNormal];
    
    [self loadSheetMusick];
    
    self.sfCountdownView = [[SFCountdownView alloc] initWithParentView:self.view];
    self.sfCountdownView.delegate = self;
    self.sfCountdownView.countdownColor = [UIColor blackColor];
    self.sfCountdownView.countdownFrom = 3;
    [self.sfCountdownView updateAppearance];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if(IS_RUNNING_IOS7)
    {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"popoverSectionSegue"])
    {
        SectionPopViewController *vc = [segue destinationViewController];
        vc.parentVC = self;
        vc.shd = self;
        self.popVC = ((UIStoryboardPopoverSegue*)segue).popoverController;
    }
    
    if([segue.identifier isEqualToString:@"popoverHandSegue"])
    {
        HandPopViewController *vc = [segue destinationViewController];
        vc.parentVC = self;
        vc.shd = self;
        self.popVC = ((UIStoryboardPopoverSegue*)segue).popoverController;
    }
    
    if([segue.identifier isEqualToString:@"popoverSoundSegue"])
    {
        SoundPopViewController *vc = [segue destinationViewController];
        vc.parentVC = self;
        vc.shd = self;
        self.popVC = ((UIStoryboardPopoverSegue*)segue).popoverController;
    }
}

#pragma mark - IBAction

- (IBAction)btnBack_click:(id)sender
{
    [player stop];
    if([self.fixSearchDisplayDelegate respondsToSelector:@selector(fixSearchBarPosition)])
    {
        //[self.fixSearchDisplayDelegate fixSearchBarPosition];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setCurrentButtonState:(id)sender
{
//    [self.btnCurrent setSelected:NO];
//    UIButton *btn = (UIButton*)sender;
//    [btn setSelected:YES];
//    self.btnCurrent = btn;
}

- (IBAction)btnSection_click:(id)sender
{
    [self setCurrentButtonState:sender];
}

- (IBAction)btnHand_click:(id)sender
{
    [self setCurrentButtonState:sender];
}

- (IBAction)btnPeiLianYin_click:(id)sender
{
    [self setCurrentButtonState:sender];}

- (IBAction)btnHint_click:(id)sender
{
    [self setCurrentButtonState:sender];
    if(isHitAnimating) return;
    isHitAnimating = YES;
    if(piano.hidden)
    {
        piano.hidden = NO;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            scrollView.frame = CGRectMake(0, 130, 1024, scrollView.frame.size.height-55);
            sheetmsic1.frame = CGRectMake(0, 130, sheetmsic1.frame.size.width, sheetmsic1.frame.size.height);
        } completion:^(BOOL finished) {
            isHitAnimating = NO;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            scrollView.frame = CGRectMake(0, 75, 1024, scrollView.frame.size.height+55);
            sheetmsic1.frame = CGRectMake(0, 75, sheetmsic1.frame.size.width, sheetmsic1.frame.size.height);
        } completion:^(BOOL finished) {
            piano.hidden = YES;
            isHitAnimating = NO;
        }];
    }
}

- (IBAction)btnTryListen_click:(id)sender
{
    [self setCurrentButtonState:sender];
    [player playByType:1];
}

- (IBAction)btnRePlay_click:(id)sender
{
    [player stop];
    [self.sfCountdownView start];
}

- (IBAction)btnPlay_click:(id)sender
{
    [self.sfCountdownView start];
    if([((UIButton*)sender) isSelected])
    {
        [((UIButton*)sender) setSelected:false];
        [player playPause];
    }
    else
    {
        [((UIButton*)sender) setSelected:true];
    }
}

- (IBAction)btnSudu_click:(id)sender
{
    self.sliderSpeed.value = 60000000/[[midifile time] tempo];
    [self.btnSuDu setTitle:[NSString stringWithFormat:@"%d", (int)self.sliderSpeed.value] forState:UIControlStateNormal];
}

- (IBAction)xiaoJieSlider_valueChanged:(id)sender
{
//    UISlider *slider = (UISlider*)sender;
//    [self.btnXiaoJieTiaoZhuan setTitle:[NSString stringWithFormat:@"% 1.1f", slider.value] forState:UIControlStateNormal];
    UISlider *slider = (UISlider*)sender;
    [self.btnXiaoJieTiaoZhuan setTitle:[NSString stringWithFormat:@"%d", (int)slider.value] forState:UIControlStateNormal];
    
    [player jumpMeasure:(int)slider.value-1];
}

- (IBAction)suduSlider_valueChanged:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [self.btnSuDu setTitle:[NSString stringWithFormat:@"%d", (int)slider.value] forState:UIControlStateNormal];
    
    [player changeSpeed:slider.value];
}

#pragma mark - private method

- (void) loadSheetMusick
{
    CGRect screensize = [[UIScreen mainScreen] applicationFrame];
    if (screensize.size.width >= 1200) {
        zoom = 1.5f;
    }
    else {
        zoom = 1.27f;
    }
    
    options.shadeColor = [UIColor grayColor];
    options.shade2Color = [UIColor greenColor];
    
    sheetmusic = [[SheetMusic alloc] initWithFile:midifile andOptions:&options];
    [sheetmusic setZoom:zoom];
    
    
    /* init player */
    piano = [[Piano alloc] init];
    piano.frame = CGRectMake(0, 75, 1024, 120);
    [self.view addSubview:piano];
    
    float height = sheetmusic.frame.size.height;
    CGRect frame = CGRectMake(0, 130, 1024, 768-75-130);
    scrollView= [[UIScrollView alloc] initWithFrame: frame];
    scrollView.contentSize= CGSizeMake(1024, height+280);
    scrollView.backgroundColor = [UIColor whiteColor];
    
    
    [scrollView addSubview:sheetmusic];
    sheetmusic.scrollView = scrollView;
    sheetmsic1 = [[SheetMusicPlay alloc] initWithStaffs:[sheetmusic  getStaffs]
                                          andTrackCount: [sheetmusic getTrackCounts] andOptions:&options];
    sheetmsic1.frame = frame;
    [sheetmsic1 setZoom:zoom];
    sheetmsic1.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:sheetmsic1];
    [self.view addSubview:scrollView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.delegate = self;
    //[sheetmusic addGestureRecognizer:tapGesture];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.delegate = self;
    [sheetmsic1 addGestureRecognizer:tapGesture];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.delegate = self;
    [scrollView addGestureRecognizer:tapGesture];
    
    if (player != nil)
    {
        //[player release];
    }
    player = [[MidiPlayer alloc] init];
    player.sheetPlay = sheetmsic1;
    [player changeSpeed:self.sliderSpeed.value];
    [player setMidiFile:midifile withOptions:&options andSheet:sheetmusic];
    
    [piano setShade:[UIColor blueColor] andShade2:[UIColor redColor]];
    [piano setMidiFile:midifile withOptions:&options];
    [player setPiano:piano];
}

-(void)hiddenMenuAndToolBar
{
    if(self.menuBar.hidden)
    {
        self.menuBar.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.menuBar.frame = CGRectMake(0, 0, 1024, 75);
            self.toolBar.frame = CGRectMake(0, 693, 1024, 75);
            scrollView.frame = CGRectMake(0,
                                          scrollView.frame.origin.y+75 ,
                                          scrollView.frame.size.width,
                                          scrollView.frame.size.height-75*2 );
            sheetmsic1.frame = CGRectMake(0,
                                          sheetmsic1.frame.origin.y+75,
                                          sheetmsic1.frame.size.width,
                                          sheetmsic1.frame.size.height);
            piano.frame = CGRectMake(0,
                                     piano.frame.origin.y + 75,
                                     piano.frame.size.width,
                                     piano.frame.size.height);
        } completion:^(BOOL finished) {
            ;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.menuBar.frame = CGRectMake(0, -75, 1024, 75);
            self.toolBar.frame = CGRectMake(0, 693+75, 1024, 75);
            scrollView.frame = CGRectMake(0,
                                          scrollView.frame.origin.y-75,
                                          scrollView.frame.size.width,
                                          scrollView.frame.size.height+75*2);
            sheetmsic1.frame = CGRectMake(0,
                                          sheetmsic1.frame.origin.y-75,
                                          sheetmsic1.frame.size.width,
                                          sheetmsic1.frame.size.height);
            piano.frame = CGRectMake(0,
                                     piano.frame.origin.y - 75,
                                     piano.frame.size.width,
                                     piano.frame.size.height);
        } completion:^(BOOL finished) {
            self.menuBar.hidden = YES;
        }];
    }
}


#pragma mark -
#pragma mark MidiPlayerDelegate
-(void)endSongs
{
    [self.view bringSubviewToFront:scrollView];
    NSLog(@"the song is end");
}


-(void)endSongsResult:(int)good andRight:(int)right andWrong:(int)wrong
{
    NSLog(@"the result good[%i] right[%i] wrong[%i]", good, right, wrong);
}

#pragma mark -
#pragma mark SFCountdownViewDelegate
- (void) countdownFinished:(SFCountdownView *)view
{
    int type = (int)self.iPlayMode + 1;
    switch (type) {
        case 1:
            break;
        case 2:
            [self.view bringSubviewToFront:sheetmsic1];
            break;
        case 3:
            [self.view bringSubviewToFront:sheetmsic1];
            break;
    }
    [player playByType:type];
}

#pragma mark - UIGestureRecognizerDelegate

- (IBAction)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        // handling code
        [self hiddenMenuAndToolBar];
    }
}



#pragma mark - Delegate
//拆分小节
- (void) splitMeasure:(int) from andTo:(int)to
{
    [sheetmusic setJSModel:from withEndSectionNum:to withTimeNumerator:[[midifile time] numerator] withTimeQuarter:[[midifile time]quarter] withMeasure:[[midifile time]measure]];
    
    
    [self loadSheetMusick];
    [player playJumpSection:from];
}

//左右手模式
- (void) handModel:(int)value
{
    switch (value)
    {
        case 0://左右手模式
            [midifile leftHandMute:&options andState:NO];
            [midifile rightHandMute:&options andState:NO];
            break;
        case 1://左手模式
            if ([midifile getLeftHadnMuteState:&options] == YES)
            {
                [midifile leftHandMute:&options andState:NO];
            }
            else
            {
                [midifile leftHandMute:&options andState:YES];
            }
            break;
        case 2://右手模式
            if ([midifile getRightHadnMuteState:&options] == YES)
            {
                [midifile rightHandMute:&options andState:NO];
            }
            else
            {
                [midifile rightHandMute:&options andState:YES];
            }
            break;
        default:
            break;
    }
}


//陪练音开启关闭
- (void) SparringMute:(int)value
{
    if (value == 1) {//开启
        [midifile leftHandMute:&options andState:YES];
        [midifile rightHandMute:&options andState:YES];
    } else {//关闭
        [midifile leftHandMute:&options andState:NO];
        [midifile rightHandMute:&options andState:NO];
    }
}

//节拍器开启关闭
- (void) beatMute:(int)value
{
    if (value == 1) {//开启
        
    } else {//关闭
        
    }

}

-(void)dealloc
{
    
}


@end
