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
#import "CircleDefinition.h"
#import "CEDBConnector.h"
#import "UserSettings.h"


@interface CEHomeViewController ()

@end

@implementation CEHomeViewController
@synthesize selfViewButton = _selfViewButton;

CEAppDelegate *delegate;
NSMutableArray *friends;
CEDBConnector *connector;

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
    self.navigationController.sideMenu.openMenuEnabled = YES;
    delegate = [[UIApplication sharedApplication] delegate];
    connector = [CEDBConnector new];
    [self setupMenuBarButtonItems];
    friends = [[NSMutableArray alloc] init];
    UserSettings *settings = [connector getUserSettings:delegate.currentUser.userId];
    NSArray *def = [connector getCirclesForUser:delegate.currentUser.userId];
    if (settings != nil && [settings valueForKey:@"defaultCirlceName"] != nil) {
        [self.view addSubview:[self createTableView]];
        [self reloadView:[settings valueForKey:@"defaultCirlceName"]];
    } else if (def != nil && def.count > 0){
        [self.view addSubview:[self createTableView]];
        [self reloadView:[[def objectAtIndex:0] valueForKey:@"name"]];
    } else {
        [self.view addSubview:[self createView]];
    }
    
    [_selfViewButton setTitle:delegate.currentUser.userName forState:UIControlStateNormal];;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveReloadNotification:)
                                                 name:@"ReloadHomeViewNotification"
                                               object:nil];

    __weak CEHomeViewController *weakSelf = self;
    // if you want to listen for menu open/close events
    // this is useful, for example, if you want to change a UIBarButtonItem when the menu closes
    self.navigationController.sideMenu.menuStateEventBlock = ^(MFSideMenuStateEvent event) {
        NSLog(@"event occurred: %@", weakSelf.navigationItem.title);
        switch (event) {
            case MFSideMenuStateEventMenuWillOpen:
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"ReloadTableNotification"
                 object:weakSelf];
                break;
            case MFSideMenuStateEventMenuDidOpen:
                break;
            case MFSideMenuStateEventMenuWillClose:
                
                break;
            case MFSideMenuStateEventMenuDidClose:
                // the menu finished closing
             //   weakSelf.navigationItem.title = @"Menu Closed!";
                break;
        }
        
        [weakSelf setupMenuBarButtonItems];
    };
}

-(UITableView *) createTableView {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGRect newFrame = CGRectMake(0, 0, 0, 0);
    newFrame.size = CGSizeMake(screenWidth, screenHeight - 165);
    UITableView *view = [[UITableView alloc] initWithFrame:newFrame style:UITableViewStylePlain];
    view.delegate = self;
    view.dataSource = self;
    view.tag = 1000;
    return view;
}

-(UIView *) createView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGRect newFrame = CGRectMake(0, 0, 0, 0);
    newFrame.size = CGSizeMake(screenWidth, screenHeight - 165);
    UIView *view = [[UIView alloc] initWithFrame:newFrame];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, screenWidth, 30)];
    label.text = @"You don't have circles";
    [view addSubview:label];
    return view;
}

- (void) reloadView: (NSString *) circle{
    self.navigationItem.title = circle;
    friends = [[NSMutableArray alloc] initWithArray:[connector getFriendsInCircle:circle]];
    [((UITableView *)[self.view viewWithTag:1000]) reloadData];
}

- (void) receiveReloadNotification:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    [self reloadView:[userInfo objectForKey:@"circle"]];
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


- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



- (IBAction)showSelfStatistics:(id)sender {
    UIViewController *stats = [self.storyboard instantiateViewControllerWithIdentifier:@"statistics"];
    [self presentViewController:stats animated:YES completion:nil];

}

- (IBAction)sync:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sync"
                                                    message:@"Not yet implemented"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}

- (IBAction)someAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Show history"
                                                    message:@"Not yet implemented"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}

- (IBAction)handleGesture:(UIPanGestureRecognizer *)sender {
    //TODO:
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [[friends objectAtIndex:indexPath.row] valueForKey:@"friendName"];
   
    return cell;
}


@end
