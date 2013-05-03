//
//  SideMenuViewController.h
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import <UIKit/UIKit.h>
#import "MFSideMenu.h"

@interface SideMenuViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign) MFSideMenu *sideMenu;
@property (nonatomic, assign) BOOL search;
@property (nonatomic, retain) UITapGestureRecognizer *tap;
@end