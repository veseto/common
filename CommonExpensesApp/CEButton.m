//
//  CEButton.m
//  CommonExpensesApp
//
//  Created by veseto on 20.04.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CEButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation CEButton

- (id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setBackgroundColor:[UIColor colorWithRed:(232.0f/255.0f) green:(222.0f/255.0f) blue:(188.0f/255.0f) alpha:1.0f]];
        [self.layer setBorderColor:[[UIColor colorWithRed:(140.0f/255.0f) green:(112.0f/255.0f) blue:(66.0f/255.0f) alpha:1.0f] CGColor]];
        [self.layer setBorderWidth:1.0f];
        [self setTitleColor:[UIColor colorWithRed:(77.0f/255.0f) green:(20.0f/255.0f) blue:(20.0f/255.0f) alpha:1.0f] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:(140.0f/255.0f) green:(112.0f/255.0f) blue:(66.0f/255.0f) alpha:1.0f] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor colorWithRed:(77.0f/255.0f) green:(20.0f/255.0f) blue:(20.0f/255.0f) alpha:0.03f] forState:UIControlStateDisabled];
        [self.titleLabel setFont:([UIFont fontWithName:@"Helvetica Neue" size:16.0])];
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
