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
#import <QuartzCore/QuartzCore.h>

@implementation SideMenuViewController

@synthesize sideMenu = _sideMenu;
@synthesize search;
@synthesize tap;

UITableView *tableView;
CEAppDelegate *delegate;
NSMutableArray *circles;
CEDBConnector *connector;
CESearchViewController *resListView;
BOOL newRow;
int count;
CGRect screenRect;
UIButton *btn, *ok;


- (id) init {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveReloadNotification:)
                                                 name:@"ReloadTableNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideKeyboard:)
                                                 name:@"hideKeyboardNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disableTouch:)
                                                 name:@"disableTouchNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enableTouch:)
                                                 name:@"enableTouchNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showHistoryView:)
                                                 name:@"ShowHistoryViewNotification"
                                               object:nil];

    return [self initWithStyle:UITableViewStylePlain];
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

-(void)enableTouch:(NSNotification *)enableTouchNotification {
    [self.tableView setUserInteractionEnabled:YES];
    
}
-(void)disableTouch:(NSNotification *)disableTouchNotification {
    [self.tableView setUserInteractionEnabled:NO];
    [self.tableView setEditing:NO animated:NO];
    
}

-(void)showHistoryView:(NSNotification *)showHistoryViewNotification {
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController *stats = [sb instantiateViewControllerWithIdentifier:@"history"];
    _sideMenu.navigationController.viewControllers = [[NSArray alloc] initWithObjects:stats, nil];
    [_sideMenu.navigationController popToRootViewControllerAnimated:YES];
    [_sideMenu setMenuState:MFSideMenuStateClosed];
    
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    screenRect = [[UIScreen mainScreen] bounds];
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
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(hideKeyboard:)];
    tap.delegate = self;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithRed:(242.0f/255.0f) green:(240.0f/255.0f) blue:(223.0f/255.0f) alpha:1.0f];
    self.tableView.separatorColor = [UIColor colorWithRed:(202.0f/255.0f) green:(204.0f/255.0f) blue:(182.0f/255.0f) alpha:1.0f];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //96,120,144
    
    
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
            return 1;
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
                UITableViewCell *cell1 = [topLevelObjects objectAtIndex:0];
                [cell1.contentView setBackgroundColor:[UIColor colorWithRed:(96.0f/255.0f) green:(120.0f/255.0f) blue:(144.0f/255.0f) alpha:1.0f]];
                [cell1 setSelectionStyle:UITableViewCellSelectionStyleNone];
                UIButton *settings = (UIButton *)[cell1 viewWithTag:4100];
                UIButton *searchBtn = (UIButton *)[cell1 viewWithTag:4300];
                [searchBtn addTarget:self action:@selector(toggleSearch) forControlEvents:UIControlEventTouchUpInside];
                
                [settings addTarget:self action:@selector(openSettingsView) forControlEvents:UIControlEventTouchUpInside];
                UIButton *profilePic = (UIButton *)[cell1 viewWithTag:4400];
                [profilePic addTarget:self action:@selector(openStatsView) forControlEvents:UIControlEventTouchUpInside];

                return cell1;
            } else if (indexPath.row == 1) {
                if (search) {
                    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"searchCell" owner:self options:nil];
                    cell = [topLevelObjects objectAtIndex:0];
                    cell.contentView.frame = CGRectMake(0, 0, 44, 340);
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
                    ok = (UIButton *)[cell viewWithTag:3200];
                    [ok setEnabled:(name.text.length > 0)];
                    [ok setHidden:(name.text.length < 1)];
                    [ok.layer setCornerRadius:3.0f];

                    [ok addTarget:self action:@selector(saveCircleInDB) forControlEvents:UIControlEventTouchDown];
                    
                } else {
                    CircleDefinition *c = [circles objectAtIndex:indexPath.row - 1];
                    cell.textLabel.text = c.name;
                    cell.imageView.image = [UIImage imageNamed:@"icon_180green.png"];
                    //                    [cell setBorderStyle:UITextBorderStyleNone];
                    [cell setBackgroundColor:[UIColor clearColor]];
                    [cell.textLabel setTextColor:[UIColor colorWithRed:(72.0f/255.0f) green:(66.0f/255.0f) blue:(61.0f/255.0f) alpha:1.0f]];
                    [cell.textLabel setFont:([UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0])];
                    [cell setAlpha:1.0f];
                    
                }
            } else {
                CircleDefinition *c = [circles objectAtIndex:indexPath.row];
                cell.textLabel.text = c.name;
                cell.imageView.image = [UIImage imageNamed:@"icon_180green.png"];
                //                    [cell setBorderStyle:UITextBorderStyleNone];
                [cell setBackgroundColor:[UIColor clearColor]];
                [cell.textLabel setTextColor:[UIColor colorWithRed:(72.0f/255.0f) green:(66.0f/255.0f) blue:(61.0f/255.0f) alpha:1.0f]];
                [cell.textLabel setFont:([UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0])];
                [cell setAlpha:1.0f];
                
            }
            break;
        case 2:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Log out";
                cell.imageView.image = [UIImage imageNamed:@"icon_237.png"];
                [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0]];
                [cell.textLabel setTextColor:[UIColor colorWithRed:(186.0f/255.0f) green:(42.0f/255.0f) blue:(41.0f/255.0f) alpha:1.0f]];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            break;
        default:
            break;
    }
    if (search) {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    cell.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
    if (indexPath.section == 1 && indexPath.row < count) {
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 39, screenRect.size.width, 1)];
        line.backgroundColor = [UIColor colorWithRed:(202/255.0f) green:(204/255.0f) blue:(182/255.0f) alpha:1.0f];
        //202,204,182
        [cell addSubview:line];
        UIImageView *line2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 1)];
        line2.backgroundColor = [UIColor clearColor];
        [cell addSubview:line2];
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
            break;
        case 1:
        {
            CircleDefinition *c = [circles objectAtIndex:indexPath.row];
            delegate.currentCircle = c;
            UIViewController *stats = [sb instantiateViewControllerWithIdentifier:@"home"];
            _sideMenu.navigationController.viewControllers = [[NSArray alloc] initWithObjects:stats, nil];
            [_sideMenu.navigationController popToRootViewControllerAnimated:NO];
            [_sideMenu setMenuState:MFSideMenuStateClosed];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadHomeViewNotification" object:self userInfo:nil];
        }
            break;
        case 2:
            break;
        default:
            break;
    }
}

