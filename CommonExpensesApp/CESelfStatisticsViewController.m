//
//  CESelfStatisticsViewController.m
//  CommonExpensesApp
//
//  Created by veseto on 16.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CESelfStatisticsViewController.h"

@interface CESelfStatisticsViewController ()

@end

@implementation CESelfStatisticsViewController

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

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
