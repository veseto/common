//
//  CEPasswordResetViewController.m
//  CommonExpensesApp
//
//  Created by veseto on 21.04.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CEPasswordResetViewController.h"
#import "CERequestHandler.h"

@interface CEPasswordResetViewController ()

@end

@implementation CEPasswordResetViewController
@synthesize email = _email;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    super.scrollView = self.scrollView;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dust.png"]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendResetRequest:(id)sender {
    if (![self validateEmail:_email.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect e-mail"
                                                        message:@"Enter valid e-mail address"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        CERequestHandler *handler = [CERequestHandler new];
        NSMutableDictionary *params = [[NSMutableDictionary     alloc] init];
        [params setObject:_email.text forKey:@"email"];
        [handler sendRequest:params :@"passResetMail.php"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password reset"
                                                        message:[NSString stringWithFormat:@"Change password request is sent to %@.", _email.text]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
        [textField resignFirstResponder];
    
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [super scrollViewToField:textField];
    
}


- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

@end
