//
//  CEHomeViewController.h
//  CommonExpensesApp
//
//  Created by veseto on 11.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LHDropDownControlView.h"
#import "SideMenuViewController.h"

@interface CEHomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, LHDropDownControlViewDelegate>{
    UIView *refreshHeaderView;
    UILabel *refreshLabel;
    UIImageView *refreshArrow;
    UIActivityIndicatorView *refreshSpinner;
    BOOL isDragging;
    BOOL isLoading;
    NSString *textPull;
    NSString *textRelease;
    NSString *textLoading;
}

@property (strong, nonatomic) IBOutlet UITextView *lastTransactionInfo;
@property (nonatomic, retain) UIView *refreshHeaderView;
@property (nonatomic, retain) UILabel *refreshLabel;
@property (nonatomic, retain) UIImageView *refreshArrow;
@property (nonatomic, retain) UIActivityIndicatorView *refreshSpinner;
@property (nonatomic, copy) NSString *textPull;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;
@property (nonatomic, retain) SideMenuViewController *sideMenu;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewContainer;

- (IBAction)sync:(id)sender;
- (IBAction)showHistoryView:(id)sender;
-(IBAction) addHistoryRecords:(UIButton *) sender;

@end
