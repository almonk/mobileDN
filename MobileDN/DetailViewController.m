//
//  DetailViewController.m
//  MobileDN
//
//  Created by Alasdair Monk on 29/12/2013.
//  Copyright (c) 2013 Alasdair Monk. All rights reserved.
//

#import "DetailViewController.h"
#import <AFNetworking.h>
#import "MMMarkdown.h"
#import "PBWebViewController.h"
#import <PBSafariActivity.h>
#import <SORelativeDateTransformer.h>
#import "UITableView+NXEmptyView.h"
#import <AMAttributedHighlightLabel.h>

@interface DetailViewController ()
@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.flatComments = [[NSMutableArray alloc] init];
    self.flatUsers = [[NSMutableArray alloc] init];
    self.commentDepth = [[NSMutableArray alloc] init];
    self.flatTime = [[NSMutableArray alloc] init];
    self.tableView.nxEV_hideSeparatorLinesWheyShowingEmptyView = YES;
    self.tableView.nxEV_emptyView = emptyView;
    [self loadStory:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)loadStory:(id)sender {
    [self processParsedObject:self.comments];
}

-(void)processParsedObject:(id)object{
    [self enumerateJSONToFindKeys:object forKeyNamed:nil];
}

- (void)enumerateJSONToFindKeys:(id)object forKeyNamed:(NSString *)keyName
{
    if ([object isKindOfClass:[NSDictionary class]])
    {
        // If it's a dictionary, enumerate it and pass in each key value to check
        [object enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
            [self enumerateJSONToFindKeys:value forKeyNamed:key];
        }];
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        // If it's an array, pass in the objects of the array to check
        [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self enumerateJSONToFindKeys:obj forKeyNamed:nil];
        }];
    }
    else
    {
        // If we got here (i.e. it's not a dictionary or array) so its a key/value that we needed
        //NSLog(@"We found key %@ with value %@", keyName, object);
        if ([keyName isEqualToString:@"user_display_name"]) {
            NSLog(@"Comment: %@", object);
            [_flatUsers addObject:object];
            NSLog(@"comments %d", [_flatUsers count]);
        }
        
        if ([keyName isEqualToString:@"body"]) {
            NSLog(@"Comment: %@", object);
            [_flatComments addObject:object];
            NSLog(@"comments %d", [_flatComments count]);
        }
        
        if ([keyName isEqualToString:@"depth"]) {
            NSLog(@"Depth: %@", object);
            [_commentDepth addObject:object];
        }
        
        if ([keyName isEqualToString:@"created_at"]) {
            [_flatTime addObject:object];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.flatComments count];
}

-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentLevelRaw = [_commentDepth objectAtIndex:indexPath.row];
    NSUInteger indentLevel = [indentLevelRaw integerValue];
    NSLog(@"Indentation level: %lu", (unsigned long)indentLevel);
    return indentLevel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString *indentLevelRaw = [_commentDepth objectAtIndex:indexPath.row];
    NSUInteger indentLevel = [indentLevelRaw integerValue];
    float indentPoints = indentLevel * 25;
    
    UILabel *commentBody;
    commentBody = (UILabel *)[cell viewWithTag:1];
    commentBody.userInteractionEnabled = YES;
    commentBody.numberOfLines = 0;
    
    //NSString *markdown = [tempDictionary valueForKey:@"body"];
    NSString *markdown = [self.flatComments objectAtIndex:indexPath.row];
    commentBody.text = markdown;
    
    commentBody.font = [UIFont fontWithName:@"Avenir" size:16.0f];
    commentBody.preferredMaxLayoutWidth = 280 - indentPoints; // <<<<< ALL THE MAGIC

    UILabel *usernameMeta;
    usernameMeta = (UILabel *)[cell viewWithTag:2];
    usernameMeta.text = [self.flatUsers objectAtIndex:indexPath.row];
    
    cell.indentationWidth = 25;
    
    UILabel *date;
    date = (UILabel *)[cell viewWithTag:3];
    date.text = [self convertDateToRelativeDate: [self.flatTime objectAtIndex:indexPath.row]];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSString *indentLevelRaw = [_commentDepth objectAtIndex:indexPath.row];
    NSUInteger indentLevel = [indentLevelRaw integerValue];
    float indentPoints = indentLevel * 25;
    
    UILabel *commentBody;
    commentBody = (UILabel *)[cell viewWithTag:1];
    
    //NSString *markdown = [tempDictionary valueForKey:@"body"];
    NSString *markdown = [self.flatComments objectAtIndex:indexPath.row];
    commentBody.text = markdown;
    commentBody.preferredMaxLayoutWidth = 280 - indentPoints; // <<<<< ALL THE MAGIC
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];

    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return ceil(height) + 1;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 77;
}

-(void)selectedLink:(NSString *)string
{
    NSLog(@"Tap link");
    self.webViewController = [[PBWebViewController alloc] init];
    self.webViewController.view.backgroundColor = [UIColor whiteColor];
    self.webViewController.URL = [NSURL URLWithString: string];
    
    PBSafariActivity *activity = [[PBSafariActivity alloc] init];
    self.webViewController.applicationActivities = @[activity];
    
    self.webViewController.hidesBottomBarWhenPushed = YES;
    
    // Push it
    [self.navigationController pushViewController:self.webViewController animated:YES];
}

-(NSString*)convertDateToRelativeDate:(NSString*)date {;
    NSString *origDate = date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    NSDate *origDateAsDate = [formatter dateFromString: origDate];
    NSString *relativeDate = [[SORelativeDateTransformer registeredTransformer] transformedValue: origDateAsDate];
    
    return relativeDate;
}

@end
