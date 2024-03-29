//
//  AppDelegate.m
//  MobileDN
//
//  Created by Alasdair Monk on 29/12/2013.
//  Copyright (c) 2013 Alasdair Monk. All rights reserved.
//

#import "AppDelegate.h"
#import "OSKADNLoginManager.h"
#import <OSKActivitiesManager.h>
#import <OSKActivity.h>
#import "PocketAPI.h"
#import <Parse/Parse.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [Parse setApplicationId:@"O0L8AoeAjo2PDVy9iJ6Q3ZhuU1rVNibnwzfQJqlD"
                  clientKey:@"bs8swqBpZrbM2tRxZrMZys59JqWxR8fVWUU2VkxN"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFUser enableAutomaticUser];
    [[PFUser currentUser] incrementKey:@"RunCount"];
    [[PFUser currentUser] saveInBackground];
    
    // End parse config
    
    [[PocketAPI sharedAPI] setConsumerKey:@"22401-ee70c5d7ec1f0329c936961a"];

    [[UINavigationBar appearance] setTitleTextAttributes: @{
        NSFontAttributeName: [UIFont fontWithName:@"Avenir" size:18.0f],
        NSForegroundColorAttributeName: [UIColor whiteColor]
    }];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
        [UIFont fontWithName:@"Avenir" size:18.0f], NSFontAttributeName,
        nil] forState:UIControlStateNormal];
    
    AppHelpers *helper = [[AppHelpers alloc] init];
    if ([helper getAuthToken] == NULL) {
        
    } else{
        // Has auth token
        NSLog(@"Has auth token");
    }

    return YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
			
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL success = NO;
    if ([[PocketAPI sharedAPI] handleOpenURL:url]){
        success = YES;
    }
    else {
        // if you handle your own custom url-schemes, do it here
        // success = whatever;
    }
    return success;
}


@end
