//
//  SettingsViewController.h
//  MobileDN
//
//  Created by Alasdair Monk on 12/01/2014.
//  Copyright (c) 2014 Alasdair Monk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController {
    IBOutlet UITableViewCell *signOutCell;
    IBOutlet UIBarButtonItem *signInButton;
}

-(IBAction)signOut:(id)sender;
-(IBAction)signIn:(id)sender;
-(IBAction)doFeedback:(id)sender;


@end
