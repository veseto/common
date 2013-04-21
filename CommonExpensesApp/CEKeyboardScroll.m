//
//  CEKeyboardScroll.m
//  CommonExpensesApp
//
//  Created by veseto on 21.04.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CEKeyboardScroll.h"

@interface CEKeyboardScroll ()

@end

@implementation CEKeyboardScroll

CGSize kbSize;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    kbSize = CGSizeMake(320, 216);
    [self registerForKeyboardNotifications];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    gestureRecognizer.numberOfTapsRequired = 1;

    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
   // UIEdgeInsets contentInsets = UIEdgeInsetsZero;
   // self.scrollView.contentInset = contentInsets;
   // self.scrollView.scrollIndicatorInsets = contentInsets;
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];

}

-(void) scrollViewToField: (UITextField *) activeField {
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height - 90);
    [self.scrollView setContentOffset:scrollPoint animated:YES];
}

- (IBAction)handleTapGesture:(id)sender {
    for(id view in self.scrollView.subviews){
        [(UIView *)view resignFirstResponder];
    }
}

@end
