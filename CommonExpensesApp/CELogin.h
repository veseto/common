//
//  CELogin.h
//  CommonExpensesApp
//
//  Created by veseto on 28.02.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEKeyboardScroll.h"

@interface CELogin : CEKeyboardScroll <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UISwitch *rememberUser;
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (nonatomic, assign) id delegate;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *forgotPassBtn;

- (IBAction)LogIn:(id)sender;
- (IBAction)closeView:(id)sender;
- (IBAction)openSignUpView:(id)sender;
-(void) showHomeView;
-(void) closeViews;
@end
