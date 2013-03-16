//
//  CEHomeViewController.h
//  CommonExpensesApp
//
//  Created by veseto on 11.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuViewController.h"

@interface CEHomeViewController : UIViewController
@property (nonatomic, retain) SideMenuViewController *sideMenu;
@property (strong, nonatomic) IBOutlet UILabel *circleName;
@end
