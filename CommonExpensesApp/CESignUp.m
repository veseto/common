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
@synthesize password = _password;
@synthesize confirm = _confirm;
@synthesize email = _email;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

-(void) viewWillAppear: (BOOL) animated {
    bar = [[KeyboardBar alloc] init];
    NSMutableArray * fields = [[NSMutableArray alloc] initWithObjects:_userName, _email, _password, _confirm, nil];
    bar.field = nil;
    bar.index = -1;
    for (UITextField *field in fields) {
        [field setInputAccessoryView:bar];
    }
    [bar setFields:fields];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)register:(id)sender {
    [self signUp];
    
}

- (void) signUp {
    if (_userName.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty username"
                                                        message:@"Enter username"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else if (_userName.text.length < 4) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid username"
                                                        message:@"Username should be at least 4 symbols"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else if (![self validateEmail:_email.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect e-mail"
                                                        message:@"Enter valid e-mail address"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else if (_password.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty password"
                                                        message:@"Enter password"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else if ([_password.text isEqualToString:_confirm.text]) {
        NSMutableDictionary *params = [[NSMutableDictionary     alloc] init];
        [params setObject:_userName.text forKey:@"username"];
        [params setObject:_email.text forKey:@"email"];
        [params setObject:_password.text forKey:@"password"];
        [params setObject:_confirm.text forKey:@"confirm"];
        CERequestHandler *handler = [[CERequestHandler alloc] init];
        NSDictionary *json = [handler sendRequest:params :@"usrregister.php"];
        if (json != nil &&  [json objectForKey:@"error"] != nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection failed"
                                                            message:((NSError *) [json objectForKey:@"error"]).localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else if (json != nil && json.count > 0) {
            CEDBConnector * connector = [[CEDBConnector alloc] init];
            [connector saveUser:json];
            CEUser *user = [CEUser new];
            user.userName = [json valueForKey:@"username"];
            user.userId = [NSNumber numberWithInt:[[json valueForKey:@"userid"] intValue]];
            ((CEAppDelegate *)[[UIApplication sharedApplication] delegate]).currentUser= user;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pending activation"
                                                            message:[NSString stringWithFormat:@"Activation e-mail was sent to %@. You won't be able to sync data until account is not activated", _email.text]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTableNotification" object:self];
            UIViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"home"];
            [self.navigationController pushViewController:home animated:YES];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration fail"
                                                            message:[NSString stringWithFormat:@"User with username %@ already exists", _userName.text]
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


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self signUp];
    return YES;
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

- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
