//
//  DetailViewController.m
//  MobileDN
//
//  Created by Alasdair Monk on 29/12/2013.
//  Copyright (c) 2013 Alasdair Monk. All rights reserved.
//

#import "DetailViewController.h"
#import <AFNetworking.h>
#import "MMMarkdown.h"
#import "PBWebViewController.h"
#import "PBSafariActivity.h"
#import <SORelativeDateTransformer.h>
#import "UITableView+NXEmptyView.h"
#import <AMAttributedHighlightLabel.h>
#import <MCSwipeTableViewCell.h>
#import "AppHelpers.h"
#import <SVProgressHUD.h>
#import "CommentNavViewController.h"
#import "CommentViewController.h"


@interface DetailViewController () <MCSwipeTableViewCellDelegate>
@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.comments = [[NSMutableArray alloc] init];
    self.flatComments = [[NSMutableArray alloc] init];
    self.flatUsers = [[NSMutableArray alloc] init];
    self.commentDepth = [[NSMutableArray alloc] init];
    self.flatTime = [[NSMutableArray alloc] init];
    self.flatIds = [[NSMutableArray alloc] init];
    self.tableView.nxEV_hideSeparatorLinesWheyShowingEmptyView = YES;
    self.tableView.nxEV_emptyView = emptyView;
    NSLog(@"Load story %@", self.storyId);
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updateComments) forControlEvents:UIControlEventValueChanged];
    [self updateComments];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)loadStory:(id)sender {
    NSArray *comments = self.comments;
    
    self.flatComments = [[NSMutableArray alloc] init];
    self.flatUsers = [[NSMutableArray alloc] init];
    self.commentDepth = [[NSMutableArray alloc] init];
    self.flatTime = [[NSMutableArray alloc] init];
    self.flatIds = [[NSMutableArray alloc] init];
    
    [comments enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
        NSLog(@"Body: %@", [obj objectForKey:@"body"]);
        [_flatUsers addObject: [obj objectForKey:@"user_display_name"]];
        [_flatComments addObject: [obj objectForKey:@"body"]];
        [_commentDepth addObject: [obj objectForKey:@"depth"]];
        [_flatTime addObject: [obj objectForKey:@"created_at"]];
        [_flatIds addObject: [obj objectForKey:@"id"]];
        [_flatUsers count];
        
        for (NSDictionary *dict in [obj objectForKey:@"comments"]) {
            NSLog(@"Body: %@", [dict objectForKey:@"body"]);
            [_flatUsers addObject: [dict objectForKey:@"user_display_name"]];
            [_flatComments addObject: [dict objectForKey:@"body"]];
            [_commentDepth addObject: @"0"];
            [_flatTime addObject: [dict objectForKey:@"created_at"]];
            [_flatIds addObject: [dict objectForKey:@"id"]];
            [_flatUsers count];
            
            for (NSDictionary *dict2 in [dict objectForKey:@"comments"]) {
                NSLog(@"Body: %@", [dict2 objectForKey:@"body"]);
                [_flatUsers addObject: [dict2 objectForKey:@"user_display_name"]];
                [_flatComments addObject: [dict2 objectForKey:@"body"]];
                [_commentDepth addObject: @"0"];
                [_flatTime addObject: [dict2 objectForKey:@"created_at"]];
                [_flatIds addObject: [dict2 objectForKey:@"id"]];
                [_flatUsers count];
                
                for (NSDictionary *dict3 in [dict2 objectForKey:@"comments"]) {
                    NSLog(@"Body: %@", [dict3 objectForKey:@"body"]);
                    [_flatUsers addObject: [dict3 objectForKey:@"user_display_name"]];
                    [_flatComments addObject: [dict3 objectForKey:@"body"]];
                    [_commentDepth addObject: @"0"];
                    [_flatTime addObject: [dict3 objectForKey:@"created_at"]];
                    [_flatIds addObject: [dict3 objectForKey:@"id"]];
                    [_flatUsers count];
                }
            }
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.flatComments count];
}

-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentLevelRaw = [_commentDepth objectAtIndex:indexPath.row];
    NSUInteger indentLevel = [indentLevelRaw integerValue];
    return indentLevel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    UITextView *commentBody;
    commentBody = (UITextView *)[cell viewWithTag:1];
    commentBody.userInteractionEnabled = NO;
    commentBody.scrollEnabled = NO;
    commentBody.bounces = NO;
    commentBody.delegate = self;

    
    commentBody.text = [self.flatComments objectAtIndex:indexPath.row];
    commentBody.font = [UIFont fontWithName:@"Avenir" size:16.0f];

    //commentBody.preferredMaxLayoutWidth = 280 - indentPoints; // <<<<< ALL THE MAGIC

    UILabel *usernameMeta;
    usernameMeta = (UILabel *)[cell viewWithTag:2];
    usernameMeta.text = [self.flatUsers objectAtIndex:indexPath.row];
    NSLog(@"%@",[self.flatUsers objectAtIndex:indexPath.row] );
    
    cell.indentationWidth = 25;
    
    UILabel *date;
    date = (UILabel *)[cell viewWithTag:3];
    date.text = [self convertDateToRelativeDate: [self.flatTime objectAtIndex:indexPath.row]];
    
    // Swipey bits
    UIView *checkView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"upvote.png"]];
    UIColor *greenColor = [UIColor colorWithRed:0.102 green:0.659 blue:0.373 alpha:1.0];
    
    UIView *replyView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"reply.png"]];
    UIColor *yellowColor = [UIColor colorWithRed:254.0 / 255.0 green:217.0 / 255.0 blue:56.0 / 255.0 alpha:1.0];
    
    [cell setDelegate:self];
    [cell setDefaultColor:[UIColor colorWithRed:0.765 green:0.788 blue:0.824 alpha:1.0]];
    [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        
        AppHelpers *helper = [[AppHelpers alloc] init];
        if ([helper getAuthToken] == NULL) {
            [self showLogin];
            return;
        }
        
        NSLog(@"Upvote %@", [self.flatIds objectAtIndex:indexPath.row]);
        [SVProgressHUD showWithStatus:@"Upvoting..."];
        
        NSString *upvoteUrl = [NSString stringWithFormat:@"https://api-news.layervault.com/api/v1/comments/%@/upvote", [self.flatIds objectAtIndex:indexPath.row]];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager.requestSerializer setValue:[helper getAuthToken] forHTTPHeaderField:@"Authorization"];
        [manager POST:upvoteUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"Upvoted"];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Couldn't upvote"];
            NSLog(@"Error: %@", error);
        }];

    }];
    
    [cell setSwipeGestureWithView:replyView color:yellowColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        AppHelpers *helper = [[AppHelpers alloc] init];
        if ([helper getAuthToken] == NULL) {
            [self showLogin];
            return;
        }
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        CommentNavViewController *commentNavViewController = (CommentNavViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CommentView"];
        commentNavViewController.parent = self;
        commentNavViewController.commentId = [self.flatIds objectAtIndex:indexPath.row];
        commentNavViewController.replyRow = [self.tableView indexPathForCell: cell];
        [self presentViewController:commentNavViewController animated:YES completion:^{
            
        }];
    }];

    return cell;
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSString *indentLevelRaw = [_commentDepth objectAtIndex:indexPath.row];
    NSUInteger indentLevel = [indentLevelRaw integerValue];
    float indentPoints = indentLevel * 25;

    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    
    UITextView *commentBody;
    commentBody = (UITextView *)[cell viewWithTag:1];
    commentBody.userInteractionEnabled = YES;
    commentBody.text = [self.flatComments objectAtIndex:indexPath.row];
    
    commentBody.font = [UIFont fontWithName:@"Avenir" size:16.0f];
    
    CGFloat width = 291 - indentPoints;

    CGSize size = [commentBody sizeThatFits:CGSizeMake(width, FLT_MAX)];
    
    [commentBody sizeToFit];

    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    
