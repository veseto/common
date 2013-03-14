//
//  CEAddCircleViewController.h
//  CommonExpensesApp
//
//  Created by veseto on 14.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CEAddCircleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *name;
@property (strong, nonatomic) IBOutlet UITextField *friendName;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)add:(id)sender;
- (IBAction)createCircle:(id)sender;

@end
