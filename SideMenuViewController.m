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
#import "CESearchViewController.h"

@implementation SideMenuViewController

@synthesize sideMenu;

UITableView *tableView;
CEAppDelegate *delegate;
NSMutableArray *circles;
CEDBConnector *connector;
CESearchViewController *resListView;
BOOL newRow, search;
int count;

- (id) init {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveReloadNotification:)
                                                 name:@"ReloadTableNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideKeyboard:)
                                                 name:@"hideKeyboardNotification"
                                               object:nil];
    return [self initWithStyle:UITableViewStyleGrouped];
}

-(void)receiveReloadNotification:(NSNotification *)reloadNotification {
    circles = [[NSMutableArray alloc] initWithArray:[connector getCirclesForUser:delegate.currentUser.userId]];
    if (!circles) {
        circles = [[NSMutableArray alloc] init];
    }
    count = circles.count;
    [tableView reloadData];
}

-(void)hideKeyboard:(NSNotification *)hideKeyboardNotification {
    [self cancelAdd];
    if (search) {
        [self toggleSearch];
    }
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    newRow = NO;
    search = NO;
    tableView = self.tableView;
    delegate = [[UIApplication sharedApplication] delegate];
    connector = [CEDBConnector new];
    circles = [[NSMutableArray alloc] initWithArray:[connector getCirclesForUser:delegate.currentUser.userId]];
    count = circles.count;
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
            return search?2:1;
        case 1:
            return count;
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
        case 0: {
            if (indexPath.row == 0) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"profileCell" owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                UIButton *settings = (UIButton *)[cell viewWithTag:4100];
                UIButton *search = (UIButton *)[cell viewWithTag:4300];
                [search addTarget:self action:@selector(toggleSearch) forControlEvents:UIControlEventTouchUpInside];

                [settings addTarget:self action:@selector(openSettingsView) forControlEvents:UIControlEventTouchUpInside];
            } else if (indexPath.row == 1) {
                if (search) {
                    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"searchCell" owner:self options:nil];
                    cell = [topLevelObjects objectAtIndex:0];
                    UISearchBar *searchBar = (UISearchBar *)[cell viewWithTag:5000];
                    searchBar.delegate = self;
                }
            }
            
        }
            break;
        case 1:
            if (newRow) {
                if (indexPath.row == 0) {
                    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"addDataCell" owner:self options:nil];
                    cell = [topLevelObjects objectAtIndex:0];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    UITextField *name = (UITextField *)[cell viewWithTag:3100];
                    name.delegate = self;
                    [name addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
                    [name becomeFirstResponder];
                    UIButton *ok = (UIButton *)[cell viewWithTag:3200];
                    [ok setEnabled:(name.text.length > 0)];
                    [ok setHidden:(name.text.length < 1)];
                    [ok addTarget:self action:@selector(saveCircleInDB) forControlEvents:UIControlEventTouchUpInside];
                    [((UIButton *)[cell viewWithTag:3300]) addTarget:self action:@selector(cancelAdd) forControlEvents:UIControlEventTouchUpInside];
                } else {
                    CircleDefinition *c = [circles objectAtIndex:indexPath.row + 1];
                    cell.textLabel.text = c.name;
                }
            } else {
                CircleDefinition *c = [circles objectAtIndex:indexPath.row];
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
    
    if (newRow) {
        [self cancelAdd];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0){
                UIViewController *stats = [sb instantiateViewControllerWithIdentifier:@"statistics"];
                self.sideMenu.navigationController.viewControllers = [[NSArray alloc] initWithObjects:stats, nil];
                [self.sideMenu.navigationController popToRootViewControllerAnimated:NO];
            }
            [self.sideMenu setMenuState:MFSideMenuStateClosed];
            break;
        case 1:
        {
            CircleDefinition *c = [circles objectAtIndex:indexPath.row];
            delegate.currentCircle = c;
            UIViewController *stats = [sb instantiateViewControllerWithIdentifier:@"home"];
            self.sideMenu.navigationController.viewControllers = [[NSArray alloc] initWithObjects:stats, nil];
            [self.sideMenu.navigationController popToRootViewControllerAnimated:NO];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ReloadHomeViewNotification"
             object:self];
            [self.sideMenu setMenuState:MFSideMenuStateClosed];
        }
            break;
        case 2:
            if (indexPath.row == 0) {
            } else if (indexPath.row == 1) {
                delegate.currentUser = nil;
                self.sideMenu.openMenuEnabled = NO;
                UIViewController *home = [sb instantiateViewControllerWithIdentifier:@"CELogin"];
                UINavigationController *nav = ((CEHomeViewController *)[sb instantiateViewControllerWithIdentifier:@"home"]).navigationController;
                NSArray *controllers = [NSArray arrayWithObject:home];
                self.sideMenu.navigationController.viewControllers = controllers;
                [nav pushViewController:home animated:YES];
                
            }
            [self.sideMenu setMenuState:MFSideMenuStateClosed];
            break;
        default:
            break;
    }
}

