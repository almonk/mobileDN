//
//  SearchViewController.m
//  MobileDN
//
//  Created by Alasdair Monk on 31/12/2013.
//  Copyright (c) 2013 Alasdair Monk. All rights reserved.
//

#import "SearchViewController.h"
#import "DetailViewController.h"
#import <AFNetworking.h>
#import "PBWebViewController.h"
#import "PBSafariActivity.h"
#import "ProgressHUD.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "AppHelpers.h"
#import <SVProgressHUD.h>

@interface SearchViewController ()

@end

@implementation SearchViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    searchBar.delegate = self;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) hideKeyboard {
    [searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) searchBarSearchButtonClicked:(UISearchBar*) searchContact
{
    [self loadFrontPage:nil];
}

-(IBAction)loadFrontPage:(id)sender {
    [self.refreshControl beginRefreshing];
    
    [SVProgressHUD showWithStatus:@"Searching..."];
    
    AppHelpers *helper = [[AppHelpers alloc] init];
    
    NSDictionary *parameters = @{@"query" : [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[helper getAuthToken] forHTTPHeaderField:@"Authorization"];
    [manager GET:@"https://api-news.layervault.com/api/v1/stories/search" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        self.stories = responseObject;
        [self.tableView reloadData];
        [(UIRefreshControl *)sender endRefreshing];
        [self.refreshControl endRefreshing];
        [SVProgressHUD dismiss];
        [self.view endEditing:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ProgressHUD showError:@"Can't connect to DN"];
        [self.refreshControl endRefreshing];
        NSLog(@"Error: %@", error);
    }];
}


#pragma mark - Table view data source

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

    UILabel *metaData;
    metaData = (UILabel *)[cell viewWithTag:2];
    metaData.text = [tempDictionary valueForKey:@"url"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
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

@end
