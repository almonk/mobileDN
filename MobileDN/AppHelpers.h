//
//  AppHelpers.h
//  webTableView
//
//  Created by Alasdair Monk on 29/10/2013.
//  Copyright (c) 2013 Joe Hoffman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppHelpers : UIViewController

-(NSString*)getAuthToken;
-(void)removeAuthToken;
-(void)setAuthToken:(NSString*)token;

@end
