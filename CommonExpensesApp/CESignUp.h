//
//  CESignUp.h
//  CommonExpensesApp
//
//  Created by veseto on 18.02.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEKeyboardScroll.h"

@interface CESignUp : CEKeyboardScroll <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (nonatomic, assign) id delegate;
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)closeView:(id)sender;
- (IBAction)signUp:(id)sender;
- (IBAction)openLoginView:(id)sender;
-(void) closeViews;
@end
