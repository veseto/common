//
//  CEAddFriendsViewController.h
//  CommonExpensesApp
//
//  Created by veseto on 14.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleDefinition.h"

@interface CEAddFriendsViewController : UIViewController
- (IBAction)finish:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property CircleDefinition *circle;
@end
