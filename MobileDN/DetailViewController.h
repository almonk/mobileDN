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

@interface DetailViewController : UITableViewController <UITableViewDataSource, UITextViewDelegate> {
    IBOutlet UIView *emptyView;
}

-(IBAction)composeNewComment:(id)sender;
-(void)addLatestCommentToBottom:(NSString*)comment : (NSString*)username : (NSString*)commentId;
-(void)addReplyComment:(NSString*)comment : (NSString*)username : (NSIndexPath*)replyRow : (NSString*)depth : (NSString*)commentId;
-(void)updateComments;

@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) NSString *storyId;
@property (strong, nonatomic) NSMutableArray *flatComments;
@property (strong, nonatomic) NSMutableArray *flatUsers;
@property (strong, nonatomic) NSMutableArray *flatTime;
@property (strong, nonatomic) NSMutableArray *flatIds;
@property (strong, nonatomic) NSMutableArray *commentDepth;
@property (weak, nonatomic) NSMutableArray *heights;
@property (strong, nonatomic) PBWebViewController *webViewController;



@end
