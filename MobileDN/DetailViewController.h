//
//  DetailViewController.h
//  MobileDN
//
//  Created by Alasdair Monk on 29/12/2013.
//  Copyright (c) 2013 Alasdair Monk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel.h>
#import "PBWebViewController.h"

@interface DetailViewController : UITableViewController <TTTAttributedLabelDelegate,UITableViewDataSource> {
}

@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) NSMutableArray *flatComments;
@property (weak, nonatomic) NSMutableArray *heights;
@property (strong, nonatomic) PBWebViewController *webViewController;

@end
