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
#import "CEStartPageViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "CESignUp.h"

@interface CELogin ()

@end

@implementation CELogin
@synthesize username = _username;
@synthesize password = _password;
@synthesize rememberUser = _rememberUser;
@synthesize forgotPassBtn = _forgotPassBtn;


bool isLogged;

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
    [_forgotPassBtn setTitleColor:[UIColor colorWithRed:(242.0f/255.0f) green:(240.0f/255.0f) blue:(223.0f/255.0f) alpha:1.0f] forState:UIControlStateNormal];

}
-(void) viewWillAppear: (BOOL) animated {
    isLogged = NO;
    CEAppDelegate *delegate =[[UIApplication sharedApplication] delegate];
    delegate.currentCircle = nil;
    delegate.currentUser = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)LogIn:(id)sender {
    [self logIn];
    
}

- (IBAction)closeView:(id)sender {
    if ([self.delegate isKindOfClass:[CESignUp class]]) {
        [self.delegate closeViews];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)openSignUpView:(id)sender {
    if ([self.delegate isKindOfClass:[CESignUp class]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        CELogin *login = [sb instantiateViewControllerWithIdentifier:@"CESignUp"];
        login.delegate = self;
        [login setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        
        [self presentViewController:login animated:YES completion:nil];
    }
}

- (IBAction)loginWithFacebook:(id)sender {
    [self openSessionWithAllowLoginUI:YES];
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
        [self handleLogin:nil];
    }
}

- (void) handleLogin:(NSDictionary *)usr {
    CEAppDelegate *delegate =[[UIApplication sharedApplication] delegate];
    CEDBConnector *connector = [[CEDBConnector alloc] init];

    CEUser *user = nil;
    if (usr == nil) {
        
        user = [connector getUser:_username.text];
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
                user.userId = [NSNumber numberWithInt:[[json valueForKey:@"userid"] intValue]];
            }
        }
        if (user == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User does not exists"
                                                            message:[NSString stringWithFormat:@"Username %@ is not registered", _username.text]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else if (!isLogged) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wrong credentials"
                                                            message:@"Username and password don't match"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    } else {
        CEDBConnector *connector = [[CEDBConnector alloc] init];
        
        CEUser *user = [connector getUser:[usr objectForKey:@"name"]];
        if (user != nil && [user.password isEqualToString:[self sha1:_password.text]]) {
            isLogged = YES;
        } else {
            CERequestHandler *handler = [[CERequestHandler alloc] init];
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setObject:[usr objectForKey:@"name"] forKey:@"username"];
            [params setObject:[usr objectForKey:@"id"] forKey:@"password"];
            NSDictionary *json = [handler sendRequest:params :@"usrlogin.php"];
            [connector saveUser:json];
            if ([json count] > 0) {
                isLogged = YES;
                user = [CEUser new];
                user.userName = [json valueForKey:@"username"];
                user.userId = [NSNumber numberWithInt:[[json valueForKey:@"userid"] intValue]];
            }
        }
        if (user == nil) {
            bool isRegistered;
            NSMutableDictionary *params = [[NSMutableDictionary     alloc] init];
            [params setObject:[usr objectForKey:@"name"] forKey:@"username"];
            [params setObject:[usr objectForKey:@"email"] forKey:@"email"];
            [params setObject:[usr objectForKey:@"id"] forKey:@"password"];
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
                                                                message:[NSString stringWithFormat:@"Activation e-mail was sent to %@. You won't be able to sync data until account is not activated", [usr objectForKey:@"email"]]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            } else {
                
            }
        }
    }
    if (isLogged) {
        delegate.currentUser = user;
        [connector setDefaultUser:user.userName:user.userId];
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
    [super scrollViewToField:textField];
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 10) {
        [[self.view viewWithTag:20] becomeFirstResponder];
    } else {
        [self logIn];
    }
    
    return YES;
}

-(void) viewWillDisappear:(BOOL)animated {
    if (isLogged) {
        [((CEStartPageViewController *)_delegate) showHomeView];
    }
}
-(void) closeViews {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)me{
    if (FBSession.activeSession.isOpen) {
        //[self.authButton setTitle:@"Logout" forState:UIControlStateNormal];
        //self.userInfoTextView.hidden = NO;
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                                               id<FBGraphUser> fbuser,
                                                               NSError *error) {
            if (!error) {
                [self handleLogin:fbuser];
            }
        }];
    }
    
    
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"user_location",
                            @"user_birthday",
                            @"user_likes",
                            nil];
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self me];
                                         }];
}

@end
