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
#import "CELogin.h"
#import <CommonCrypto/CommonDigest.h>

@interface CESignUp ()

@end

@implementation CESignUp

@synthesize password = _password;
@synthesize email = _email;
@synthesize delegate = _delegate;
@synthesize username = _username;
bool isRegistered;
CEAppDelegate *appDelegate;

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
    appDelegate =[[UIApplication sharedApplication] delegate];
    appDelegate.currentUser = nil;
    appDelegate.currentCircle = nil;
    CEDBConnector * connector = [[CEDBConnector alloc] init];
    [connector removeDefaultUser];


}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) signUpLocal:(NSDictionary *) usr {
    if (usr == nil) {
        if (_username.text.length < 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty username"
                                                            message:@"Enter valid username"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [[self.view viewWithTag:9] becomeFirstResponder];
        } else if (![self validateEmail:_email.text]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect e-mail"
                                                            message:@"Enter valid e-mail address"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [[self.view viewWithTag:10] becomeFirstResponder];
        } else if (_password.text.length < 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty password"
                                                            message:@"Enter password"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat screenWidth = screenRect.size.width;
            CGFloat screenHeight = screenRect.size.height;
            
            spinner.center = CGPointMake(screenWidth/2, screenHeight/2 - 35);
            spinner.color = [UIColor blackColor];
            [self.view addSubview:spinner];
            [spinner startAnimating];
            dispatch_queue_t workingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(workingQueue,
                           ^{
                               NSMutableDictionary *params = [[NSMutableDictionary     alloc] init];
                               [params setObject:_username.text forKey:@"username"];
                               [params setObject:_email.text forKey:@"email"];
                               [params setObject:_password.text forKey:@"password"];
                               CERequestHandler *handler = [[CERequestHandler alloc] init];
                               NSDictionary *json = [handler sendRequest:params :@"usrregister.php"];
                               
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (json != nil &&  [json objectForKey:@"error"] != nil) {
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection failed"
                                                                                       message:((NSError *) [json objectForKey:@"error"]).description
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
                                       appDelegate.currentUser= user;
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pending activation"
                                                                                       message:[NSString stringWithFormat:@"Activation e-mail was sent to %@. You won't be able to sync data until account is not activated", _email.text]
                                                                                      delegate:nil
                                                                             cancelButtonTitle:@"OK"
                                                                             otherButtonTitles:nil];
                                       [alert show];
                                       
                                       [self closeView:self];
                                       
                                   } else {
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration fail"
                                                                                       message:[NSString stringWithFormat:@"Email %@ already registered", _email.text]
                                                                                      delegate:nil
                                                                             cancelButtonTitle:@"OK"
                                                                             otherButtonTitles:nil];
                                       [alert show];
                                       
                                   }
                                   
                                   [spinner stopAnimating];
                               });
                           });
            
            
            
        }
    }

    
  //  [self dismissViewControllerAnimated:YES completion:nil];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 10) {
        [[self.view viewWithTag:20] becomeFirstResponder];
        [textField resignFirstResponder];
        
    } else if (textField.tag == 9){
        [[self.view viewWithTag:10] becomeFirstResponder];
    } else {
        [self signUpLocal:nil];
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


- (IBAction)closeView:(id)sender {
    if ([self.delegate isKindOfClass:[CELogin class]]) {
        [self.delegate closeViews];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)signUp:(id)sender {
    [self signUpLocal:nil];
}

- (IBAction)openLoginView:(id)sender {
    if ([self.delegate isKindOfClass:[CELogin class]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        CELogin *login = [sb instantiateViewControllerWithIdentifier:@"emailLogin"];
        login.delegate = self;
        [login setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        
        [self presentViewController:login animated:YES completion:nil];
    }
    
}

-(void) viewWillAppear:(BOOL)animated {
    isRegistered = NO;
}
-(void) viewWillDisappear:(BOOL)animated {
    if (appDelegate.currentUser != nil) {
        [((CEStartPageViewController *)_delegate) showHomeView];
    }
}

-(void) showHomeView {
    if (appDelegate.currentUser != nil) {
        [((CEStartPageViewController *)_delegate) showHomeView];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [super scrollViewToField:textField];
    
}

-(void) closeViews {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
