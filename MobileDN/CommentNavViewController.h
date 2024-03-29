//
//  CommentNavViewController.h
//  MobileDN
//
//  Created by Alasdair Monk on 18/02/2014.
//  Copyright (c) 2014 Alasdair Monk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@interface CommentNavViewController : UINavigationController

@property (nonatomic,retain) NSString *storyId;
@property (strong, nonatomic) NSString *commentId;
@property (strong, nonatomic) NSIndexPath *replyRow;
@property (nonatomic, retain) DetailViewController* parent;

@end
