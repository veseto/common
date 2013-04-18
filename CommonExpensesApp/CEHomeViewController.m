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
#import "CEFriendHelper.h"
#import "Friend.h"
#import "KeyboardBar.h"
#import "CEHistoryViewController.h"

@interface CEHomeViewController ()

@end

@implementation CEHomeViewController
@synthesize selfViewButton = _selfViewButton;
@synthesize tableView = _tableView;

CEAppDelegate *delegate;
NSArray *tmp;
NSMutableArray *friends;
CEDBConnector *connector;
KeyboardBar *bar;
UITextView *scroll;

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
    bar = [KeyboardBar new];
    
    //Add init with default circle
    [self reloadView];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTableNotification" object:weakSelf];
    self.navigationController.sideMenu.menuStateEventBlock = ^(MFSideMenuStateEvent event) {
        NSLog(@"event occurred: %@", weakSelf.navigationItem.title);
        switch (event) {
            case MFSideMenuStateEventMenuWillOpen:
                break;
            case MFSideMenuStateEventMenuDidOpen:
                break;
            case MFSideMenuStateEventMenuWillClose:
                break;
            case MFSideMenuStateEventMenuDidClose:
                break;
        }
        
        [weakSelf setupMenuBarButtonItems];
    };

}

-(UIView *) createTableView {
    UIView *viewToRemove = [self.view viewWithTag:2000];
    [[viewToRemove subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [viewToRemove removeFromSuperview];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;

    CGRect newFrame3 = CGRectMake(0, 0, 0, 0);
    newFrame3.size = CGSizeMake(screenWidth, screenHeight - 110);
    UIView *container = [[UIView alloc] initWithFrame:newFrame3];
  //  [container setBackgroundColor:[UIColor redColor]];
    
    CGRect newFrame = CGRectMake(0, 0, 0, 0);
    newFrame.size = CGSizeMake(screenWidth, 100);
    tmp = [[NSMutableArray alloc] initWithArray:[connector getFriendsInCircle:delegate.currentCircle.name :delegate.currentCircle.ownerId]];
    
    scroll = [[UITextView alloc] initWithFrame:newFrame];
    NSMutableString *text = [NSMutableString new];
    for (Friend *fr in tmp) {
        [text appendString:fr.friendName];
        [text appendString:@"   "];
        [text appendString:[NSString stringWithFormat:@"%.2f", fr.balanceInCircle.doubleValue]];
        [text appendString:@"\n"];
    }
    scroll.text = text;
    scroll.backgroundColor = [UIColor clearColor];
    [container addSubview:scroll];
    
    
    CGRect newFrame2 = CGRectMake(0, 100, 0, 0);
    newFrame2.size = CGSizeMake(screenWidth, screenHeight - 265);
    _tableView = [[UITableView alloc] initWithFrame:newFrame2 style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tag = 1000;
    _tableView.backgroundColor = [UIColor clearColor];
    
    [container addSubview:_tableView];
    
    CGRect newFrame4 = CGRectMake(screenWidth - 120, screenHeight - 155, 0, 0);
    newFrame4.size = CGSizeMake(70, 42);
    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    [okButton setFrame:newFrame4];
    [okButton addTarget:self
               action:@selector(addHistoryRecords:)
     forControlEvents:UIControlEventTouchDown];
    [okButton setTitle:@"OK" forState:UIControlStateNormal];
    [okButton actionsForTarget:okButton forControlEvent:UIControlEventTouchUpInside];

    [container addSubview:okButton];
    container.tag = 3003;
    return container;
}

-(UIView *) createView {
    UIView *viewToRemove = [self.view viewWithTag:3003];
    _tableView = nil;
    [[viewToRemove subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [viewToRemove removeFromSuperview];
    
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

- (void) reloadView{
    
    if (delegate.currentCircle != nil && delegate.currentCircle.name.length >0) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ (%d)", delegate.currentCircle.name, delegate.currentCircle.numberOfFriends.intValue];
        friends = [NSMutableArray new];
        tmp = [[NSMutableArray alloc] initWithArray:[connector getFriendsInCircle:delegate.currentCircle.name :delegate.currentCircle.ownerId]];
        for (Friend *f in tmp) {
            [friends addObject:[[CEFriendHelper alloc] initWithName:f.friendName]];
        }
        if (_tableView == nil) {
            [self.view addSubview:[self createTableView]];
        }
        [self reloadData:delegate.currentCircle];

    } else {
        [self.view addSubview:[self createView]];
        self.navigationItem.title = @"";
    }
}

- (void) reloadData: (CircleDefinition *)def {
    [_tableView reloadData];
    tmp = [connector getFriendsInCircle:def.name :def.ownerId];
    NSMutableString *text = [NSMutableString new];
    for (Friend *fr in tmp) {
        [text appendString:fr.friendName];
        [text appendString:@"   "];
        [text appendString:[NSString stringWithFormat:@"%.2f", fr.balanceInCircle.doubleValue]];
        [text appendString:@"\n"];
    }
    scroll.text = text;
}

- (void) receiveReloadNotification:(NSNotification *) notification {
    [self reloadView];
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
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;

    spinner.center = CGPointMake(screenWidth/2, screenHeight/2 - 35);
    spinner.color = [UIColor blackColor];
    [self.view addSubview:spinner];
    [spinner startAnimating];

    dispatch_queue_t workingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // it's not, so we will start a background process to calculate it and not block the UI
    dispatch_async(workingQueue,
                   ^{
                       
                       CESynchManager *syncMngr = [[CESynchManager alloc] init];
                       CERequestHandler *handler = [CERequestHandler new];
                       NSDictionary *res = [handler sendJsonRequest: [syncMngr syncAllUserData:delegate.currentUser.userId]:@"usrsync.php"];
                       NSDictionary *data = [res objectForKey:@"data"];
                       if ([data objectForKey:@"error"] == nil) {
                           NSArray *deleted = [data objectForKey:@"deleted"];
                           [connector removeDeletedCirclesForUser:deleted :delegate.currentUser.userId];
                           for (NSDictionary * dict in [data objectForKey:@"circles"]) {
                               [connector createCircleFromServer:[dict objectForKey:@"friends"] :[dict objectForKey:@"history"] :[NSNumber numberWithInt: [[dict objectForKey:@"ownerId"] intValue]] :[dict objectForKey:@"name"] :[NSNumber numberWithInt:[[dict objectForKey:@"id"] intValue]] :[NSNumber numberWithInt:[[dict objectForKey:@"lastRevision"] intValue]]];
                           }
                       }
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [spinner stopAnimating];
                           if ([data objectForKey:@"error"] != nil) {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account is not active"
                                                                               message:@"You have to activate your account first"
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil];
                               [alert show];
                           }
                           [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTableNotification" object:self];
                           [self reloadView];
                       });
                   });
    
}

- (IBAction)someAction:(id)sender {
    CEHistoryViewController *stats = [self.storyboard instantiateViewControllerWithIdentifier:@"history"];
    stats.definition = delegate.currentCircle;
    [self presentViewController:stats animated:YES completion:nil];
    
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
    static NSString *CellIdentifier = @"addDataCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    CEFriendHelper *fHelper = [friends objectAtIndex:indexPath.row];
    ((UILabel *)[cell viewWithTag:1010]).text = fHelper.userName;

    UITextField *amount = (UITextField *)[cell viewWithTag:1020];
    [amount setDelegate:self];
    [amount setInputAccessoryView:bar];
    [bar.fields insertObject:amount atIndex:indexPath.row];
    if (fHelper.amount != nil && fHelper.amount.length > 0) {
        amount.text = fHelper.amount;
    } else {
        amount.text = @"";
    }
    UITextField *dropDown = (UITextField *)[cell viewWithTag:1030];
    [dropDown setDelegate:self];
    
    if (fHelper.currency != nil && [fHelper.currency isEqualToString:@"Select"]) {
        dropDown.text = fHelper.currency;
    }
    
    cell.tag = 10000 + indexPath.row;
    
    return cell;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    UITableViewCell *cell = (UITableViewCell *) textField.superview.superview;
    CEFriendHelper *friend = [friends objectAtIndex:cell.tag - 10000];
    
    if (textField.tag == 1020) {
        friend.amount = textField.text;
    }
    friend.currency = ((UITextField *)[cell viewWithTag:1030]).text;
    
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    bar.field = textField;
}

-(IBAction) addHistoryRecords:(UIButton *) sender {
    [connector addHistoryRecords:friends :delegate.currentCircle.name :delegate.currentCircle.ownerId :delegate.currentUser.userId];
    [self reloadView];
}

@end
