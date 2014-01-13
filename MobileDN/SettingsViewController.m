//
//  SettingsViewController.m
//  MobileDN
//
//  Created by Alasdair Monk on 12/01/2014.
//  Copyright (c) 2014 Alasdair Monk. All rights reserved.
//

#import "SettingsViewController.h"
#import <OvershareKit.h>


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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
