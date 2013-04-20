//
//  CEStartPageViewController.m
//  CommonExpensesApp
//
//  Created by Murat, Deniz on 19.04.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CEStartPageViewController.h"
#import "CELogin.h"

@interface CEStartPageViewController ()

@end

@implementation CEStartPageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

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


@end
