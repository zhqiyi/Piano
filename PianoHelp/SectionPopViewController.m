//
//  SectionPopViewController.m
//  PianoHelp
//
//  Created by Jobs on 14-6-2.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "SectionPopViewController.h"
#import "MelodyDetailViewController.h"

@interface SectionPopViewController ()
@property (nonatomic,weak) UITextField *txtCurrentInput;
@end


@implementation SectionPopViewController

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
    self.txtCurrentInput = self.txtFrom;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextField delegate method


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(textField.text.length > 4)
    {
        textField.text = [textField.text substringToIndex:textField.text.length-1];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.placeholder = @"Input Please";
    [textField resignFirstResponder];
    self.txtCurrentInput = textField;
}

- (IBAction)btnNumber_click:(id)sender
{
    self.txtCurrentInput.text = [NSString stringWithFormat:@"%@%ld",
                                 self.txtCurrentInput.text ? self.txtCurrentInput.text : @"",
                                 (long)[((UIButton*)sender) tag]
                                 ];
    [self.txtCurrentInput becomeFirstResponder];
    [self.txtCurrentInput resignFirstResponder];
}

- (IBAction)btnOK_click:(id)sender
{
    if(self.txtFrom.text.length<1)
    {
        
    }
    if(self.txtTo.text.length<1)
    {
        
    }
    [self.parentVC.popVC dismissPopoverAnimated:YES];
    
    int from = [self.txtFrom.text intValue];
    int to = [self.txtTo.text intValue];
    
    [self.shd splitMeasure:from andTo:to];
}

- (IBAction)btnDel_click:(id)sender
{
    if(self.txtCurrentInput.text.length >0)
        self.txtCurrentInput.text = [self.txtCurrentInput.text substringToIndex:self.txtCurrentInput.text.length-1];
}
@end
