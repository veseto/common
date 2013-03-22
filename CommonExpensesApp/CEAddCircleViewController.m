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
@synthesize name = _name;
@synthesize friendName = _friendName;
@synthesize tableView = _tableView;
@synthesize friendNameLbl = _friendNameLbl;
@synthesize plusButton = _plusButton;
@synthesize okButton = _okButton;
@synthesize circleNameLbl = _circleNameLbl;

NSMutableArray *friends;
KeyboardBar *bar;
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
    bar = [KeyboardBar new];
    delegate =[[UIApplication sharedApplication] delegate];
    _friendName.inputAccessoryView = bar;
    _name.inputAccessoryView = bar;
    bar.fields = [[NSMutableArray alloc] initWithObjects:_name, nil];
    bar.field = _name;
    bar.index = 0;
    [_name becomeFirstResponder];
    friends = [[NSMutableArray alloc] init];
    self.navigationItem.title = @"Create new circle";
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Back"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = flipButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) cancel {
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController *home = [sb instantiateViewControllerWithIdentifier:@"home"];
    [self.navigationController pushViewController:home animated:YES];
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
        CEUser *user = ((CEAppDelegate *)[[UIApplication sharedApplication] delegate]).currentUser;
        [friends insertObject:user.userName atIndex:0];
         NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:_name.text forKey:@"circle"];
        [dict setObject:[NSNumber numberWithInt:friends.count] forKey:@"numberOfFriends"];
        CEDBConnector *connector = [CEDBConnector new];
        [connector createCircle:friends :user.userId :_name.text :nil];
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        UIViewController *home = [sb instantiateViewControllerWithIdentifier:@"home"];
        [self.navigationController pushViewController:home animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTableNotification" object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadHomeViewNotification" object:self userInfo:dict];
    }
    
}

- (IBAction)submitName:(id)sender {
    if (_name.text.length > 0) {
        [_circleNameLbl setEnabled:NO];
        [_name setEnabled:NO];
        [_okButton setEnabled:NO];
        [_friendNameLbl setHidden:NO];
        [_friendName setHidden:NO];
        [_friendName setUserInteractionEnabled:YES];
        [_plusButton setHidden:NO];
        [_plusButton setUserInteractionEnabled:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty name"
                                                        message:@"You have to provide circle name"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [bar setField:textField];
    bar.index = [bar.fields indexOfObject:textField];
}
@end
