//
//  CommentViewController.m
//  MobileDN
//
//  Created by Alasdair Monk on 18/02/2014.
//  Copyright (c) 2014 Alasdair Monk. All rights reserved.
//

#import "CommentViewController.h"
#import <SVProgressHUD.h>
#import <AFNetworking.h>
#import "AppHelpers.h"
#import <MTBlockAlertView.h>

@interface CommentViewController ()

@end

@implementation CommentViewController

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
    [commentBody becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)dismissSelf:(id)sender
{
    if ([[commentBody text] isEqualToString:@""]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [MTBlockAlertView showWithTitle:nil
                                message:@"Are you sure you want to discard your comment?"
                      cancelButtonTitle:@"Cancel"
                       otherButtonTitle:@"Discard"
                         alertViewStyle:UIAlertViewStyleDefault
                        completionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            
                            if (buttonIndex == 1) {
                                [self dismissViewControllerAnimated:YES completion:nil];
                            }
                        }];
    }
}

-(IBAction)sendComment:(id)sender
{
    if (self.commentId) {
        // This is a reply
        [self submitComment];
    }
    
    if (self.storyId) {
        // This is a reply
        [self submitComment];
    }
}

-(void)refreshParent
{
    [self.parent updateComments];
}

-(void)submitComment
{
    AppHelpers *helper = [[AppHelpers alloc] init];
    [SVProgressHUD showWithStatus:@"Sending..." maskType:SVProgressHUDMaskTypeBlack];
    NSString *commentUrl;
    
    if (self.storyId) {
        commentUrl = [NSString stringWithFormat:@"https://api-news.layervault.com/api/v1/stories/%@/reply", self.storyId];
    }
    
    if (self.commentId) {
        commentUrl = [NSString stringWithFormat:@"https://api-news.layervault.com/api/v1/comments/%@/reply", self.commentId];
    }
    
    NSDictionary *parameters = @{@"comment[body]": [commentBody text]};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[helper getAuthToken] forHTTPHeaderField:@"Authorization"];
    [manager POST:@"http://www.mocky.io/v2/530a3ca1199be5f80210b127" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            NSDictionary *comment = responseObject[@"comment"];
            
            if (self.storyId) {
                [_parent addLatestCommentToBottom:[comment objectForKey:@"body"] : [comment objectForKey:@"user_display_name"] : [comment objectForKey:@"id"]];
            }
            
            if (self.commentId) {
                [_parent addReplyComment:[comment objectForKey:@"body"] : [comment objectForKey:@"user_display_name"] : self.replyRow : [comment objectForKey:@"depth"] : [comment objectForKey:@"id"]];
            }
            
            [SVProgressHUD showSuccessWithStatus:@"Posted"];

            [self dismissViewControllerAnimated:YES completion:nil];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Couldn't comment"];
        NSLog(@"%@", error);
    }];
}


@end
