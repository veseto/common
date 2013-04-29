//
//  CESearchViewController.m
//  CommonExpensesApp
//
//  Created by veseto on 29.04.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CESearchViewController.h"
#import "CircleDefinition.h"
#import "CEAppDelegate.h"

@interface CESearchViewController ()

@end

@implementation CESearchViewController
@synthesize searchStrings = _searchStrings;

NSMutableArray *displayList;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.tableView.frame = CGRectMake(10, 135, 250, 190);
    }
    return self;
}

- (void)viewDidLoad
{
    displayList = [NSMutableArray new];
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return displayList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [displayList objectAtIndex:indexPath.row];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *name = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    for (CircleDefinition *c in _searchStrings) {
        if ([c.name isEqualToString:name]) {

            ((CEAppDelegate *)[[UIApplication sharedApplication] delegate]).currentCircle = c;
            UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];

            UIViewController *stats = [sb instantiateViewControllerWithIdentifier:@"home"];
            self.navigationController.viewControllers = [[NSArray alloc] initWithObjects:stats, nil];
            [self.navigationController popToRootViewControllerAnimated:NO];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ReloadHomeViewNotification"
             object:self];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"hideKeyboardNotification"
             object:self];
        }
    }
}

-(void) performSearch:(NSString *) searchString {
    [displayList removeAllObjects];
    for (CircleDefinition *s in _searchStrings) {
        if ([s.name rangeOfString:searchString].location != NSNotFound) {
            [displayList addObject:s.name];
        }
    }
    CGRect old = self.tableView.frame;
    [self.tableView setFrame:CGRectMake(old.origin.x, old.origin.y, old.size.width, displayList.count * 44)];
    
    [displayList sortUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
    [self.tableView reloadData];
}

@end
