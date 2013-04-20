//
//  CESignUp.h
//  CommonExpensesApp
//
//  Created by veseto on 18.02.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CESignUp : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (nonatomic, assign) id delegate;

- (IBAction)closeView:(id)sender;

@end
