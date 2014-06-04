//
//  MelodyViewController.m
//  PianoHelp
//
//  Created by Jobs on 14-5-15.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "MelodyViewController.h"

extern NSString *ScopeAuthor;
extern NSString *ScopeSongName;

@interface MelodyViewController ()

@end

@implementation MelodyViewController

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
//    self.title = @"英皇考级教材曲谱";
//    
//    NSArray *productArray = @[[APLProduct productWithType:ScopeAuthor name:@"聂耳－黄河大合唱"],
//                              [APLProduct productWithType:ScopeAuthor name:@"帕瓦罗蒂－我的太阳"],
//                              [APLProduct productWithType:ScopeSongName name:@"贝多纷第一交响曲"],
//                              [APLProduct productWithType:ScopeSongName name:@"贝多纷第二交响曲"],
//                              [APLProduct productWithType:ScopeSongName name:@"贝多纷第三交响曲"],
//                              [APLProduct productWithType:ScopeSongName name:@"贝多纷第四交响曲"],
//                              [APLProduct productWithType:ScopeSongName name:@"贝多纷第五交响曲"]];

    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCompare:)];
    self.melodyArray = [[self.melodySet allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    self.searchResults = [NSMutableArray arrayWithCapacity:[self.melodyArray count]];
    
    /*
     Set up the search scope buttons with titles using products' localized display names.
     */
    NSMutableArray *scopeButtonTitles = [[NSMutableArray alloc] init];
    //[scopeButtonTitles addObject:NSLocalizedString(@"全部", @"Title for the All button in the search display controller.")];
    
    for (NSString *deviceType in [APLProduct deviceTypeNames])
    {
        NSString *displayName = [APLProduct displayNameForType:deviceType];
        [scopeButtonTitles addObject:displayName];
    }
    
    self.searchDisplayController.searchBar.scopeButtonTitles = scopeButtonTitles;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //self.navigationController.navigationBar.hidden = NO;
    [self.searchDisplayController searchResultsTableView].rowHeight = 64;
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
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [self.searchResults count];
    }
	else
	{
        return [self.melodyArray count];
    }
}


#pragma mark - UITableView data source and delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"melodyCell";
    
    // Dequeue a cell from self's table view.
	MelodyTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellID];
	/*
	 If the requesting table view is the search display controller's table view, configure the cell using the search results array, otherwise use the product array.
	 */
	Melody *melody;
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        melody = [self.searchResults objectAtIndex:indexPath.row];
    }
	else
	{
        melody = [self.melodyArray objectAtIndex:indexPath.row];
    }
    
    cell.labNum.text = [NSString stringWithFormat:@"%03ld", (long)indexPath.row+1];
    
	[cell updateContent:melody];
    cell.updateDelegate = self;
	return (UITableViewCell*)cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - Content Filtering

- (void)updateFilteredContentForSearchString:(NSString *)strSearch type:(NSString *)typeName
{
    if ((strSearch == nil) || [strSearch length] == 0)
    {
        self.searchResults = [self.melodyArray mutableCopy];
        return;
    }
    
    [self.searchResults removeAllObjects];

    for (Melody *melody in self.melodyArray)
	{
        NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
        NSRange range, foundRange;
        if([typeName isEqualToString:ScopeSongName])
        {
            range = NSMakeRange(0, melody.name.length);
            foundRange = [melody.name rangeOfString:strSearch options:searchOptions range:range];
        }
        else if([typeName isEqualToString:ScopeAuthor])
        {
            range = NSMakeRange(0, melody.author.length);
            foundRange = [melody.author rangeOfString:strSearch options:searchOptions range:range];
        }
        if (foundRange.length > 0)
        {
            [self.searchResults addObject:melody];
        }
	}
}


#pragma mark - UISearchDisplayController Delegate Methods

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self updateMelodyState];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSInteger selectedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    NSString *scope = [[APLProduct deviceTypeNames] objectAtIndex:(selectedScopeButtonIndex)];
    [self updateFilteredContentForSearchString:searchString type:scope];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSString *searchString = [self.searchDisplayController.searchBar text];
    NSString *scope = [[APLProduct deviceTypeNames] objectAtIndex:(searchOption)];
    [self updateFilteredContentForSearchString:searchString type:scope];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - MelodyTableViewCellDelegate

-(void)updateMelodyState
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCompare:)];
    self.melodyArray = [[self.melodySet allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    self.searchResults = [self.melodyArray mutableCopy];//save result for sort of scope.
    [self.tableView reloadData];
}

@end
