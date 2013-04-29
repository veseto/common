//
//  CESearchViewController.h
//  CommonExpensesApp
//
//  Created by veseto on 29.04.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CESearchViewController : UITableViewController

@property (nonatomic, retain) NSArray *searchStrings;
-(void) performSearch:(NSString *) searchString;
@end
