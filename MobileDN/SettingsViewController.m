//
//  SettingsViewController.m
//  MobileDN
//
//  Created by Alasdair Monk on 12/01/2014.
//  Copyright (c) 2014 Alasdair Monk. All rights reserved.
//

#import "SettingsViewController.h"
#import <OvershareKit.h>
#import <MTBlockAlertView.h>
#import "AppHelpers.h"
#import <AFNetworking.h>
#import <CTFeedbackViewController.h>


@interface SettingsViewController ()

@end

@implementation SettingsViewController

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
    [self loadProfileInfo];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadProfileInfo
{
    AppHelpers *helper = [[AppHelpers alloc] init];
    
    NSLog(@"Loading info");
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[helper getAuthToken] forHTTPHeaderField:@"Authorization"];
    [manager GET:@"https://api-news.layervault.com/api/v1/me" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Got info");
        NSDictionary *profile = responseObject[@"me"];
        
        NSString *fullName = [NSString stringWithFormat:@"%@ %@", [profile valueForKey:@"first_name"], [profile valueForKey:@"last_name"]];
        [name setText: fullName];
        
        if ([[profile valueForKey:@"job"] length] != 0) {
            [jobTitle setText: [profile valueForKey:@"job"]];
        }
        
        NSString *ImageURL = [profile valueForKey:@"portrait_url"];
        
        if ([ImageURL length] != 0) {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageURL]];
            avatar.image = [UIImage imageWithData:imageData];
        }
        
        [spinner stopAnimating];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

-(IBAction)signOut:(id)sender
{
    [MTBlockAlertView showWithTitle:@"Sign out"
                            message:@"Are you sure you want to sign out?"
                  cancelButtonTitle:@"Cancel"
                   otherButtonTitle:@"Sign out"
                     alertViewStyle:UIAlertViewStyleDefault
                    completionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        NSLog(@"Sign out Button: %ld", (long)buttonIndex);
                        if (buttonIndex == 1) {
                            AppHelpers* helper = [[AppHelpers alloc] init];
                            [helper removeAuthToken];
                            
                            UIStoryboard *mainBoard = [UIStoryboard storyboardWithName:@"UserFlow" bundle:nil];
                            UIViewController *vc = [mainBoard instantiateInitialViewController];
                            
                            [self presentViewController:vc animated:YES completion:nil];
                        }
                    }];
}

-(IBAction)showSharingSettings:(id)sender
{
    NSString *object1 = OSKActivityType_API_AppDotNet;
    
    NSArray *excludedActivities = [NSArray arrayWithObjects: object1, nil];
    
    OSKAccountManagementViewController *manager = [[OSKAccountManagementViewController alloc] initWithIgnoredActivityClasses:excludedActivities optionalBespokeActivityClasses:nil];
    
    OSKNavigationController *navController = [[OSKNavigationController alloc] initWithRootViewController:manager];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)followMeOnTwitter:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/intent/user?screen_name=almonk"]];
}

-(IBAction)rateApp:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id790720884?at=10l6dK"]];    
}

-(IBAction)doFeedback:(id)sender
{
    CTFeedbackViewController *feedbackViewController = [CTFeedbackViewController controllerWithTopics:CTFeedbackViewController.defaultTopics localizedTopics:CTFeedbackViewController.defaultLocalizedTopics];
    feedbackViewController.toRecipients = @[@"alasdair.monk@gmail.com"];
    feedbackViewController.useHTML = NO;
    [self.navigationController pushViewController:feedbackViewController animated:YES];
}

@end
