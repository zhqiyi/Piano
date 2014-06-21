//
//  ShopViewController.m
//  PianoHelp
//
//  Created by Jobs on 14-5-15.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "ShopViewController.h"
#import "AppDelegate.h"

@interface ShopViewController ()

@end

@implementation ShopViewController

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"UITableViewCell";
    
    // Dequeue a cell from self's table view.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	/*
	 If the requesting table view is the search display controller's table view, configure the cell using the search results array, otherwise use the product array.
	 */
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (IBAction)btnTest_onclick:(id)sender
{
    [((AppDelegate*)[UIApplication sharedApplication].delegate) loadDemoMidiToSQL];
}

- (IBAction)btnBack_onclick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
