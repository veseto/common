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
        [self setBorderStyle:UITextBorderStyleNone];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setTextColor:[UIColor colorWithRed:(142.0f/255.0f) green:(158.0f/255.0f) blue:(130.0f/255.0f) alpha:1.0f]];
        [self setFont:([UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0])];
        [self setAlpha:1.0f];
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
