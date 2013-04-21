//
//  CEKeyboardScroll.h
//  CommonExpensesApp
//
//  Created by veseto on 21.04.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CEKeyboardScroll : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
-(void) scrollViewToField: (UITextField *) activeField;
@end
