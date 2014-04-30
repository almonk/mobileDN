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

-(NSString*)clientId {
    return @"18d55d3d8e6b6097b9403e8e59eaaf0fa8b89ab04f13bc50c4c1c12f19db820b";
}

-(void)removeAuthToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"authToken"];
}

@end
