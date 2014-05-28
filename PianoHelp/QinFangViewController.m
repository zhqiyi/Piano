//
//  QinFangViewController.m
//  PianoHelp
//
//  Created by Jobs on 14-5-15.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "QinFangViewController.h"
#import "AppDelegate.h"
#import "MelodyFavorite.h"
#import "Melody.h"

@interface QinFangViewController ()
@property (nonatomic, weak) UIButton *btnModel;
@property (nonatomic, weak) UIButton *btnScope;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSArray *melodyArray;
@end

@implementation QinFangViewController

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
    self.btnScope = self.btnTask;
    [self.btnScope setSelected:YES];
    self.btnModel = self.btnPlayModel;
    [self.btnPlayModel setSelected:YES];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    self.melodyArray = [[self fetchedResultsController] fetchedObjects];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImage *image = [UIImage imageNamed:@"daohangtiao.png"];
    self.toolBar.backgroundColor = [UIColor colorWithPatternImage:image];

    //if(!IS_RUNNING_IOS7)
    {
        for (UIView *subView in self.toolBar.subviews)
        {
            if([subView isKindOfClass:[UIImageView class]])
            {
                [subView removeFromSuperview];
            }
        }
    }

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

#pragma mark - UITableView data source and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/*
	 If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
	 */
    return [self.melodyArray count];
}


#pragma mark - UITableView data source and delegate methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Dequeue a cell from self's table view.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    MelodyFavorite *melodyFavo = [self.melodyArray objectAtIndex:indexPath.row];
    cell.textLabel.text = melodyFavo.melody.name;
    return cell;
}


#pragma mark - Fetched results controller

/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MelodyFavorite" inManagedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSArray *sortArray = @[sort];
    [fetchRequest setSortDescriptors:sortArray];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sort = %@", [NSNumber numberWithInt:1]];
    [fetchRequest setPredicate:predicate];
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest
                                 managedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext
                                 sectionNameKeyPath:@"sort"
                                 cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

#pragma mark - ACTION

- (IBAction)btnModel_click:(id)sender
{
    if(self.btnModel != sender)
    {
        if(self.btnModel)
            [self.btnModel setSelected:NO];
        self.btnModel = sender;
        [self.btnModel setSelected:YES];
    }
    else
    {
        return;
    }
    if([self.btnModel tag] == 1)
    {
        
    }
    else if([self.btnModel tag] ==2)
    {
        
    }
    else
    {
        
    }
}

- (IBAction)btnScope_click:(id)sender
{
    if(self.btnScope != sender)
    {
        if(self.btnScope)
            [self.btnScope setSelected:NO];
        self.btnScope = sender;
        [self.btnScope setSelected:YES];
    }
    else
    {
        return;
    }
    if([self.btnScope tag] == 1)
    {
        
    }
    else if([self.btnScope tag] ==2)
    {
        
    }
    else
    {
        
    }
    
}
@end
