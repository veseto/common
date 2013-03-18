//
//  CESynchManager.m
//  CommonExpensesApp
//
//  Created by veseto on 18.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CESynchManager.h"
#import "CEAppDelegate.h"
#import "CEDBConnector.h"
#import "CEUser.h"
#import "CircleDefinition.h"
#import "Friend.h"

@implementation CESynchManager

-(NSData *) syncAllUserData: (NSNumber *) userId {
    CEDBConnector *connector = [CEDBConnector new];
    
    NSArray *circlesForUser = [connector getCirclesForUser:userId];
    NSMutableArray *jsonCircles = [NSMutableArray new];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:userId forKey:@"userid"];
    
    for (CircleDefinition *def in circlesForUser) {
        if ([def.circleId isEqualToNumber:[NSNumber numberWithInt:0]]) {
            NSMutableDictionary *tmp = [NSMutableDictionary new];
            [tmp setObject:def.name forKey:@"name"];
            [tmp setObject:def.ownerId forKey:@"ownerId"];
            [tmp setObject:def.numberOfFriends forKey:@"numberOfFriends"];
            [jsonCircles addObject:tmp];
            NSArray *friends = [connector getFriendsInCircle:[def valueForKey:@"name"]];
            NSMutableArray *frArray = [NSMutableArray new];
            for (Friend *friend in friends) {
                NSMutableDictionary *friendsDict = [NSMutableDictionary new];
                [friendsDict setObject:friend.friendName forKey:@"friendName"];
                [friendsDict setObject:friend.circleName forKey:@"circleName"];
                [friendsDict setObject:friend.friendIndexInCircle forKey:@"friendIndexInCircle"];
                [friendsDict setObject:friend.balanceInCircle forKey:@"balanceInCircle"];
                [frArray addObject:friendsDict];
            }
            [tmp setObject:frArray forKey:@"friends"];
        }
    }
    [dict setObject:jsonCircles forKey:@"circles"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (!jsonData) {
        NSLog(@"JSON error: %@", error);
    } else {
        //Do something with jsonData
    }
    return jsonData;
}


@end
