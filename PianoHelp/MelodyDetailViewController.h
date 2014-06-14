//
//  MelodyDetailViewController.h
//  PianoHelp
//
//  Created by Jobs on 14-5-25.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "BaseViewController.h"

#import "StaveFramework/MidiFile.h"
#import "StaveFramework/MidiPlayer.h"
#import "StaveFramework/Piano.h"
#import "StaveFramework/SheetMusic.h"
#import "StaveFramework/SheetMusicPlay.h"
#import "StaveFramework/SFCountdownView.h"

@interface MelodyDetailViewController : BaseViewController <SFCountdownViewDelegate, MidiPlayerDelegate>
{
    MidiFile *midifile;         /** The midifile that was read */
    SheetMusic *sheetmusic;     /** The sheet music to display */
    UIScrollView *scrollView;   /** For scrolling through the sheet music */
    MidiPlayer *player;         /** The top panel for playing the music */
    Piano *piano;               /** The piano at the top, for highlighting notes */
    float zoom;                 /** The zoom level */
    MidiOptions options;        /** The options selected in the menus */
    
    SheetMusicPlay *sheetmsic1;
}

@property (nonatomic) NSInteger iPlayMode;
@property (weak, nonatomic) IBOutlet UIButton *btnXiaoJieTiaoZhuan;
@property (weak, nonatomic) IBOutlet UIButton *btnSuDu;
@property (weak, nonatomic) UIPopoverController *popVC;
@property (weak, nonatomic) IBOutlet UISlider *sliderXiaoJie;
@property (weak, nonatomic) IBOutlet UISlider *sliderSpeed;

@property (strong, nonatomic) NSString *fileName;

- (IBAction)btnBack_click:(id)sender;
- (IBAction)btnSection_click:(id)sender;
- (IBAction)btnHand_click:(id)sender;
- (IBAction)btnPeiLianYin_click:(id)sender;
- (IBAction)btnHint_click:(id)sender;
- (IBAction)btnTryListen_click:(id)sender;
- (IBAction)btnRePlay_click:(id)sender;
- (IBAction)btnPlay_click:(id)sender;
- (IBAction)btnSudu_click:(id)sender;

- (IBAction)xiaoJieSlider_valueChanged:(id)sender;
- (IBAction)suduSlider_valueChanged:(id)sender;

@end
