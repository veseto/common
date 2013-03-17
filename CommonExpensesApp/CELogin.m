//
//  CELogin.m
//  CommonExpensesApp
//
//  Created by veseto on 28.02.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CELogin.h"
#import "CERequestHandler.h"
#import "CEDBConnector.h"
#import "CEAppDelegate.h"
#import "KeyboardBar.h"
#import "CEUser.h"
#import <CommonCrypto/CommonDigest.h>

@interface CELogin ()

@end

@implementation CELogin
@synthesize username = _username;
@synthesize password = _password;
@synthesize text = _text;
@synthesize rememberUser = _rememberUser;
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
    
}
-(void) viewWillAppear: (BOOL) animated {
    bar = [KeyboardBar new];
    NSMutableArray *fields = [[NSMutableArray alloc] initWithObjects:_username, _password, nil];
    for (UITextField *field in fields) {
        [field setInputAccessoryView:bar];
    }
    bar.index = -1;
    bar.field = nil;
    bar.fields = fields;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)LogIn:(id)sender {
    [self logIn];
    
}

- (void) logIn {
    if (_username.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing username"
                                                        message:@"Username is not provided"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else if (_password.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing password"
                                                        message:@"Password is not provided"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        CEDBConnector *connector = [[CEDBConnector alloc] init];
        CEAppDelegate *delegate =[[UIApplication sharedApplication] delegate];
        
        bool isLogged = NO;
        CEUser *user = [connector getUser:_username.text];
        if (user != nil && [user.password isEqualToString:[self sha1:_password.text]]) {
            isLogged = YES;
        } else {
            CERequestHandler *handler = [[CERequestHandler alloc] init];
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setObject:_username.text forKey:@"username"];
            [params setObject:_password.text forKey:@"password"];
            NSDictionary *json = [handler sendRequest:params :@"usrlogin.php"];
            [connector saveUser:json];
            if ([json count] > 0) {
                isLogged = YES;
                user = [CEUser new];
                user.userName = [json valueForKey:@"username"];
                user.userId = [NSNumber numberWithInt:[[json valueForKey:@"userid"] integerValue]];
            }
        }
        if (user == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User does not exists"
                                                            message:[NSString stringWithFormat:@"Username %@ is not registered", _username.text]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            if (isLogged) {
                delegate.currentUser = user;
                if ([_rememberUser isOn]) {
                    [connector setDefaultUser:user.userName:user.userId];
                }
                UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
                UIViewController *home = [sb instantiateViewControllerWithIdentifier:@"home"];
                [self.navigationController pushViewController:home animated:YES];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wrong credentials"
                                                                message:@"Username and password don't match"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
            }
        }
    }
}

-(NSString*) sha1:(NSString*)input {
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [bar setField:textField];
    bar.index = [bar.fields indexOfObject:textField];
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [bar setField:nil];
    bar.index = -1;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self logIn];
    return YES;
}

@end
