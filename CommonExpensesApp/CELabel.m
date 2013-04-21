//
//  CELabel.m
//  CommonExpensesApp
//
//  Created by veseto on 20.04.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CELabel.h"

@implementation CELabel

- (id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])) {
       // [self setBackgroundColor:[UIColor redColor]];
        [self setFont:([UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0])];
        [self setTextColor:[UIColor colorWithRed:(73.0f/255.0f) green:(66.0f/255.0f) blue:(61.0f/255.0f) alpha:1.0f]];
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
