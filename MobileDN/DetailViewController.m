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
#import <TTTAttributedLabel.h>
#import "PBWebViewController.h"
#import <PBSafariActivity.h>

@interface DetailViewController ()
@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.flatComments = [[NSMutableArray alloc] init];
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
            [_flatComments addObject:object];
            NSLog(@"comments %d", [_flatComments count]);
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDictionary *tempDictionary = [self.comments objectAtIndex:indexPath.row];
    
    
    TTTAttributedLabel *commentBody;
    commentBody = (TTTAttributedLabel *)[cell viewWithTag:1];
    commentBody.delegate = self;
    commentBody.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    //NSString *markdown = [tempDictionary valueForKey:@"body"];
    NSString *markdown = [self.flatComments objectAtIndex:indexPath.row];
//    NSString *html = [MMMarkdown HTMLStringWithMarkdown:markdown error:nil];
//    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
//    NSAttributedString *preview = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:nil error:nil];
    
    commentBody.text = markdown;
    [commentBody setText:markdown afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {

        return mutableAttributedString;
    }];
    commentBody.font = [UIFont fontWithName:@"Avenir" size:16.0f];
    [commentBody sizeToFit];

    
    
    UILabel *usernameMeta;
    usernameMeta = (UILabel *)[cell viewWithTag:2];
    usernameMeta.text = [tempDictionary valueForKey:@"user_display_name"];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    commentBody.preferredMaxLayoutWidth = CGRectGetWidth(tableView.frame);

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSDictionary *tempDictionary = [self.comments objectAtIndex:indexPath.row];
    
    TTTAttributedLabel *commentBody;
    commentBody = (TTTAttributedLabel *)[cell viewWithTag:1];
    commentBody.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    NSString *markdown = [tempDictionary valueForKey:@"body"];
//    NSString *html = [MMMarkdown HTMLStringWithMarkdown:markdown error:nil];
//    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
//    NSAttributedString *preview = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:nil error:nil];
    
    commentBody.text = markdown;
    [commentBody setText:markdown afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        return mutableAttributedString;
    }];
    commentBody.font = [UIFont fontWithName:@"Avenir" size:16.0f];
    [commentBody sizeToFit];

    
    UILabel *usernameMeta;
    usernameMeta = (UILabel *)[cell viewWithTag:2];
    usernameMeta.text = [tempDictionary valueForKey:@"user_display_name"];
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));

    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1; // Round up
    return height;
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    self.webViewController = [[PBWebViewController alloc] init];
    self.webViewController.view.backgroundColor = [UIColor whiteColor];
    self.webViewController.URL = url;
    
    PBSafariActivity *activity = [[PBSafariActivity alloc] init];
    self.webViewController.applicationActivities = @[activity];
    
    self.webViewController.hidesBottomBarWhenPushed = YES;
    
    // Push it
    [self.navigationController pushViewController:self.webViewController animated:YES];
}

@end
