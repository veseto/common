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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendResetRequest:(id)sender {
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

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