-(void) logout {
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    delegate.currentUser = nil;
    [connector removeDefaultUser];
    _sideMenu.openMenuEnabled = NO;
    UIViewController *home = [sb instantiateViewControllerWithIdentifier:@"CELogin"];
    UINavigationController *nav = ((CEHomeViewController *)[sb instantiateViewControllerWithIdentifier:@"home"]).navigationController;
    NSArray *controllers = [NSArray arrayWithObject:home];
    _sideMenu.navigationController.viewControllers = controllers;
    [nav pushViewController:home animated:YES];
    [_sideMenu setMenuState:MFSideMenuStateClosed];
    
    
}

#pragma mark - UISearchBarDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    //    if (newRow) {
    //        [self cancelAdd];
    //        row -= 1;
    //    }
    //    if (search) {
    //        [self toggleSearch];
    //    }
    if (indexPath.section == 1) {
        CircleDefinition *d = [circles objectAtIndex:row];
        if (delegate.currentCircle == d) {
            delegate.currentCircle = nil;
        }
        if (d.circleId != nil) {
            [connector addDeletedCircle:d.circleId :delegate.currentUser.userId];
        }
        [connector deleteCircle:d.name :delegate.currentUser.userId];
        count -= 1;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTableNotification" object:self];
        
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ReloadHomeViewNotification"
         object:self
         userInfo:nil];
    } else if (indexPath.section == 2) {
        [self logout];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (search || newRow) return NO;
    if (indexPath.section == 1) {
        if (newRow && indexPath.row == 0) {
            return NO;
        } else {
            return YES;
        }
    }
    if (indexPath.section == 2) return YES;
    return NO;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat screenWidth = screenRect.size.width;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, screenWidth, 30)]; // x,y,width,height
    headerView.bounds = CGRectInset(headerView.frame,0.0f,4.0f);
    [headerView setBackgroundColor:[UIColor colorWithRed:(202/255.0f) green:(204/255.0f) blue:(182/255.0f) alpha:1.0f]];
    [headerView setAutoresizesSubviews:YES];
    [headerView setClipsToBounds:YES];
    //142,158,130
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 100, headerView.frame.size.height)];
    [lbl setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0]];
    [lbl setTextColor:[UIColor colorWithRed:(72.0f/255.0f) green:(66.0f/255.0f) blue:(61.0f/255.0f) alpha:1.0f]];
    lbl.backgroundColor =[UIColor clearColor];
    switch (section) {
        case 0: {
            return nil;
        }
        case 1: {
            lbl.text = @"CIRCLES";
            btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.frame = CGRectMake(screenWidth - 78, 0, 32, 32); // x,y,width,height
            if (newRow) {
                [btn setBackgroundImage:[UIImage imageNamed:@"icon_223.png"] forState:UIControlStateNormal];
            } else {
                [btn setBackgroundImage:[UIImage imageNamed:@"icon_222.png"] forState:UIControlStateNormal];
            }
            [btn addTarget:self
                    action:@selector(toggleCircleAdd)
          forControlEvents:UIControlEventTouchDown];
            
            [headerView addSubview:btn];
        }
            break;
        case 2:
            lbl.text = @"";
            break;
        default:
            break;
    }
    [headerView addSubview:lbl];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return 0;
    return 24;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)path
{
    if ((search) || (path.section == 1 && path.row == 0 && newRow) || (path.section == 0 && path.row == 1)){
        return nil;
    }
    
    return path;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) return 100;
    if (search && indexPath.section == 0 && indexPath.row == 1) return 44;
    return 40;
}

