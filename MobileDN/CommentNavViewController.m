//
//  CommentNavViewController.m
//  MobileDN
//
//  Created by Alasdair Monk on 18/02/2014.
//  Copyright (c) 2014 Alasdair Monk. All rights reserved.
//

#import "CommentNavViewController.h"
#import "CommentViewController.h"

@interface CommentNavViewController ()

@end

@implementation CommentNavViewController

@synthesize storyId;
@synthesize commentId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@", self.storyId);
    NSLog(@"%@", self.commentId);
    [self setValue:self.storyId forKey:@"storyId"];
    [self setValue:self.commentId forKey:@"commentId"];
	// Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
