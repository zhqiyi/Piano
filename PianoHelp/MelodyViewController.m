//
//  MelodyViewController.m
//  PianoHelp
//
//  Created by Jobs on 14-5-15.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "MelodyViewController.h"
#import "APLProduct.h"

@interface MelodyViewController ()
@property (nonatomic) NSMutableArray *searchResults;
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
    self.title = @"英皇考级教材曲谱";
    
    NSArray *productArray = @[[APLProduct productWithType:ProductTypeDevice name:@"黄河大合唱"],
                              [APLProduct productWithType:ProductTypeDevice name:@"我的太阳"],
                              [APLProduct productWithType:ProductTypeDevice name:@"贝多纷第一交响曲"],
                              [APLProduct productWithType:ProductTypeDevice name:@"贝多纷第二交响曲"],
                              [APLProduct productWithType:ProductTypeDevice name:@"贝多纷第三交响曲"],
                              [APLProduct productWithType:ProductTypeDesktop name:@"贝多纷第四交响曲"],
                              [APLProduct productWithType:ProductTypeDesktop name:@"贝多纷第五交响曲"]];

    self.products = productArray;
    
    self.searchResults = [NSMutableArray arrayWithCapacity:[self.products count]];
    
    /*
     Set up the search scope buttons with titles using products' localized display names.
     */
    NSMutableArray *scopeButtonTitles = [[NSMutableArray alloc] init];
    [scopeButtonTitles addObject:NSLocalizedString(@"全部", @"Title for the All button in the search display controller.")];
    
    for (NSString *deviceType in [APLProduct deviceTypeNames])
    {
        NSString *displayName = [APLProduct displayNameForType:deviceType];
        [scopeButtonTitles addObject:displayName];
    }
    
    self.searchDisplayController.searchBar.scopeButtonTitles = scopeButtonTitles;
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
        return [self.products count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"melodyCell";
    
    // Dequeue a cell from self's table view.
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellID];
    
//    if(!cell)
//    {
//        cell = [[UITableViewCell alloc]init];
//    }
    
	/*
	 If the requesting table view is the search display controller's table view, configure the cell using the search results array, otherwise use the product array.
	 */
	APLProduct *product;
    
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        product = [self.searchResults objectAtIndex:indexPath.row];
    }
	else
	{
        product = [self.products objectAtIndex:indexPath.row];
    }
    
	cell.textLabel.text = product.name;
	return cell;
}


#pragma mark - Content Filtering

- (void)updateFilteredContentForProductName:(NSString *)productName type:(NSString *)typeName
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
    if ((productName == nil) || [productName length] == 0)
    {
        // If there is no search string and the scope is "All".
        if (typeName == nil)
        {
            self.searchResults = [self.products mutableCopy];
        }
        else
        {
            // If there is no search string and the scope is chosen.
            NSMutableArray *searchResults = [[NSMutableArray alloc] init];
            for (APLProduct *product in self.products)
            {
                if ([product.type isEqualToString:typeName])
                {
                    [searchResults addObject:product];
                }
            }
            self.searchResults = searchResults;
        }
        return;
    }
    
    
    [self.searchResults removeAllObjects]; // First clear the filtered array.
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
    for (APLProduct *product in self.products)
	{
		if ((typeName == nil) || [product.type isEqualToString:typeName])
		{
            NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
            NSRange productNameRange = NSMakeRange(0, product.name.length);
            NSRange foundRange = [product.name rangeOfString:productName options:searchOptions range:productNameRange];
            if (foundRange.length > 0)
			{
				[self.searchResults addObject:product];
            }
		}
	}
}


#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSString *scope;
    
    NSInteger selectedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    if (selectedScopeButtonIndex > 0)
    {
        scope = [[APLProduct deviceTypeNames] objectAtIndex:(selectedScopeButtonIndex - 1)];
    }
    
    [self updateFilteredContentForProductName:searchString type:scope];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSString *searchString = [self.searchDisplayController.searchBar text];
    NSString *scope;
    
    if (searchOption > 0)
    {
        scope = [[APLProduct deviceTypeNames] objectAtIndex:(searchOption - 1)];
    }
    
    [self updateFilteredContentForProductName:searchString type:scope];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


//#pragma mark - UITableView data source and delegate methods
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//	/*
//	 If the requesting table view is the search display controller's table view, return the count of
//     the filtered list, otherwise return the count of the main list.
//	 */
//	return 5;
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	static NSString *kCellID = @"CellIdentifier";
//    
//    // Dequeue a cell from self's table view.
//	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
//    
//	/*
//	 If the requesting table view is the search display controller's table view, configure the cell using the search results array, otherwise use the product array.
//	 */
//    
//	if (tableView == self.searchDisplayController.searchResultsTableView)
//	{
//        
//    }
//    
//	return cell;
//}


@end
