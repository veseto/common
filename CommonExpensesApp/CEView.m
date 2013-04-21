//
//  CEView.m
//  CommonExpensesApp
//
//  Created by veseto on 21.04.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CEView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CEView

- (id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setBackgroundColor:[UIColor colorWithRed:(242.0f/255.0f) green:(240.0f/255.0f) blue:(223.0f/255.0f) alpha:1.0f]];
        [self.layer setBorderColor:[[UIColor colorWithRed:(96.0f/255.0f) green:(120.0f/255.0f) blue:(144.0f/255.0f) alpha:1.0f] CGColor]];
        [self.layer setBorderWidth:1.0f];

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
