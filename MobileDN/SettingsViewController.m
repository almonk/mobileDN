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
#import <SVProgressHUD.h>


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
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    AppHelpers* helper = [[AppHelpers alloc] init];
    
    if ([helper getAuthToken] == NULL) {
        signInButton.enabled = true;
        signInButton.title = @"Sign in";
        [signOutCell setHidden:YES];
    } else {
        signInButton.enabled = false;
        signInButton.title = nil;
        [signOutCell setHidden:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                            [SVProgressHUD showSuccessWithStatus:@"Signed out"];
                            signInButton.enabled = true;
                            signInButton.title = @"Sign in";
                            [signOutCell setHidden:YES];
                        }
                    }];
}

-(IBAction)signIn:(id)sender
{
    NSLog(@"No auth token");
    UIStoryboard *authBoard = [UIStoryboard storyboardWithName:@"UserFlow" bundle:nil];
    UIViewController *vc = [authBoard instantiateInitialViewController];
    [self.navigationController presentViewController:vc animated:YES completion:nil];
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
