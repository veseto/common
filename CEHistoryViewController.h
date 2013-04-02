//
//  CEHistoryViewController.h
//  CommonExpensesApp
//
//  Created by veseto on 01.04.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleDefinition.h"

@interface CEHistoryViewController : UIViewController
- (IBAction)closeHistoryView:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property CircleDefinition *definition;

@end
