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
#import "CEDBConnector.h"
#import "CEAppDelegate.h"
#import "CEUser.h"

@interface CEAddCircleViewController ()

@end

@implementation CEAddCircleViewController
@synthesize friendName = _friendName;
@synthesize tableView = _tableView;
@synthesize friendNameLbl = _friendNameLbl;
@synthesize plusButton = _plusButton;
@synthesize circleNameLbl = _circleNameLbl;

NSMutableArray *friends;
CEAppDelegate *delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    delegate =[[UIApplication sharedApplication] delegate];
    friends = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
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
        if ([friends indexOfObject:_friendName.text] != NSNotFound) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate names"
                                                            message:[NSString stringWithFormat:@"There is already friend with name %@ in the circle", _friendName.text]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else if ([_friendName.text isEqualToString:delegate.currentUser.userName]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Duplicate names"
                                                           message:@"You cannot add yourself as friend"
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
            [alert show];
            
        } else {
            [friends insertObject:_friendName.text atIndex:0];
            [_tableView reloadData];
            _friendName.text = @"";
            [_friendName becomeFirstResponder];
        }
    }
}

- (IBAction)createCircle:(id)sender {
    
    if (friends.count < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No friends"
                                                        message:@"You have to add friends"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    } else {
        CEUser *user = delegate.currentUser;
        CEDBConnector *connector = [CEDBConnector new];
        
        [connector updateCircle:friends :user.userId :delegate.currentCircle.name];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadHomeViewNotification" object:self userInfo:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end
