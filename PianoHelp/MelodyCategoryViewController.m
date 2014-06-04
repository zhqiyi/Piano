//
//  MelodyCategoryViewController.m
//  PianoHelp
//
//  Created by Jobs on 14-5-15.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "MelodyCategoryViewController.h"
#import "AppDelegate.h"
#import "MelodyCategory.h"
#import "MelodyCategoryCollectioViewCell.h"
#import "MelodyViewController.h"

@interface MelodyCategoryViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MelodyCategory *currentMelodyCategory;

@end

@implementation MelodyCategoryViewController

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
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
//    NSArray *arrayResult = self.fetchedResultsController.fetchedObjects;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.levelIndent == 0)
    {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    else if(self.levelIndent == 1)
    {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    if([[segue identifier] isEqualToString:@"pushMelody"])
    {
        MelodyViewController *vc = [segue destinationViewController];
        vc.title = self.currentMelodyCategory.name;
        vc.melodySet = self.currentMelodyCategory.melody;
    }
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    NSArray *sections = [self.fetchedResultsController sections];
    if([sections count] == 0) return 0;
    id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];

    MelodyCategory *selectedItem = (MelodyCategory *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    [((MelodyCategoryCollectioViewCell*)cell) updateContent:selectedItem];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.levelIndent == 0)
    {
        MelodyCategory *selectedItem = (MelodyCategory *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        [self.parentViewController performSegueWithIdentifier:@"pushMelodyLevelSegue" sender:selectedItem];
    }
    else if (self.levelIndent == 1)
    {
        self.currentMelodyCategory = (MelodyCategory *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"pushMelody" sender:nil];
    }
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:30];
    
    // Create the sort descriptors array.
    NSSortDescriptor *authorDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    //NSSortDescriptor *sortTitle = [NSSortDescriptor sortDescriptorWithKey:@"melody@name" ascending:YES];
    NSArray *sortDescriptors = @[authorDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    if(self.levelIndent == 0)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@)", @"parentCategory", nil];
        fetchRequest.predicate = predicate;
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(parentCategory = %@)", self.parentCategory, nil];
        fetchRequest.predicate = predicate;
    }
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest
                                 managedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext
                                 sectionNameKeyPath:@"name"
                                 cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

@end
