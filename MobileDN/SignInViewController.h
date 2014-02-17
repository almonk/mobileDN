//
//  SignInViewController.h
//  MobileDN
//
//  Created by Alasdair Monk on 17/02/2014.
//  Copyright (c) 2014 Alasdair Monk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppHelpers.h"

@interface SignInViewController : UITableViewController {
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
}

-(IBAction)doSignIn:(id)sender;

@end
