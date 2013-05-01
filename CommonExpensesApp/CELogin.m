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
#import <QuartzCore/QuartzCore.h>

@interface CELogin ()

@end

@implementation CELogin
@synthesize username = _username;
@synthesize password = _password;
@synthesize rememberUser = _rememberUser;
@synthesize forgotPassBtn = _forgotPassBtn;


bool isLogged;
CEAppDelegate *appDelegate;
CEDBConnector *connector;

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
    connector = [[CEDBConnector alloc] init];
    isLogged = NO;
    [super viewDidLoad];
    [connector removeDefaultUser];
    
    appDelegate =[[UIApplication sharedApplication] delegate];
    appDelegate.currentUser = nil;
    appDelegate.currentCircle = nil;
    super.scrollView = self.scrollView;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dust.png"]];
    [_forgotPassBtn setTitleColor:[UIColor colorWithRed:(242.0f/255.0f) green:(240.0f/255.0f) blue:(223.0f/255.0f) alpha:1.0f] forState:UIControlStateNormal];
    [_forgotPassBtn setBackgroundColor:[UIColor colorWithRed:(142.0f/255.0f) green:(158.0f/255.0f) blue:(130.0f/255.0f) alpha:1.0f]];
    [_forgotPassBtn.layer setCornerRadius:3.0f];
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
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    spinner.center = CGPointMake(screenWidth/2, screenHeight/2 - 35);
    spinner.color = [UIColor blackColor];
    [self.view addSubview:spinner];
    [spinner startAnimating];
    NSString *username = _username.text;
    NSString *password = _password.text;
    dispatch_queue_t workingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(workingQueue,
                   ^{
                       CEUser *user = nil;
                       user = [connector getUser:username];
                       NSString *error = nil;
                       if (user != nil && [user.password isEqualToString:[self sha1:password]]) {
                           isLogged = YES;
                       } else {
                           CERequestHandler *handler = [[CERequestHandler alloc] init];
                           NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                           [params setObject:username forKey:@"username"];
                           [params setObject:password forKey:@"password"];
                           NSDictionary *json = [handler sendRequest:params :@"usrlogin.php"];
                           if ([json count] > 0) {
                               if ([json objectForKey:@"error"] == nil) {
                                   isLogged = YES;
                                   [connector saveUser:json];
                                   user = [CEUser new];
                                   user.userName = [json valueForKey:@"username"];
                                   user.userId = [NSNumber numberWithInt:[[json valueForKey:@"userid"] intValue]];
                               } else {
                                   error = [json objectForKey:@"error"];
                               }
                           }
                       }
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           if (error != nil) {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wrong credentials"
                                                                               message:@"Username and password don't match"
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil];
                               [alert show];

                           } else if (user == nil) {
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
                           
                           if (isLogged) {
                               appDelegate.currentUser = user;
                               [connector setDefaultUser:user.userName:user.userId];
                               [self closeView:self];
                           }
                           [spinner stopAnimating];
                       });
                   });
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
    if (appDelegate.currentUser != nil) {
        [((CEStartPageViewController *)_delegate) showHomeView];
    }
}
-(void) closeViews {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void) showHomeView {
    if (appDelegate.currentUser != nil) {
        [((CEStartPageViewController *)_delegate) showHomeView];
    }
}

@end
