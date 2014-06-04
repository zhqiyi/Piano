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
#import "FavoriteTableViewCell.h"
#import "MelodyDetailViewController.h"

@interface QinFangViewController ()
@property (nonatomic, weak) UIButton *btnModel;
@property (nonatomic, weak) UIButton *btnScope;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController0;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController1;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController2;
@property (nonatomic, strong) NSMutableArray *melodyArray;
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
    [self btnScope_click:self.btnTask];
    self.btnScope = self.btnTask;
    [self.btnScope setSelected:YES];
    self.btnModel = self.btnPlayModel;
    [self.btnPlayModel setSelected:YES];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"melodyDetailSegue"])
    {
        MelodyDetailViewController *vc = segue.destinationViewController;
        vc.iPlayMode = self.btnModel.tag;
    }
}


#pragma mark - UITableView data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/*
	 If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
	 */
    return [self.melodyArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Dequeue a cell from self's table view.
    static NSString *CellIdentifier = @"FavoriteTableCell";
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    MelodyFavorite *melodyFavo = [self.melodyArray objectAtIndex:indexPath.row];
    [((FavoriteTableViewCell*)cell) updateContent:melodyFavo];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        // Delete the managed object.
        id mo = [self.fetchedResultsController0 objectAtIndexPath:indexPath];
        NSManagedObjectContext *context = [self.fetchedResultsController0 managedObjectContext];
        [context deleteObject:mo];
        [self.melodyArray removeObject:mo];
        NSError *error;
        if (![context save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }

}

#pragma mark - Fetched results controller

/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController0
{
    
    if (_fetchedResultsController0 != nil) {
        return _fetchedResultsController0;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MelodyFavorite" inManagedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSArray *sortArray = @[sort];
    [fetchRequest setSortDescriptors:sortArray];
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController0 = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest
                                 managedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext
                                 sectionNameKeyPath:@"sort"
                                 cacheName:nil];
    _fetchedResultsController0.delegate = self;
    
    return _fetchedResultsController0;
}

- (NSFetchedResultsController *)fetchedResultsController1
{
    
    if (_fetchedResultsController1 != nil) {
        return _fetchedResultsController1;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MelodyFavorite" inManagedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSArray *sortArray = @[sort];
    [fetchRequest setSortDescriptors:sortArray];
    
    if(self.btnScope.tag != 0)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sort = 1 or sort = 3"];
        [fetchRequest setPredicate:predicate];
    }
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController1 = [[NSFetchedResultsController alloc]
                                  initWithFetchRequest:fetchRequest
                                  managedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext
                                  sectionNameKeyPath:@"sort"
                                  cacheName:nil];
    _fetchedResultsController1.delegate = self;
    
    return _fetchedResultsController1;
}

- (NSFetchedResultsController *)fetchedResultsController2
{
    
    if (_fetchedResultsController2 != nil) {
        return _fetchedResultsController2;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MelodyFavorite" inManagedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSArray *sortArray = @[sort];
    [fetchRequest setSortDescriptors:sortArray];
    
    if(self.btnScope.tag != 0)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sort = 2 or sort = 3"];
        [fetchRequest setPredicate:predicate];
    }
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController2 = [[NSFetchedResultsController alloc]
                                  initWithFetchRequest:fetchRequest
                                  managedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext
                                  sectionNameKeyPath:@"sort"
                                  cacheName:nil];
    _fetchedResultsController2.delegate = self;
    
    return _fetchedResultsController2;
}

/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    static NSString *CellIdentifier = @"FavoriteTableCell";
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
        {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeUpdate:
        {
//            MelodyFavorite *melodyFavo = [self.fetchedResultsController0 objectAtIndexPath:indexPath];
            MelodyFavorite *melodyFavo = [self.melodyArray objectAtIndex:indexPath.row];
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            [((FavoriteTableViewCell*)cell) updateContent:melodyFavo];
            break;
        }
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
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
    
    
    if(self.btnScope.tag == 0)//all
    {
        NSError *error;
        if (![[self fetchedResultsController0] performFetch:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        self.melodyArray = [[[self fetchedResultsController0] fetchedObjects] mutableCopy];
        [self.tableView reloadData];
    }
    else if(self.btnScope.tag == 1)
    {
        NSError *error;
        if (![[self fetchedResultsController1] performFetch:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        self.melodyArray = [[[self fetchedResultsController1] fetchedObjects] mutableCopy];
        [self.tableView reloadData];
    }
    else if(self.btnScope.tag == 2)
    {
        NSError *error;
        if (![[self fetchedResultsController2] performFetch:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        self.melodyArray = [[[self fetchedResultsController2] fetchedObjects] mutableCopy];
        [self.tableView reloadData];
    }
}
@end
