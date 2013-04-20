//
//  CETextField.m
//  CommonExpensesApp
//
//  Created by veseto on 20.04.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CETextField.h"

@implementation CETextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setBorderStyle:UITextBorderStyleRoundedRect];
       // [self setBackgroundColor:[UIColor redColor]];
        [self setTextColor:[UIColor colorWithRed:(139.0f/225.0f) green:(69.0f/225.0f) blue:(19.0f/225.0f) alpha:1.0f]];
        [self setFont:[UIFont fontWithName:@"Gill Sans" size:18.0]];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
