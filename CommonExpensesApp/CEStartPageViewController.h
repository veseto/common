//
//  CEStartPageViewController.h
//  CommonExpensesApp
//
//  Created by Murat, Deniz on 19.04.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface CEStartPageViewController : UIViewController

- (void)showHomeView;

- (IBAction)showLoginView:(id)sender;
- (IBAction)showRegisterView:(id)sender;
- (IBAction)registerWithFacebook:(id)sender;
@property (nonatomic, retain) ACAccountStore *accountStore;
@property (nonatomic, retain) ACAccount *facebookAccount;
@end
