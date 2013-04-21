//
//  CEPasswordResetViewController.h
//  CommonExpensesApp
//
//  Created by veseto on 21.04.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CEPasswordResetViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *email;
- (IBAction)sendResetRequest:(id)sender;
- (IBAction)goBack:(id)sender;

@end
