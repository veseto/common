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
        [self setBackgroundColor:[UIColor colorWithRed:(96.0f/255.0f) green:(120.0f/255.0f) blue:(144.0f/255.0f) alpha:1.0f]];
        [self.layer setBorderColor:[[UIColor colorWithRed:(96.0f/255.0f) green:(120.0f/255.0f) blue:(144.0f/255.0f) alpha:1.0f] CGColor]];
        [self.layer setBorderWidth:1.0f];
        [self setTitleColor:[UIColor colorWithRed:(242.0f/255.0f) green:(240.0f/255.0f) blue:(223.0f/255.0f) alpha:1.0f] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:(73.0f/255.0f) green:(66.0f/255.0f) blue:(61.0f/255.0f) alpha:1.0f] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor colorWithRed:(241.0f/255.0f) green:(209.0f/255.0f) blue:(134.0f/255.0f) alpha:0.03f] forState:UIControlStateDisabled];
        [self.titleLabel setFont:([UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0])];
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
