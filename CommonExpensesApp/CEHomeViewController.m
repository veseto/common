//
//  CEHomeViewController.m
//  CommonExpensesApp
//
//  Created by veseto on 11.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CEHomeViewController.h"
#import "MFSideMenu.h"
#import "CEAppDelegate.h"


@interface CEHomeViewController ()

@end

@implementation CEHomeViewController

CEAppDelegate *delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc {
    self.navigationController.sideMenu.menuStateEventBlock = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = [[UIApplication sharedApplication] delegate];
    [self setupMenuBarButtonItems];
    
    __weak CEHomeViewController *weakSelf = self;
    // if you want to listen for menu open/close events
    // this is useful, for example, if you want to change a UIBarButtonItem when the menu closes
    weakSelf.navigationItem.title = delegate.currentUser;
    self.navigationController.sideMenu.menuStateEventBlock = ^(MFSideMenuStateEvent event) {
        NSLog(@"event occurred: %@", weakSelf.navigationItem.title);
        switch (event) {
            case MFSideMenuStateEventMenuWillOpen:
                // the menu will open
                //weakSelf.navigationItem.title = @"Menu Will Open!";
                break;
            case MFSideMenuStateEventMenuDidOpen:
                // the menu finished opening
               // weakSelf.navigationItem.title = @"Menu Opened!";
                break;
            case MFSideMenuStateEventMenuWillClose:
                // the menu will close
               // weakSelf.navigationItem.title = @"Menu Will Close!";
                break;
            case MFSideMenuStateEventMenuDidClose:
                // the menu finished closing
             //   weakSelf.navigationItem.title = @"Menu Closed!";
                break;
        }
        
        [weakSelf setupMenuBarButtonItems];
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
        case MFSideMenuStateRightMenuOpen:
            break;
    }
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered
            target:self.navigationController.sideMenu
            action:@selector(toggleLeftSideMenu)];
}

- (UIBarButtonItem *)backBarButtonItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
                                            style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(backButtonPressed:)];
}

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



@end
