//
//  CEHomeViewController.h
//  CommonExpensesApp
//
//  Created by veseto on 11.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuViewController.h"

@interface CEHomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) SideMenuViewController *sideMenu;
@property (nonatomic, retain) IBOutlet UIButton *selfViewButton;
- (IBAction)showSelfStatistics:(id)sender;
- (IBAction)sync:(id)sender;
- (IBAction)someAction:(id)sender;
@end
