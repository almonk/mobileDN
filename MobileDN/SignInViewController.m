//
//  SignInViewController.m
//  MobileDN
//
//  Created by Alasdair Monk on 17/02/2014.
//  Copyright (c) 2014 Alasdair Monk. All rights reserved.
//

#import "SignInViewController.h"

#import <SVProgressHUD.h>
#import <AFNetworking.h>

@interface SignInViewController ()
@end

@implementation SignInViewController

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
    [username becomeFirstResponder];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(IBAction)doSignIn:(id)sender
{
    AppHelpers *helper = [[AppHelpers alloc] init];
    
    [SVProgressHUD showWithStatus:@"Signing in" maskType:SVProgressHUDMaskTypeBlack];
    
    NSString *URLString = @"https://api-news.layervault.com/oauth/token";
    NSDictionary *parameters = @{@"grant_type": @"password", @"username" : [username text], @"password" : [password text], @"client_id" : @"18d55d3d8e6b6097b9403e8e59eaaf0fa8b89ab04f13bc50c4c1c12f19db820b", @"client_secret" : @"6b606c71e17addff1f16569a53e817fae745b943bcb693c2112dfa09dc58e618"};
    
    [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:URLString parameters:parameters];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSLog(@"TOKEN: %@", responseObject[@"access_token"]);
        [helper setAuthToken: responseObject[@"access_token"]];
        [SVProgressHUD showSuccessWithStatus:@"Success"];
        
        UIStoryboard *mainBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        UIViewController *vc = [mainBoard instantiateInitialViewController];
        
        [self presentViewController:vc animated:YES completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [SVProgressHUD showErrorWithStatus:@"Couldn't sign in"];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
