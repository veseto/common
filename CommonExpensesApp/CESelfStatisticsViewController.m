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
    [self setupMenuBarButtonItems];

    self.navigationController.sideMenu.openMenuEnabled = YES;
    __weak CESelfStatisticsViewController *weakSelf = self;
    
    self.navigationController.sideMenu.menuStateEventBlock = ^(MFSideMenuStateEvent event) {
        NSLog(@"event occurred: %@", weakSelf.navigationItem.title);
        switch (event) {
            case MFSideMenuStateEventMenuWillOpen:
                break;
            case MFSideMenuStateEventMenuDidOpen:
                break;
            case MFSideMenuStateEventMenuWillClose:
            {
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"hideKeyboardNotification"
                 object:weakSelf];
            }
                break;
            case MFSideMenuStateEventMenuDidClose: 
                break;
        }        
    };
}

- (void)setupMenuBarButtonItems {
    switch (self.navigationController.sideMenu.menuState) {
        case MFSideMenuStateClosed:
            self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
            break;
        case MFSideMenuStateLeftMenuOpen:
            self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
            break;
    }
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered
            target:self.navigationController.sideMenu
            action:@selector(toggleLeftSideMenu)];
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
