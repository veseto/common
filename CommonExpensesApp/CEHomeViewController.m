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
#import "CESynchManager.h"
#import "CERequestHandler.h"

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
        [self reloadView:[settings valueForKey:@"defaultCirlceName"] :0];
    } else if (def != nil && def.count > 0){
        [self.view addSubview:[self createTableView]];
        [self reloadView:[[def objectAtIndex:0] valueForKey:@"name"] :[[[def objectAtIndex:0] valueForKey:@"numberOfFriends"] intValue]];
    } else {
        [self.view addSubview:[self createView]];
    }
    
    [_selfViewButton setTitle:delegate.currentUser.userName forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveReloadNotification:)
                                                 name:@"ReloadHomeViewNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showStatsView:)
                                                 name:@"ShowStatsViewNotification"
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
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"ReloadTableNotification"
                 object:weakSelf];
                break;
            case MFSideMenuStateEventMenuWillClose:
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"ReloadTableNotification"
                 object:weakSelf];
                break;
            case MFSideMenuStateEventMenuDidClose:
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"ReloadTableNotification"
                 object:weakSelf];
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
    view.tag = 2000;
    return view;
}

- (void) reloadView: (NSString *) circle :(int) numberOfFriends{
    if (circle != nil && circle.length >0) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@(%d)", circle, numberOfFriends];
        friends = [[NSMutableArray alloc] initWithArray:[connector getFriendsInCircle:circle]];
        UITableView *tableView = (UITableView *)[self.view viewWithTag:1000];
        if (tableView == nil) {
            [[self.view viewWithTag:2000] removeFromSuperview];
            [self.view addSubview:[self createTableView]];
        }
        [tableView reloadData];
    }
}

- (void) receiveReloadNotification:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    [self reloadView:[userInfo objectForKey:@"circle"] :[[userInfo objectForKey:@"numberOfFriends"] integerValue]];
}

-(void) showStatsView: (NSNotification *) notification {
    [self showStatView];
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
    [self showStatView];
}

-(void) showStatView{
    UIViewController *stats = [self.storyboard instantiateViewControllerWithIdentifier:@"statistics"];
    [self presentViewController:stats animated:YES completion:nil];

}

- (IBAction)sync:(id)sender {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setCenter:CGPointMake(self.view.window.frame.size.width/2.0, self.view.window.frame.size.height/2.0)]; // I do this because I'm in landscape mode
    [self.view addSubview:spinner];
    [spinner startAnimating];
    CESynchManager *syncMngr = [[CESynchManager alloc] init];
    CERequestHandler *handler = [CERequestHandler new];
    NSDictionary *res = [handler sendJsonRequest: [syncMngr syncAllUserData:delegate.currentUser.userId]:@"usrsync.php"];
    NSString *first = @"";
    int num = 0;
    for (NSDictionary * dict in res) {
        [connector createCircleFromServer:[dict objectForKey:@"friends"] :[NSNumber numberWithInt: [[dict objectForKey:@"ownerId"] integerValue]] :[dict objectForKey:@"name"] :[NSNumber numberWithInt:[[dict objectForKey:@"id"] integerValue]]];
        if (first.length == 0) {
            first = [dict objectForKey:@"name"];
            num = [[dict objectForKey:@"numberOfFriends"] intValue];
        }
    }
    [spinner stopAnimating];
    [self reloadView:first :num];
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
