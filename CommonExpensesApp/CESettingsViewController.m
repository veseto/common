//
//  CESettingsViewController.m
//  CommonExpensesApp
//
//  Created by veseto on 17.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CESettingsViewController.h"

@interface CESettingsViewController ()

@end

@implementation CESettingsViewController

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

- (IBAction)closeView:(id)sender {
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController *home = [sb instantiateViewControllerWithIdentifier:@"home"];
    [self.navigationController pushViewController:home animated:YES];
}
@end
