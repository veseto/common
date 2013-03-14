//
//  CEAddCircleViewController.m
//  CommonExpensesApp
//
//  Created by veseto on 14.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CEAddCircleViewController.h"
#import "CircleDefinition.h"
#import "CEAddFriendsViewController.h"

@interface CEAddCircleViewController ()

@end

@implementation CEAddCircleViewController
@synthesize name = _name;
@synthesize numberOfFriends = _numberOfFriends;

CircleDefinition *circle;

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    circle = [[CircleDefinition alloc] init];
    [circle setName: _name.text];
    [circle setNumberOfFriends:[NSNumber numberWithInt: _numberOfFriends.text.integerValue]];
    CEAddFriendsViewController *vc = [segue destinationViewController];
    vc.circle = circle;
}

@end
