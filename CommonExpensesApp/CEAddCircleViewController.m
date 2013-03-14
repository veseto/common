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
#import "KeyboardBar.h"

@interface CEAddCircleViewController ()

@end

@implementation CEAddCircleViewController
@synthesize name = _name;
@synthesize tableView = _tableView;

NSMutableArray *friends;
KeyboardBar *bar;

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
    bar = [KeyboardBar new];
    _friendName.inputAccessoryView = bar;
    _name.inputAccessoryView = bar;
    bar.fields = [[NSMutableArray alloc] initWithObjects:_name, _friendName, nil];
    bar.field = nil;
    bar.index = -1;
    friends = [[NSMutableArray alloc] init];
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
    return friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [friends objectAtIndex:indexPath.row];
    return cell;
}


- (IBAction)add:(id)sender {
    if (_friendName.text.length > 0) {
        [friends insertObject:_friendName.text atIndex:0];
        [_tableView reloadData];
    }
}

- (IBAction)createCircle:(id)sender {
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [bar setField:textField];
    bar.index = [bar.fields indexOfObject:textField];
}
@end
