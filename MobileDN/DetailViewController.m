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
        [_flatComments addObject: [obj objectForKey:@"body_html"]];
        [_commentDepth addObject: [obj objectForKey:@"depth"]];
        [_flatTime addObject: [obj objectForKey:@"created_at"]];
        [_flatIds addObject: [obj objectForKey:@"id"]];
        [_flatUsers count];
        
        for (NSDictionary *dict in [obj objectForKey:@"comments"]) {
            NSLog(@"Body: %@", [dict objectForKey:@"body"]);
            [_flatUsers addObject: [dict objectForKey:@"user_display_name"]];
            [_flatComments addObject: [dict objectForKey:@"body_html"]];
            [_commentDepth addObject: [dict objectForKey:@"depth"]];
            [_flatTime addObject: [dict objectForKey:@"created_at"]];
            [_flatIds addObject: [dict objectForKey:@"id"]];
            [_flatUsers count];
            
            for (NSDictionary *dict2 in [dict objectForKey:@"comments"]) {
                NSLog(@"Body: %@", [dict2 objectForKey:@"body"]);
                [_flatUsers addObject: [dict2 objectForKey:@"user_display_name"]];
                [_flatComments addObject: [dict2 objectForKey:@"body_html"]];
                [_commentDepth addObject: [dict2 objectForKey:@"depth"]];
                [_flatTime addObject: [dict2 objectForKey:@"created_at"]];
                [_flatIds addObject: [dict2 objectForKey:@"id"]];
                [_flatUsers count];
                
                for (NSDictionary *dict3 in [dict2 objectForKey:@"comments"]) {
                    NSLog(@"Body: %@", [dict3 objectForKey:@"body"]);
                    [_flatUsers addObject: [dict3 objectForKey:@"user_display_name"]];
                    [_flatComments addObject: [dict3 objectForKey:@"body_html"]];
                    [_commentDepth addObject: [dict3 objectForKey:@"depth"]];
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
    NSLog(@"Indentation level: %lu", (unsigned long)indentLevel);
    return indentLevel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    AppHelpers *helper = [[AppHelpers alloc] init];
    
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    NSString *indentLevelRaw = [_commentDepth objectAtIndex:indexPath.row];
    NSUInteger indentLevel = [indentLevelRaw integerValue];
    float indentPoints = indentLevel * 25;
    
    UITextView *commentBody;
    commentBody = (UITextView *)[cell viewWithTag:1];
    commentBody.userInteractionEnabled = YES;
    commentBody.scrollEnabled = NO;
    commentBody.bounces = NO;
    commentBody.delegate = self;
    
    NSString *htmlAndStyle = [NSString stringWithFormat:@"<html><head><style>img { max-width:160px; }</style></style><body>%@</body></html>", [self.flatComments objectAtIndex:indexPath.row]];
    
    NSData *htmlData = [htmlAndStyle dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create the HTML string
    NSDictionary *importParams = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSError *error = nil;
    NSAttributedString *htmlString = [[NSAttributedString alloc] initWithData:htmlData options:importParams documentAttributes:NULL error:&error];
    
    // Instantiate UITextView object
    commentBody.attributedText = htmlString;
    
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
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    
    UITextView *commentBody;
    commentBody = (UITextView *)[cell viewWithTag:1];
    commentBody.userInteractionEnabled = YES;
    
    NSString *htmlAndStyle = [NSString stringWithFormat:@"<html><head><style>img { max-width:160px; }</style></style><body>%@</body></html>", [self.flatComments objectAtIndex:indexPath.row]];
    
    NSData *htmlData = [htmlAndStyle dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create the HTML string
    NSDictionary *importParams = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSError *error = nil;
    NSAttributedString *htmlString = [[NSAttributedString alloc] initWithData:htmlData options:importParams documentAttributes:NULL error:&error];
    
    // Instantiate UITextView object
    commentBody.attributedText = htmlString;
    
    commentBody.font = [UIFont fontWithName:@"Avenir" size:16.0f];
    
    CGFloat width = 291 - indentPoints;

    CGSize size = [commentBody sizeThatFits:CGSizeMake(width, FLT_MAX)];
    
    [commentBody sizeToFit];

    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    
    
    //CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return size.height + 2 * 20;
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
    
    self.webViewController.hidesBottomBarWhenPushed = YES;
    
    // Push it
    [self.navigationController pushViewController:self.webViewController animated:YES];
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

-(IBAction)composeNewComment:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    CommentNavViewController *commentNavViewController = (CommentNavViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CommentView"];
    commentNavViewController.parent = self;
    commentNavViewController.storyId = self.storyId;
    [self presentViewController:commentNavViewController animated:YES completion:^{
        
    }];
}

-(void)addLatestCommentToBottom:(NSString*)comment : (NSString*)username : (NSString*)commentId
{
    NSInteger sectionsAmount = [self.tableView numberOfSections];
    NSInteger rowsAmount = [self.tableView numberOfRowsInSection:sectionsAmount-1];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(rowsAmount - 1) inSection:(sectionsAmount - 1)];

    if (rowsAmount == 0) {
        // No rows so we have to create indexes
        [self.flatComments addObject:comment];
        [self.flatUsers addObject:username];
        [self.commentDepth addObject:@"0"];
        [self.flatTime addObject:@"Test"];
        [self.flatIds addObject:commentId];
        [self.tableView reloadData];
    } else {
        // There's data already so we just add to the end of the array
        
        [self.flatComments insertObject:comment atIndex:rowsAmount];
        [self.flatUsers insertObject:username atIndex:rowsAmount];
        [self.commentDepth insertObject:@"0" atIndex:rowsAmount];
        [self.flatTime insertObject:@"Test" atIndex:rowsAmount];
        [self.flatIds insertObject:commentId atIndex:rowsAmount];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [self.tableView endUpdates];
        
        NSTimeInterval delayInSeconds = 0.2;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        });
    }
}



-(void)addReplyComment: (NSString*)comment : (NSString*)username : (NSIndexPath*)replyRow : (NSString*)depth : (NSString*)commentId
{
    NSInteger newLast = [replyRow indexAtPosition:replyRow.length-1]+1;
    replyRow = [[replyRow indexPathByRemovingLastIndex] indexPathByAddingIndex:newLast];
    
    [self.flatComments insertObject:comment atIndex:replyRow.row];
    [self.flatUsers insertObject:username atIndex:replyRow.row];
    [self.commentDepth insertObject:depth atIndex:replyRow.row];
    [self.flatTime insertObject:@"Test" atIndex:replyRow.row];
    [self.flatIds insertObject:commentId atIndex:replyRow.row];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:replyRow] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    
    NSTimeInterval delayInSeconds = 0.2;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView scrollToRowAtIndexPath:replyRow atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    });

    
}

-(void)updateComments
{
    NSLog(@"UPDATE COMMENTS");

    AppHelpers *helper = [[AppHelpers alloc] init];
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeBlack];
    
    NSString *queryUrl = [NSString stringWithFormat:@"https://api-news.layervault.com/api/v1/stories/%@", self.storyId];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[helper getAuthToken] forHTTPHeaderField:@"Authorization"];
    [manager GET:queryUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *story = responseObject[@"story"];
        NSMutableArray *comments = [story objectForKey:@"comments"];
        NSLog(@"STORY %@", responseObject[@"story"]);
        NSLog(@"COMMENTS %@", comments);
        self.comments = comments;
        [self loadStory:nil];
        [self.tableView reloadData];
        NSTimeInterval delayInSeconds = 0.5;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [SVProgressHUD dismiss];

            [self.refreshControl endRefreshing];
        });

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
        [SVProgressHUD showErrorWithStatus:@"Couldn't get comments"];
        NSLog(@"Error: %@", error);
    }];
}

@end
