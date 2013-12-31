//
//  MasterViewController.h
//  MobileDN
//
//  Created by Alasdair Monk on 29/12/2013.
//  Copyright (c) 2013 Alasdair Monk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PBWebViewController.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController <UITableViewDataSource>

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (strong, nonatomic) NSMutableArray *stories;

@property (strong, nonatomic) NSMutableArray *readStories;

@property (strong, nonatomic) PBWebViewController *webViewController;

@end
