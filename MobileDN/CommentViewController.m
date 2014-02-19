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
    self.storyId = [self.navigationController valueForKey:@"storyId"];
    self.commentId = [self.navigationController valueForKey:@"commentId"];
    NSLog(@"%@", self.storyId);
    NSLog(@"%@", self.commentId);
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)dismissSelf:(id)sender
{
    [MTBlockAlertView showWithTitle:@"Discard comment"
                            message:@"You'll lose your comment"
                  cancelButtonTitle:@"Cancel"
                   otherButtonTitle:@"Discard"
                     alertViewStyle:UIAlertViewStyleDefault
                    completionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        NSLog(@"Sign out Button: %ld", (long)buttonIndex);
                        if (buttonIndex == 1) {
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }
                    }];

}

-(IBAction)sendComment:(id)sender
{
    AppHelpers *helper = [[AppHelpers alloc] init];
    
    [SVProgressHUD showWithStatus:@"Sending..." maskType:SVProgressHUDMaskTypeBlack];
    
    if (self.commentId) {
        // This is a reply
        NSString *commentUrl = [NSString stringWithFormat:@"https://api-news.layervault.com/api/v1/comments/%@/reply", self.commentId];
        
        NSDictionary *parameters = @{@"comment[body]": [commentBody text]};
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager.requestSerializer setValue:[helper getAuthToken] forHTTPHeaderField:@"Authorization"];
        [manager POST:commentUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"Comment added"];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Couldn't comment"];
        }];
    } else {
        // This is a context-less comment
        NSString *commentUrl = [NSString stringWithFormat:@"https://api-news.layervault.com/api/v1/stories/%@/reply", self.storyId];
        
        NSDictionary *parameters = @{@"comment[body]": [commentBody text]};
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager.requestSerializer setValue:[helper getAuthToken] forHTTPHeaderField:@"Authorization"];
        [manager POST:commentUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"Comment added"];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Couldn't comment"];
            NSLog(@"%@", error);
        }];
    }
}

@end
