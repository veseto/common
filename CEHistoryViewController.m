//
//  CEHistoryViewController.m
//  CommonExpensesApp
//
//  Created by veseto on 01.04.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CEHistoryViewController.h"
#import "CEDBConnector.h"
#import "CEAppDelegate.h"
#import "HistoryRecord.h"

@interface CEHistoryViewController ()

@end

@implementation CEHistoryViewController
@synthesize tableView = _tableView;
@synthesize sideMenu = _sideMenu;

NSArray *history;
CEDBConnector *connector;
CEAppDelegate *delegate;

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
    connector = [CEDBConnector new];
    delegate = [[UIApplication sharedApplication] delegate];
    history = [[NSArray alloc] initWithArray:[connector getHistoryRecords:delegate.currentCircle.name :delegate.currentCircle.ownerId]];

    self.navigationController.sideMenu.openMenuEnabled = YES;
    self.navigationItem.title = delegate.currentCircle.name;
    [self setupMenuBarButtonItems];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return history.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HistoryCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    HistoryRecord *record = [history objectAtIndex:history.count - indexPath.row - 1];
    UILabel *nameLbl = (UILabel *)[cell viewWithTag:2010];
    nameLbl.text = record.user;
    UILabel *amountLbl = (UILabel *)[cell viewWithTag:2020];
    amountLbl.text = [NSString stringWithFormat:@"%.2f", record.sum.doubleValue];
    UILabel *currencyLbl = (UILabel *)[cell viewWithTag:2030];
    currencyLbl.text = record.currency;
    return cell;
}

@end
