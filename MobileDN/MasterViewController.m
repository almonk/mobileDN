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
#import <PBSafariActivity.h>
#import "ProgressHUD.h"
#import "UIScrollView+SVInfiniteScrolling.h"

@interface MasterViewController () {
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
    [manager GET:queryUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
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
    
    return cell;
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
    detailViewController.hidesBottomBarWhenPushed = YES;
    detailViewController.title = [story valueForKey:@"title"];
    [self.navigationController pushViewController:detailViewController animated:YES];
}


@end
