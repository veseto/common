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
#import "LHDropDownControlView.h"
#import <QuartzCore/QuartzCore.h>
#define REFRESH_HEADER_HEIGHT 52.0f

@interface CEHomeViewController ()

@end

@implementation CEHomeViewController
@synthesize scrollViewContainer = _scrollViewContainer;
@synthesize textPull, textRelease, textLoading, refreshHeaderView, refreshLabel, refreshArrow, refreshSpinner;

CEAppDelegate *delegate;
NSArray *tmp;
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
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupStrings];
    [self addPullToRefreshHeader];
    
    self.navigationController.sideMenu.openMenuEnabled = YES;
    delegate = [[UIApplication sharedApplication] delegate];
    connector = [CEDBConnector new];
    [self setupMenuBarButtonItems];
    bar = [KeyboardBar new];
    
    //Add init with default circle
    
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
            {
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"hideKeyboardNotification"
                 object:weakSelf];
            }
                break;
            case MFSideMenuStateEventMenuDidClose:
                break;
        }
        
        [weakSelf setupMenuBarButtonItems];
    };
    [self createHomeView];
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
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
    if (delegate.currentCircle != nil) {
        self.navigationItem.rightBarButtonItem = [self rightMenuBarItem];
    }
    
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered
            target:self.navigationController.sideMenu
            action:@selector(toggleLeftSideMenu)];
}
- (UIBarButtonItem *)rightMenuBarItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(showHistoryView:)];
}


#pragma mark - end of view setup



#pragma mark - delegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField{
    //    UITableViewCell *cell = (UITableViewCell *) textField.superview.superview;
    //    CEFriendHelper *friend = [friends objectAtIndex:cell.tag - 10000];
    //
    //    if (textField.tag == 1020) {
    //        friend.amount = textField.text;
    //    }
    //    friend.currency = ((UITextField *)[cell viewWithTag:1030]).text;
    //
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    bar.field = textField;
}


#pragma mark - Drop Down Selector Delegate

- (void)dropDownControlViewWillBecomeActive:(LHDropDownControlView *)view  {
    self.navigationController.sideMenu.openMenuEnabled = NO;
    
    [self.scrollViewContainer setScrollEnabled:NO];
    [self.scrollViewContainer setUserInteractionEnabled:NO];
    for (UIView *v in view.superview.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            v.userInteractionEnabled = NO;
            [((UIScrollView *)v) setScrollEnabled:NO];
        }
    }
}

- (void)dropDownControlView:(LHDropDownControlView *)view didFinishWithSelection:(id)selection {
    self.navigationController.sideMenu.openMenuEnabled = YES;
    
    view.title = [NSString stringWithFormat:@"%@", selection ? : @"EUR"];
    [self.scrollViewContainer setScrollEnabled:YES];
    [self.scrollViewContainer setUserInteractionEnabled:YES];
    for (UIView *v in view.superview.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            v.userInteractionEnabled = YES;
            [((UIScrollView *)v) setScrollEnabled:YES];
        }
    }
}

#pragma mark - handle reload notifications
- (void) receiveReloadNotification:(NSNotification *) notification {
    if (notification.userInfo != nil) {
        [self.navigationController.sideMenu setMenuState:MFSideMenuStateClosed];
    }
    [self createHomeView];
}

-(void) showStatsView: (NSNotification *) notification {
    [self showStatView];
}

-(void) showStatView{
    UIViewController *stats = [self.storyboard instantiateViewControllerWithIdentifier:@"statistics"];
    [self.navigationController pushViewController:stats animated:YES];
    
}

#pragma action handling private methods

- (IBAction)sync:(id)sender {
    
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
                           [self stopLoading];
                           if ([data objectForKey:@"error"] != nil) {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account is not active"
                                                                               message:@"You have to activate your account first"
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil];
                               [alert show];
                           }
                           [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTableNotification" object:self];
                       });
                   });
    
}

- (IBAction)showHistoryView:(id)sender {
    CEHistoryViewController *stats = [self.storyboard instantiateViewControllerWithIdentifier:@"history"];
    self.navigationController.viewControllers = [[NSArray alloc] initWithObjects:stats, nil];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
}

-(IBAction) addHistoryRecords:(UIButton *) sender {
    NSMutableArray *friends = [NSMutableArray new];
    NSMutableString *text = [NSMutableString new];
    for (int i = 0; i < delegate.currentCircle.numberOfFriends.intValue; i ++) {
        UIScrollView *inputView = (UIScrollView *)[self.scrollViewContainer viewWithTag:1000];
        NSString *amount = ((UITextField *)[inputView viewWithTag:1200 + i]).text;
        NSString *name = ((UILabel *)[inputView viewWithTag:1100 + i]).text;
        NSString *currency = ((LHDropDownControlView *)[inputView viewWithTag:1300]).title;
        
        //        [text appendString:name];
        //        [text appendString:@"-"];
        //        [text appendString:amount.length > 0 ?@"0" :amount];
        //        [text appendString:currency];
        //        [text appendString:@" "];
        //
        if (amount.length > 0) {
            CEFriendHelper *h = [[CEFriendHelper alloc] initWithName:name];
            h.amount = amount;
            h.currency = currency;
            [friends addObject:h];
        }
    }
    [connector addHistoryRecords:friends :delegate.currentCircle.name :delegate.currentCircle.ownerId :delegate.currentUser.userId];
    self.lastTransactionInfo.text = text;
    [self createHomeView];
}

