//
//  AppHelpers.m
//  webTableView
//
//  Created by Alasdair Monk on 29/10/2013.
//  Copyright (c) 2013 Joe Hoffman. All rights reserved.
//

#import "AppHelpers.h"

@interface AppHelpers ()

@end

@implementation AppHelpers

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)setAuthToken:(NSString*)token {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bearerAndToken = [NSString stringWithFormat:@"%@ %@", @"Bearer", token];
    [defaults setObject:bearerAndToken forKey:@"authToken"];
}

-(NSString*)getAuthToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"authToken"];
    NSLog(@"TOKEN: %@", token);
    return token;
}

-(void)removeAuthToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"authToken"];
}

@end
