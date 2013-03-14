//
//  CESignUp.m
//  CommonExpensesApp
//
//  Created by veseto on 18.02.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CESignUp.h"
#import "CERequestHandler.h"
#import "CEDBConnector.h"
#import "KeyboardBar.h"
#import "CEAppDelegate.h"

@interface CESignUp ()

@end

@implementation CESignUp

@synthesize userName = _userName;
@synthesize email = _email;
@synthesize password = _password;
@synthesize confirm = _confirm;
@synthesize isDefault = _isDefault;

KeyboardBar *bar;

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
    bar = [[KeyboardBar alloc] init];
    NSMutableArray * fields = [[NSMutableArray alloc] initWithObjects:_userName, _email, _password, _confirm, nil];
    bar.field = nil;
    bar.index = -1;
    for (UITextField *field in fields) {
        [field setInputAccessoryView:bar];
    }
    [bar setFields:fields];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)register:(id)sender {
    
    if ([_password.text isEqualToString:_confirm.text]) {
        NSMutableDictionary *params = [[NSMutableDictionary     alloc] init];
        [params setObject:_userName.text forKey:@"username"];
        [params setObject:_password.text forKey:@"password"];
        [params setObject:_confirm.text forKey:@"confirm"];
        [params setObject:_email.text forKey:@"email"];
        CERequestHandler *handler = [[CERequestHandler alloc] init];
        NSDictionary *json = [handler sendRequest:params :@"usrregister.php"];
        if (json != nil && json.count > 0) {
            CEDBConnector * connector = [[CEDBConnector alloc] init];
            [connector saveUser:json];
            ((CEAppDelegate *)[[UIApplication sharedApplication] delegate]).currentUser = _userName.text;
            if ([_isDefault isOn]) {
                [connector setDefaultUser:_userName.text];
            }
            UIViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"home"];
            [self.navigationController pushViewController:home animated:YES];

        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration fail"
                                                            message:@"User cannot be created"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password confirmation"
                                                        message:@"Passwords don't match"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//CESuccessViewController *vc = [segue destinationViewController];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    bar.field = textField;
    bar.index = [bar.fields indexOfObject:textField];
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}


- (void)keyboardWasShown:(NSNotification *)notification
{
    
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    
    // Step 3: Scroll the target text field into view.
    CGRect aRect = self.view.frame;
    aRect.size.height -= (keyboardSize.height + 15);
    if (!CGRectContainsPoint(aRect, bar.field.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, 55);//bar.field.frame.origin.y - (keyboardSize.height-15));
        [_scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void) keyboardWillHide:(NSNotification *)notification {
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}

@end