#pragma mark - create empty circle list view and circle view view

-(void) createHomeView {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    [[self.scrollViewContainer viewWithTag:1000].subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    for (UIView *view in self.scrollViewContainer.subviews) {
        if (view != refreshHeaderView) {
            [view removeFromSuperview];
        }
    }
    
    if (delegate.currentCircle != nil) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ (%d)", delegate.currentCircle.name, delegate.currentCircle.numberOfFriends.intValue];

        if (delegate.currentCircle.numberOfFriends.intValue > 1) {
            UIScrollView *inputView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, screenWidth, screenHeight - 220)];
            inputView.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
            NSMutableArray *tmp = [connector getFriendsInCircle:delegate.currentCircle.name: delegate.currentCircle.ownerId];
            NSMutableString *str = [[NSMutableString alloc] init];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button addTarget:self
                       action:@selector(addHistoryRecords:)
             forControlEvents:UIControlEventTouchDown];
            [button setTitle:@"+" forState:UIControlStateNormal];
            button.frame = CGRectMake(290, 20, 30, 30);
            [inputView addSubview:button];
            LHDropDownControlView *currency = [[LHDropDownControlView alloc] initWithFrame:CGRectMake(200, 20, 85, 35)];
            [currency setTitle:@"EUR"];
            NSArray *currencyArr = [[NSArray alloc] initWithObjects:@"EUR", @"BGN", @"USD", nil];
            [currency setSelectionOptions:currencyArr withTitles:currencyArr];
            currency.delegate = self;
            currency.tag = 1300;
            [inputView addSubview:currency];
            
            for (int i = 0; i < tmp.count; i ++) {
                Friend *f = [tmp objectAtIndex:i];
                
                [str appendString:f.friendName];
                [str appendString:@"  "];
                [str appendString:[NSString stringWithFormat:@"%0.2f BGN\n", f.balanceInCircle.doubleValue]];
                
                UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, i*30 + i*20 + 60, 80, 30)];
                nameLbl.text = f.friendName;
                nameLbl.tag = 1100 + i;
                [inputView addSubview:nameLbl];
                
                UITextField *amount = [[UITextField alloc] initWithFrame:CGRectMake(120, i*30 + i*20 + 60, 70, 30)];
                amount.borderStyle = UITextBorderStyleRoundedRect;
                amount.tag = 1200 + i;
                amount.delegate = self;
                [inputView addSubview:amount];
                
            }
            inputView.tag = 1000;
            [self.scrollViewContainer addSubview:inputView];
            
            scroll = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
            scroll.text = str;
            scroll.editable = NO;
            [self.scrollViewContainer addSubview:scroll];
        } else {
            UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 25)];
            l.text = @"You are the only one in circle";
            [self.scrollViewContainer addSubview:l];
        }
    } else {
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 25)];
        l.text = @"No selected circle";
        [self.scrollViewContainer addSubview:l];
    }
}

- (void)setupStrings{
    textPull = @"Pull down to refresh...";
    textRelease = @"Release to refresh...";
    textLoading = @"Loading...";
}

- (void)addPullToRefreshHeader {
    refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, REFRESH_HEADER_HEIGHT)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    refreshArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 27) / 2),
                                    (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                    27, 44);
    
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [refreshHeaderView addSubview:refreshSpinner];
    [self.scrollViewContainer addSubview:refreshHeaderView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            self.scrollViewContainer.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            self.scrollViewContainer.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView animateWithDuration:0.25 animations:^{
            if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                refreshLabel.text = self.textRelease;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else {
                // User is scrolling somewhere within the header
                refreshLabel.text = self.textPull;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
        }];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
}

- (void)startLoading {
    isLoading = YES;
    
    // Show the header
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollViewContainer.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        refreshLabel.text = self.textLoading;
        refreshArrow.hidden = YES;
        [refreshSpinner startAnimating];
    }];
    
    // Refresh action!
    [self refresh];
}

- (void)stopLoading {
    isLoading = NO;
    
    // Hide the header
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollViewContainer.contentInset = UIEdgeInsetsZero;
        [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(stopLoadingComplete)];
                     }];
}

- (void)stopLoadingComplete {
    // Reset the header
    refreshLabel.text = self.textPull;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
}

- (void)refresh {
    // This is just a demo. Override this method with your custom reload action.
    // Don't forget to call stopLoading at the end.
    [self performSelector:@selector(sync:) withObject:nil afterDelay:2.0];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
