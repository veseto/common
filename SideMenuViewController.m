//
//  SideMenuViewController.m
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "CEAppDelegate.h"
#import "CEHomeViewController.h"
#import "CEDBConnector.h"
#import "CircleDefinition.h"

@implementation SideMenuViewController

@synthesize sideMenu;

UITableView *tableView;
CEAppDelegate *delegate;
NSMutableArray *circles;
CEDBConnector *connector;

- (id) init {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveReloadNotification:)
                                                 name:@"ReloadTableNotification"
                                               object:nil];
    return [self initWithStyle:UITableViewStyleGrouped];
}

-(void)receiveReloadNotification:(NSNotification *)reloadNotification {
    circles = [[NSMutableArray alloc] initWithArray:[connector getCirclesForUser:delegate.currentUser.userId]];
    if (!circles) {
        circles = [[NSMutableArray alloc] init];
    }
    [tableView reloadData];
}
- (void) viewDidLoad {
    [super viewDidLoad];
    tableView = self.tableView;
    delegate = [[UIApplication sharedApplication] delegate];
    connector = [CEDBConnector new];
    circles = [[NSMutableArray alloc] initWithArray:[connector getCirclesForUser:delegate.currentUser.userId]];
    if (!circles) {
        circles = [[NSMutableArray alloc] init];
    }
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"";
        case 1:
            return @"Circles";
        default:
            return @"--";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
        case 1:
            return circles.count + 1;
        case 2:
            return 2;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = delegate.currentUser.userName;
            // [cell setBackgroundColor:[UIColor clearColor]];
            // [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            // [cell setUserInteractionEnabled:NO];
            break;
        case 1:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Add Circle";
            } else {
                CircleDefinition *c = [circles objectAtIndex:indexPath.row - 1];
                cell.textLabel.text = c.name;
            }
            break;
        case 2:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Settings";
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"Log out";
            }
            break;
        default:
            break;
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0){
                UIViewController *stats = [sb instantiateViewControllerWithIdentifier:@"statistics"];
                self.sideMenu.navigationController.viewControllers = [[NSArray alloc] initWithObjects:stats, nil];
                [self.sideMenu.navigationController popToRootViewControllerAnimated:NO];
            }
            break;
        case 1:
            if (indexPath.row == 0) {
                UIViewController *home = [sb instantiateViewControllerWithIdentifier:@"addCircle"];
                [self.sideMenu.navigationController presentViewController:home animated:YES completion:nil];
            } else {
                CircleDefinition *c = [circles objectAtIndex:indexPath.row - 1];
                delegate.currentCircle = c;
                UIViewController *stats = [sb instantiateViewControllerWithIdentifier:@"home"];
                self.sideMenu.navigationController.viewControllers = [[NSArray alloc] initWithObjects:stats, nil];
                [self.sideMenu.navigationController popToRootViewControllerAnimated:NO];

                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"ReloadHomeViewNotification"
                 object:self];
            }
            break;
        case 2:
            if (indexPath.row == 0) {
                UIViewController *settings = [sb instantiateViewControllerWithIdentifier:@"settings"];
                self.sideMenu.navigationController.viewControllers = [[NSArray alloc] initWithObjects:settings, nil];
                [self.sideMenu.navigationController popToRootViewControllerAnimated:NO];
            } else if (indexPath.row == 1) {
                delegate.currentUser = nil;
                self.sideMenu.openMenuEnabled = NO;
                UIViewController *home = [sb instantiateViewControllerWithIdentifier:@"CELogin"];
                UINavigationController *nav = ((CEHomeViewController *)[sb instantiateViewControllerWithIdentifier:@"home"]).navigationController;
                NSArray *controllers = [NSArray arrayWithObject:home];
                self.sideMenu.navigationController.viewControllers = controllers;
                [nav pushViewController:home animated:YES];
                
            }
            break;
        default:
            break;
    }
    [self.sideMenu setMenuState:MFSideMenuStateClosed];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    CircleDefinition *d = [circles objectAtIndex:indexPath.row - 1];
    if (d.circleId != nil) {
        [connector addDeletedCircle:d.circleId :delegate.currentUser.userId];
    }
    [connector deleteCircle:d.name :delegate.currentUser.userId];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTableNotification" object:self];
    
    if (circles.count > 0) {
        CircleDefinition *c = [circles objectAtIndex:0];
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:c forKey:@"circle"];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ReloadHomeViewNotification"
         object:self
         userInfo:userInfo];
    } else {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ReloadHomeViewNotification"
         object:self
         userInfo:nil];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row > 0) return YES;
    return NO;
}


@end
