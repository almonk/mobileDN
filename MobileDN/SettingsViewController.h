//
//  SettingsViewController.h
//  MobileDN
//
//  Created by Alasdair Monk on 12/01/2014.
//  Copyright (c) 2014 Alasdair Monk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController {
    IBOutlet UIImageView *avatar;
    IBOutlet UILabel *name;
    IBOutlet UILabel *jobTitle;
    IBOutlet UIActivityIndicatorView *spinner;
}
-(IBAction)showSharingSettings:(id)sender;
-(IBAction)signOut:(id)sender;
-(IBAction)doFeedback:(id)sender;


@end
