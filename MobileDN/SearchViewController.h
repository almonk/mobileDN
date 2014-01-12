//
//  SearchViewController.h
//  MobileDN
//
//  Created by Alasdair Monk on 31/12/2013.
//  Copyright (c) 2013 Alasdair Monk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBWebViewController.h"
#import "DetailViewController.h"

@interface SearchViewController : UITableViewController {
    IBOutlet UISearchBar *searchBar;
}

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (strong, nonatomic) PBWebViewController *webViewController;

@property (strong, nonatomic) NSMutableArray *stories;

@end