//    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return size.height + 2 * 17;
}


-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 77;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    NSLog(@"Tap link");
    
    self.webViewController = [[PBWebViewController alloc] init];
    self.webViewController.view.backgroundColor = [UIColor whiteColor];
    self.webViewController.URL = URL;
    
    PBSafariActivity *activity = [[PBSafariActivity alloc] init];
    self.webViewController.applicationActivities = @[activity];
    
    // Push it
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:self.webViewController] animated:YES completion:nil];
    
    return NO;
}

-(NSString*)convertDateToRelativeDate:(NSString*)date {;
    NSString *origDate = date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    NSDate *origDateAsDate = [formatter dateFromString: origDate];
    NSString *relativeDate = [[SORelativeDateTransformer registeredTransformer] transformedValue: origDateAsDate];
    
    return relativeDate;
}

-(void)showLogin {
    NSLog(@"No auth token");
    UIStoryboard *authBoard = [UIStoryboard storyboardWithName:@"UserFlow" bundle:nil];
    UIViewController *vc = [authBoard instantiateInitialViewController];
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}


-(IBAction)composeNewComment:(id)sender
{
    AppHelpers *helper = [[AppHelpers alloc] init];
    if ([helper getAuthToken] == NULL) {
        [self showLogin];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    CommentNavViewController *commentNavViewController = (CommentNavViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CommentView"];
    commentNavViewController.parent = self;
    commentNavViewController.storyId = self.storyId;
    [self presentViewController:commentNavViewController animated:YES completion:^{
        
    }];
}

-(void)addLatestCommentToBottom:(NSString*)comment : (NSString*)username : (NSString*)commentId
{
    NSTimeInterval delayInSeconds = 0.8;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self updateComments];
    });
}



-(void)addReplyComment: (NSString*)comment : (NSString*)username : (NSIndexPath*)replyRow : (NSString*)depth : (NSString*)commentId
{
    NSIndexPath* top = [NSIndexPath indexPathForRow:NSNotFound inSection:0];
    [self.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    NSTimeInterval delayInSeconds = 0.8;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self updateComments];
    });
    
}

-(void)updateComments
{
    AppHelpers *helper = [[AppHelpers alloc] init];
    
    [SVProgressHUD show];
    
    NSString *queryUrl = [NSString stringWithFormat:@"https://api-news.layervault.com/api/v1/stories/%@", self.storyId];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    if ([helper getAuthToken] == NULL) {
    } else {
        [manager.requestSerializer setValue:[helper getAuthToken] forHTTPHeaderField:@"Authorization"];
    }
    
    [manager.requestSerializer setValue:[helper getAuthToken] forHTTPHeaderField:@"Authorization"];
    [manager GET:queryUrl parameters:@{ @"client_id": [helper clientId] } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *story = responseObject[@"story"];
        NSMutableArray *comments = [story objectForKey:@"comments"];
        NSLog(@"STORY %@", responseObject[@"story"]);
        NSLog(@"COMMENTS %@", comments);
        self.comments = comments;
        [self loadStory:nil];
        [self.tableView reloadData];
        
        [SVProgressHUD dismiss];
        [self.refreshControl endRefreshing];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
        [SVProgressHUD showErrorWithStatus:@"Couldn't get comments"];
        NSLog(@"Error: %@", error);
    }];
}

@end
