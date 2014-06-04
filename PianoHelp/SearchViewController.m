//
//  SearchViewController.m
//  PianoHelp
//
//  Created by Jobs on 14-5-14.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "SearchViewController.h"
#import "AppDelegate.h"
#import "MelodyTableViewCell.h"

@interface SearchViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation SearchViewController

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
    //self.view.tintColor = [UIColor purpleColor];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCompare:)];
    self.melodyArray = [[[self fetchedResultsController] fetchedObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    self.searchResults = [NSMutableArray arrayWithCapacity:[self.melodyArray count]];
    self.title = @"搜索曲库";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    self.navigationController.navigationBar.tintColor = nil;

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Dequeue a cell from self's table view.
	MelodyTableViewCell *cell = (MelodyTableViewCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.isInSearch = YES;
    [cell updateContent:cell.melody];
    return (UITableViewCell*)cell;
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Melody" inManagedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortArray = @[sort];
    [fetchRequest setSortDescriptors:sortArray];

    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest
                                 managedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext
                                 sectionNameKeyPath:@"name"
                                 cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

-(void)updateMelodyState
{
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCompare:)];
    self.melodyArray = [[[self fetchedResultsController] fetchedObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    self.searchResults = [self.melodyArray mutableCopy];//save result for sort of scope.
    [self.tableView reloadData];
}

#pragma mark - UISearchDisplayController Delegate Methods

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [super searchDisplayControllerDidEndSearch:controller];
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