#pragma mark - UISearchBarDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    if (newRow) {
        [self cancelAdd];
        row -= 1;
    }
    CircleDefinition *d = [circles objectAtIndex:row];
    if (d.circleId != nil) {
        [connector addDeletedCircle:d.circleId :delegate.currentUser.userId];
    }
    [connector deleteCircle:d.name :delegate.currentUser.userId];
    count -= 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTableNotification" object:self];
    
    if (circles.count > 0) {
        CircleDefinition *c = [circles objectAtIndex:0];
        delegate.currentCircle = c;
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ReloadHomeViewNotification"
     object:self
     userInfo:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (newRow && indexPath.row == 0) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, screenWidth, 44)]; // x,y,width,height
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 40)];
    lbl.backgroundColor =[UIColor clearColor];
    switch (section) {
        case 0: {
            return nil;
        }
        case 1: {
            lbl.text = @"Circles";
            UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            reportButton.frame = CGRectMake(screenWidth - 100, 0, 30, 30); // x,y,width,height
            [reportButton setTitle:@"+" forState:UIControlStateNormal];
            [reportButton addTarget:self
                             action:@selector(addCircle)
                   forControlEvents:UIControlEventTouchDown];
            
            [headerView addSubview:reportButton];
        }
            break;
        case 2:
            lbl.text = @"---";
            break;
        default:
            break;
    }
    [headerView addSubview:lbl];
    return headerView;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)path
{
    if ((path.section == 1 && path.row == 0 && newRow) || (path.section == 0 && path.row == 1)){
        return nil;
    }
    
    return path;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) return 80;
    return 44.0;
}

-(void) addCircle {
    newRow = YES;
    count += 1;
    [self.tableView beginUpdates];
    NSIndexPath *row1 = [NSIndexPath indexPathForRow:0 inSection:1];
    
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:row1,nil] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self saveCircleInDB];
    return YES;
}

-(void) saveCircleInDB {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    UITextField *name = (UITextField *)[cell viewWithTag:3100];
    [name resignFirstResponder];
    if (name.text.length > 0) {
        if ([connector circleExistsForUser:name.text :((CEAppDelegate *)[[UIApplication sharedApplication] delegate]).currentUser.userId]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Circle exists"
                                                            message:[NSString stringWithFormat:@"Circle with name %@ already exists", name.text]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [name becomeFirstResponder];
        } else {
            CEUser *user = delegate.currentUser;
            NSArray *friends = [[NSArray alloc] initWithObjects:user.userName, nil];
            CEDBConnector *connector = [CEDBConnector new];
            delegate.currentCircle = [connector createCircle:friends :user.userId :name.text :nil];
            newRow = NO;
            
            [self.tableView beginUpdates];
            count -=1;
            NSIndexPath *row1 = [NSIndexPath indexPathForRow:0 inSection:1];
            
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:row1,nil] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            circles = [[NSMutableArray alloc] initWithArray:[connector getCirclesForUser:delegate.currentUser.userId]];
            count = circles.count;
            [tableView reloadData];
            
        }
    } else {
        [self cancelAdd];
    }
}

-(void) cancelAdd {
    if (newRow) {
        newRow = NO;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        [((UITextField *)[cell viewWithTag:3100]) resignFirstResponder];
        [self.tableView beginUpdates];
        count -=1;
        NSIndexPath *row1 = [NSIndexPath indexPathForRow:0 inSection:1];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:row1,nil] withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView endUpdates];
    }
}
-(void) textFieldDidChange {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    UITextField *name = (UITextField *)[cell viewWithTag:3100];
    
    [(UIButton *)[cell viewWithTag:3200] setEnabled:(name.text.length > 0)];
    [(UIButton *)[cell viewWithTag:3200] setHidden:(name.text.length < 1)];
    
}

-(void) openSettingsView {
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    
    UIViewController *settings = [sb instantiateViewControllerWithIdentifier:@"settings"];
    self.sideMenu.navigationController.viewControllers = [[NSArray alloc] initWithObjects:settings
                                                          , nil];
    [self.sideMenu.navigationController popToRootViewControllerAnimated:NO];
    [self.sideMenu setMenuState:MFSideMenuStateClosed];
    
    
}

-(void) toggleSearch {
    if (search) {
        search = !search;
        [self.tableView beginUpdates];
        NSIndexPath *row1 = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:row1,nil] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    } else {
        search = !search;
        [self.tableView beginUpdates];
        NSIndexPath *row1 = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:row1,nil] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];
    }
}

-(BOOL) searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    resListView = [[CESearchViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.view addSubview:resListView.tableView];
    [self.view bringSubviewToFront:resListView.tableView];
    return YES;
}

-(BOOL) searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [resListView.tableView removeFromSuperview];
    return YES;
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self.sideMenu setMenuState:MFSideMenuStateLeftMenuOpen];

    [self toggleSearch];
}
@end
