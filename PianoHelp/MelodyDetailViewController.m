//
//  MelodyDetailViewController.m
//  PianoHelp
//
//  Created by Jobs on 14-5-25.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "MelodyDetailViewController.h"
#import "SectionPopViewController.h"

@interface MelodyDetailViewController ()
{
    
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
        self.popVC = ((UIStoryboardPopoverSegue*)segue).popoverController;
    }
}


- (IBAction)btnBack_click:(id)sender
{
    [player stop];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setCurrentButtonState:(id)sender
{
    [self.btnCurrent setSelected:NO];
    UIButton *btn = (UIButton*)sender;
    [btn setSelected:YES];
    self.btnCurrent = btn;
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
}

- (IBAction)btnTryListen_click:(id)sender
{
    [self setCurrentButtonState:sender];
}

- (IBAction)btnRePlay_click:(id)sender
{
    [player stop];
    [self.sfCountdownView start];
}

- (IBAction)btnPlay_click:(id)sender
{
    [self.sfCountdownView start];
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
    
    [player jumpMeasure:(int)slider.value];
}

- (IBAction)suduSlider_valueChanged:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [self.btnSuDu setTitle:[NSString stringWithFormat:@"%d", (int)slider.value] forState:UIControlStateNormal];
    
    [player changeSpeed:slider.value];
}

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
    CGRect frame = CGRectMake(0, 200, 1024, 498);
    scrollView= [[UIScrollView alloc] initWithFrame: frame];
    scrollView.contentSize= CGSizeMake(1024, height+280);
    
    
    [scrollView addSubview:sheetmusic];
    sheetmusic.scrollView = scrollView;
    sheetmsic1 = [[SheetMusicPlay alloc] initWithStaffs:[sheetmusic  getStaffs]
                                          andTrackCount: [sheetmusic getTrackCounts] andOptions:&options];
    sheetmsic1.frame = frame;
    [sheetmsic1 setZoom:zoom];
    sheetmsic1.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:sheetmsic1];
    [self.view addSubview:scrollView];
    
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


#pragma mark -
#pragma mark MidiPlayerDelegate
-(void)endSongs
{
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
    [self.view bringSubviewToFront:sheetmsic1];
    int type = (int)self.iPlayMode + 1;
    
    type = 2;//add by zyw test
    [player playByType:type];
}

@end
