//
//  CEStartPageViewController.m
//  CommonExpensesApp
//
//  Created by Murat, Deniz on 19.04.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CEStartPageViewController.h"
#import "CELogin.h"
#import <Social/Social.h>

@interface CEStartPageViewController ()

@end

@implementation CEStartPageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dust.png"]];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)showHomeView{
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController *home = [sb instantiateViewControllerWithIdentifier:@"home"];
    [self.navigationController pushViewController:home animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTableNotification" object:self];

}

- (IBAction)showLoginView:(id)sender {
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    CELogin *login = [sb instantiateViewControllerWithIdentifier:@"emailLogin"];
    login.delegate = self;
    
    [self.navigationController presentViewController:login animated:YES completion:nil];
}

- (IBAction)showRegisterView:(id)sender {
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    CELogin *login = [sb instantiateViewControllerWithIdentifier:@"CESignUp"];
    login.delegate = self;
    
    [self.navigationController presentViewController:login animated:YES completion:nil];
}

- (IBAction)registerWithFacebook:(id)sender {
    [self openSessionWithAllowLoginUI:YES];
    
}

- (void)me{
    if (FBSession.activeSession.isOpen) {
        //[self.authButton setTitle:@"Logout" forState:UIControlStateNormal];
        //self.userInfoTextView.hidden = NO;
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                                               id<FBGraphUser> user,
                                                               NSError *error) {
            if (!error) {
                NSString *userInfo = @"";
                
                // Example: typed access (name)
                // - no special permissions required
                userInfo = [userInfo
                            stringByAppendingString:
                            [NSString stringWithFormat:@"Name: %@\n\n",
                             user.name]];
                
                // Example: typed access, (birthday)
                // - requires user_birthday permission
                userInfo = [userInfo
                            stringByAppendingString:
                            [NSString stringWithFormat:@"Birthday: %@\n\n",
                             user.birthday]];
                
                // Example: partially typed access, to location field,
                // name key (location)
                // - requires user_location permission
                userInfo = [userInfo
                            stringByAppendingString:
                            [NSString stringWithFormat:@"Location: %@\n\n",
                             [user.location objectForKey:@"name"]]];
                
                // Example: access via key (locale)
                // - no special permissions required
                userInfo = [userInfo
                            stringByAppendingString:
                            [NSString stringWithFormat:@"Locale: %@\n\n",
                             [user objectForKey:@"locale"]]];
                
                // Example: access via key for array (languages)
                // - requires user_likes permission
                if ([user objectForKey:@"languages"]) {
                    NSArray *languages = [user objectForKey:@"languages"];
                    NSMutableArray *languageNames = [[NSMutableArray alloc] init];
                    for (int i = 0; i < [languages count]; i++) {
                        [languageNames addObject:[[languages
                                                   objectAtIndex:i]
                                                  objectForKey:@"name"]];
                    }
                    userInfo = [userInfo
                                stringByAppendingString:
                                [NSString stringWithFormat:@"Languages: %@\n\n",
                                 languageNames]];
                }
                
                // Display the user info
                
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