-(IBAction) toggleCircleAdd{
    if (search) {
        [self toggleSearch];
    }
    if (!newRow) {
        [self.view addGestureRecognizer:tap];
        newRow = YES;
        count += 1;

        [self.tableView beginUpdates];        
        NSIndexPath *row1 = [NSIndexPath indexPathForRow:0 inSection:1];
        
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:row1,nil] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];

    } else {
        [self cancelAdd];
    }
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
            CEDBConnector *connector = [CEDBConnector new];
            delegate.currentCircle = [connector createCircle :user :name.text];
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
        [self.view removeGestureRecognizer:tap];
        newRow = NO;
        btn.titleLabel.text = @"+";
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
    _sideMenu.navigationController.viewControllers = [[NSArray alloc] initWithObjects:settings
                                                          , nil];
    [_sideMenu.navigationController popToRootViewControllerAnimated:NO];
    [_sideMenu setMenuState:MFSideMenuStateClosed];
    
    
}

-(void) openStatsView {
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController *stats = [sb instantiateViewControllerWithIdentifier:@"statistics"];
    _sideMenu.navigationController.viewControllers = [[NSArray alloc] initWithObjects:stats, nil];
    [_sideMenu.navigationController popToRootViewControllerAnimated:NO];
    [_sideMenu setMenuState:MFSideMenuStateClosed];
    
    
}

-(void) toggleSearch {
    if (newRow) {
        [self toggleCircleAdd];
    }
    if (search) {
        [self.view removeGestureRecognizer:tap];
        search = !search;
        [self.tableView beginUpdates];
        NSIndexPath *row1 = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:row1,nil] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        [[self.view viewWithTag:10100] removeFromSuperview];
    } else {
        search = !search;
        [self.view addGestureRecognizer:tap];
        [self.tableView beginUpdates];
        NSIndexPath *row1 = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:row1,nil] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];
        [((UISearchBar *)[[self.tableView cellForRowAtIndexPath:row1] viewWithTag:5000]) becomeFirstResponder];
    }
}

-(BOOL) searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    resListView = [[CESearchViewController alloc] initWithStyle:UITableViewStylePlain];
    [resListView setSearchStrings:circles];
    
    return YES;
}

-(BOOL) searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [resListView.tableView removeFromSuperview];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0){
        [resListView.tableView removeFromSuperview];
        [self.tableView setUserInteractionEnabled:YES];
        [[self.view viewWithTag:10100] removeFromSuperview];
    } else {
        if (searchText.length == 1 && [self.view viewWithTag:10100] == nil) {
            UIView *halfTransparentBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 135, screenRect.size.width, 300)];
            halfTransparentBackgroundView.backgroundColor = [UIColor blackColor]; //or whatever...
            halfTransparentBackgroundView.alpha = 0.5;
            halfTransparentBackgroundView.tag = 10100;
            [self.view addSubview:halfTransparentBackgroundView];
            [self.view addSubview:resListView.tableView];
            [self.view bringSubviewToFront:resListView.tableView];
        }
        [resListView performSearch:searchText];
    }
}

- (IBAction)handleTapGesture:(id)sender {
    [self toggleSearch];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row == 0) {
        return @"Logout";
    }
    return @"Delete";
}


@end
