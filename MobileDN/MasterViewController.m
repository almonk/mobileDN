//
//  MasterViewController.m
//  MobileDN
//
//  Created by Alasdair Monk on 29/12/2013.
//  Copyright (c) 2013 Alasdair Monk. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import <AFNetworking.h>
#import "PBWebViewController.h"
#import "PBSafariActivity.h"
#import "ProgressHUD.h"
#import "AppHelpers.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import <CRToast.h>
#import <SVProgressHUD.h>


@interface MasterViewController () <MCSwipeTableViewCellDelegate> {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stories = [[NSMutableArray alloc] init];
    self.pageNumber = [[NSNumber alloc] initWithInt:1];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadFrontPage:) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];
    [self loadFrontPage:nil];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [self loadNextPage:nil];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - DN specific

-(IBAction)loadFrontPage:(id)sender {
    AppHelpers *helper = [[AppHelpers alloc] init];
    
    NSString *queryUrl = @"";
    
    if ([self.navigationItem.title isEqualToString:@"Top stories"]) {
        queryUrl = @"https://news.layervault.com/stories?format=json";
    } else {
        queryUrl = @"https://news.layervault.com/new?format=json";
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:queryUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        self.stories = responseObject[@"stories"];
        [self.tableView reloadData];
        [(UIRefreshControl *)sender endRefreshing];
        [self.refreshControl endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ProgressHUD showError:@"Can't connect to DN"];
        NSLog(@"Error: %@", error);
        [(UIRefreshControl *)sender endRefreshing];
        [self.refreshControl endRefreshing];
    }];
}

-(IBAction)loadNextPage:(id)sender {
    AppHelpers *helper = [[AppHelpers alloc] init];
    
    NSString *queryUrl = @"";
    NSNumber *nextPageNumber = self.pageNumber;
    int value = [nextPageNumber intValue];
    nextPageNumber = [NSNumber numberWithInt:value + 1];
    self.pageNumber = [[NSNumber alloc] initWithInt:value + 1];
    
    if ([self.navigationItem.title isEqualToString:@"Top stories"]) {
        queryUrl = [NSString stringWithFormat:@"https://news.layervault.com/p/%@?format=json", nextPageNumber];
    } else {
        queryUrl = [NSString stringWithFormat:@"https://news.layervault.com/new/%@?format=json", nextPageNumber];
    }
    
    NSLog(@"Querying %@", queryUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[helper getAuthToken] forHTTPHeaderField:@"Authorization"];
    [manager GET:queryUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.stories = [[NSMutableArray alloc] initWithArray:self.stories];
        [self.stories addObjectsFromArray:responseObject[@"stories"]];
        [self.tableView reloadData];
        [self.tableView.infiniteScrollingView stopAnimating];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ProgressHUD showError:@"Can't connect to DN"];
        NSLog(@"Error: %@", error);
        [self.tableView.infiniteScrollingView stopAnimating];
    }];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.stories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    AppHelpers *helper = [[AppHelpers alloc] init];
    
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        // iOS 7 separator
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsZero;
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    NSDictionary *tempDictionary= [self.stories objectAtIndex:indexPath.row];
    
    UILabel *storyName;
    storyName = (UILabel *)[cell viewWithTag:1];
    storyName.text = [tempDictionary valueForKey:@"title"];
    
    NSString *metaDataText = [NSString stringWithFormat:@"%@ points from %@", [tempDictionary valueForKey:@"vote_count"], [tempDictionary valueForKey:@"submitter_display_name"]];
    
    UILabel *metaData;
    metaData = (UILabel *)[cell viewWithTag:2];
    metaData.text = metaDataText;
    
    NSString* urlString = [tempDictionary valueForKey:@"url"];
    NSURL* url = [NSURL URLWithString:urlString];
    NSString* domain = [url host];
    
    UILabel *domainUrl;
    domainUrl = (UILabel *)[cell viewWithTag:5];
    domainUrl.text = domain;
    
    UIImage *image = [UIImage imageNamed:@"comments.png"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    button.frame = frame;
    [button setTitle: [[tempDictionary valueForKey:@"num_comments"] stringValue] forState:UIControlStateNormal];
    [button setTitleColor: [UIColor colorWithRed:0.651 green:0.675 blue:0.714 alpha:1.0] forState:UIControlStateNormal];
    //button.contentEdgeInsets = UIEdgeInsetsMake(0,0,0,0); Do any padding
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button.titleLabel setFont: [UIFont fontWithName:@"Avenir" size:13.0f]];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [button addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    cell.accessoryView = button;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // Swipey bits
    UIView *checkView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"upvote.png"]];
    UIColor *greenColor = [UIColor colorWithRed:0.102 green:0.659 blue:0.373 alpha:1.0];
    
    [cell setDelegate:self];
    [cell setDefaultColor:[UIColor colorWithRed:0.925 green:0.933 blue:0.945 alpha:1.0]];
    [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Upvote: %@", [tempDictionary valueForKey:@"id"]);
        
        NSString *upvoteUrl = [NSString stringWithFormat:@"https://api-news.layervault.com/api/v1/stories/%@/upvote", [tempDictionary valueForKey:@"id"]];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager.requestSerializer setValue:[helper getAuthToken] forHTTPHeaderField:@"Authorization"];
        [manager POST:upvoteUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"Upvoted"];
            
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber *myNumber = [tempDictionary valueForKey:@"vote_count"];
            int value = [myNumber intValue];
            myNumber = [NSNumber numberWithInt:value + 1];
            
            NSString *metaDataText = [NSString stringWithFormat:@"%@ points from %@", [myNumber stringValue], [tempDictionary valueForKey:@"submitter_display_name"]];
            
            UILabel *metaData;
            metaData = (UILabel *)[cell viewWithTag:2];
            metaData.text = metaDataText;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Couldn't upvote"];
            NSLog(@"Error: %@", error);
        }];
            
    }];
    
    return cell;
}



#pragma mark - MCSwipeTableViewCellDelegate


// When the user starts swiping the cell this method is called
- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell {
    // NSLog(@"Did start swiping the cell!");
}

// When the user ends swiping the cell this method is called
- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell {
    // NSLog(@"Did end swiping the cell!");
}

// When the user is dragging, this method is called and return the dragged percentage from the border
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didSwipeWithPercentage:(CGFloat)percentage {
    // NSLog(@"Did swipe with percentage : %f", percentage);
}

- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event
{
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil )
        return;
    
    [self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *story = [self.stories objectAtIndex:indexPath.row];
    
    self.webViewController = [[PBWebViewController alloc] init];
    self.webViewController.view.backgroundColor = [UIColor whiteColor];
    self.webViewController.URL = [NSURL URLWithString:[story objectForKey:@"url"]];
    
    PBSafariActivity *activity = [[PBSafariActivity alloc] init];
    self.webViewController.applicationActivities = @[activity];
    
    self.webViewController.hidesBottomBarWhenPushed = YES;
    
    // Push it
    [self.navigationController pushViewController:self.webViewController animated:YES];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Test");
    NSDictionary *story = [self.stories objectAtIndex:indexPath.row];
    NSMutableArray *comments = [story objectForKey:@"comments"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    DetailViewController *detailViewController = (DetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DetailView"];
    detailViewController.comments = comments;
    detailViewController.storyId = [story valueForKey:@"id"];
    detailViewController.hidesBottomBarWhenPushed = YES;
    detailViewController.title = [story valueForKey:@"title"];
    [self.navigationController pushViewController:detailViewController animated:YES];
}


@end
