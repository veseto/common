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
#import "CEStartPageViewController.h"

@interface CESignUp ()

@end

@implementation CESignUp

@synthesize password = _password;
@synthesize email = _email;
@synthesize delegate = _delegate;
bool isRegistered;

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
    if (_password.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty password"
                                                        message:@"Enter password"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        NSMutableDictionary *params = [[NSMutableDictionary     alloc] init];
        [params setObject:_email.text forKey:@"username"];
        [params setObject:_email.text forKey:@"email"];
        [params setObject:_password.text forKey:@"password"];
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
            isRegistered = YES;
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
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration fail"
                                                            message:[NSString stringWithFormat:@"Email %@ already registered", _email.text]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 10) {
        if (![self validateEmail:_email.text]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect e-mail"
                                                            message:@"Enter valid e-mail address"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            [self resignFirstResponder];
            [[self.view viewWithTag:20] becomeFirstResponder];
        }
    } else {
        [self signUp];
    }
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

-(void) viewWillAppear:(BOOL)animated {
    isRegistered = NO;
}
-(void) viewWillDisappear:(BOOL)animated {
    if (isRegistered) {
        [((CEStartPageViewController *)_delegate) showHomeView];
    }
}
@end
