//
//  CEFriendHelper.m
//  CommonExpensesApp
//
//  Created by veseto on 28.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CEFriendHelper.h"

@implementation CEFriendHelper
@synthesize userName = _userName;
@synthesize currency = _currency;
@synthesize amount = _amount;

-(CEFriendHelper *) initWithName:(NSString *) name {
    self = [CEFriendHelper new];
    _userName = name;
    return self;
}

@end
