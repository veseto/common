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
BOOL newRow;
int count;

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
    newRow = NO;
    [super viewDidLoad];
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
            return 1;
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
        case 0:
            cell.textLabel.text = delegate.currentUser.userName;
            break;
        case 1:
            if (newRow) {
                if (indexPath.row == 0) {
                    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"addDataCell" owner:self options:nil];
                    cell = [topLevelObjects objectAtIndex:0];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    UITextField *name = (UITextField *)[cell viewWithTag:3100];
                    name.delegate = self;
                    [name becomeFirstResponder];
                    UIButton *ok = (UIButton *)[cell viewWithTag:3200];
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
                UIViewController *settings = [sb instantiateViewControllerWithIdentifier:@"settings"];
                self.sideMenu.navigationController.viewControllers = [[NSArray alloc] initWithObjects:settings
                                                                      , nil];
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
            [self.sideMenu setMenuState:MFSideMenuStateClosed];
            break;
        default:
            break;
    }
}

#pragma mark - UISearchBarDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    CircleDefinition *d = [circles objectAtIndex:indexPath.row];
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
    if (indexPath.section == 1) return YES;
    return NO;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, screenWidth, 44)]; // x,y,width,height
        
        UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        reportButton.frame = CGRectMake(screenWidth - 100, 0, 30, 30); // x,y,width,height
        [reportButton setTitle:@"+" forState:UIControlStateNormal];
        [reportButton addTarget:self
                         action:@selector(addCircle)
               forControlEvents:UIControlEventTouchDown];
        
        [headerView addSubview:reportButton];
        return headerView;
    }
    return [[UIView alloc] init];
}


-(void) addCircle {
    newRow = YES;
    count += 1;
    [self.tableView beginUpdates];
    NSIndexPath *row1 = [NSIndexPath indexPathForRow:0 inSection:1];
    //you may add as many row as you want here.
    
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:row1,nil] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    
    
    //shouldHideRow = NO;
    //[self.tableView reloadData];
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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadHomeViewNotification" object:self];
    } else {
        [self cancelAdd];
    }
}

-(void) cancelAdd {
    newRow = NO;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    [((UITextField *)[cell viewWithTag:3100]) resignFirstResponder];
    [self.tableView beginUpdates];
    count -=1;
    NSIndexPath *row1 = [NSIndexPath indexPathForRow:0 inSection:1];
    
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:row1,nil] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
    
}
@end
