//
//  CircleDefinition.m
//  CommonExpensesApp
//
//  Created by veseto on 14.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CircleDefinition.h"


@implementation CircleDefinition

@dynamic id;
@dynamic name;
@dynamic numberOfFriends;
@dynamic ownerId;

+(CircleDefinition *) initWithAttrs: (NSString *) name :(NSNumber *)numberOfFriends :(NSNumber *)ownerId {
    CircleDefinition *def = [[CircleDefinition alloc] init];
    def.numberOfFriends = numberOfFriends;
    def.name = name;
    //def.ownerId =
}


@end
