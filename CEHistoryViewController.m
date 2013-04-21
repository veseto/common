//
//  CEHistoryViewController.m
//  CommonExpensesApp
//
//  Created by veseto on 01.04.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CEHistoryViewController.h"
#import "CEDBConnector.h"
#import "HistoryRecord.h"

@interface CEHistoryViewController ()

@end

@implementation CEHistoryViewController
@synthesize definition = _definition;
@synthesize tableView = _tableView;

NSArray *history;
CEDBConnector *connector;

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
    history = [[NSArray alloc] initWithArray:[connector getHistoryRecords:_definition.name :_definition.ownerId]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    history = [[NSArray alloc] initWithArray:[connector getHistoryRecords:_definition.name :_definition.ownerId]];
    [_tableView reloadData];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeHistoryView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    HistoryRecord *record = [history objectAtIndex:indexPath.row];
    UILabel *nameLbl = (UILabel *)[cell viewWithTag:2010];
    nameLbl.text = record.user;
    UILabel *amountLbl = (UILabel *)[cell viewWithTag:2020];
    amountLbl.text = [NSString stringWithFormat:@"%.2f", record.sum.doubleValue];
    UILabel *currencyLbl = (UILabel *)[cell viewWithTag:2030];
    currencyLbl.text = record.currency;
    return cell;
}

@end
