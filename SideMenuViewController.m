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
    if (section == 0) {
        return @"Circles";
    } else {
        return @"--";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return circles.count + 1;
    if (section == 1) return 2;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == circles.count) {
            cell.textLabel.text = @"Add new";
        } else {
            CircleDefinition *c = [circles objectAtIndex:indexPath.row];
            cell.textLabel.text = c.name;
        }
    } else {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Settings";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Log out";
        }
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    if (indexPath.section == 0) {
        if (indexPath.row == circles.count) {
            UIViewController *home = [sb instantiateViewControllerWithIdentifier:@"addCircle"];
            UINavigationController *nav = ((CEHomeViewController *)[sb instantiateViewControllerWithIdentifier:@"home"]).navigationController;
            NSArray *controllers = [NSArray arrayWithObject:home];
            self.sideMenu.navigationController.viewControllers = controllers;
            [nav pushViewController:home animated:YES];
        } else {
            CircleDefinition *c = [circles objectAtIndex:indexPath.row];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:c.name forKey:@"circle"];

            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ReloadHomeViewNotification"
             object:self
             userInfo:userInfo];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            
        } else if (indexPath.row == 1) {
            delegate.currentUser = nil;
            
            UIViewController *home = [sb instantiateViewControllerWithIdentifier:@"CELogin"];
            UINavigationController *nav = ((CEHomeViewController *)[sb instantiateViewControllerWithIdentifier:@"home"]).navigationController;
            NSArray *controllers = [NSArray arrayWithObject:home];
            self.sideMenu.navigationController.viewControllers = controllers;
            [nav pushViewController:home animated:YES];

        }
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



@end
