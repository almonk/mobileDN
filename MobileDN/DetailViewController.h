//
//  DetailViewController.h
//  MobileDN
//
//  Created by Alasdair Monk on 29/12/2013.
//  Copyright (c) 2013 Alasdair Monk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBWebViewController.h"
#import <AMAttributedHighlightLabel.h>

@interface DetailViewController : UITableViewController <UITableViewDataSource> {
    IBOutlet UIView *emptyView;
}

@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) NSString *storyId;
@property (strong, nonatomic) NSMutableArray *flatComments;
@property (strong, nonatomic) NSMutableArray *flatUsers;
@property (strong, nonatomic) NSMutableArray *flatTime;
@property (strong, nonatomic) NSMutableArray *commentDepth;
@property (weak, nonatomic) NSMutableArray *heights;
@property (strong, nonatomic) PBWebViewController *webViewController;

@end
