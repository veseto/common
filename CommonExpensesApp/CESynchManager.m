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
    NSArray *deleted = [connector getDeletedCirclesForUser:userId];
    [dict setObject:deleted forKey:@"deleted"];
    NSMutableArray *circleIndexes = [NSMutableArray new];
    for (CircleDefinition *def in circlesForUser) {
        if (def.circleId == nil || [def.circleId isEqualToNumber:[NSNumber numberWithInt:0]]) {
            NSMutableDictionary *tmp = [NSMutableDictionary new];
            [tmp setObject:def.name forKey:@"name"];
            [tmp setObject:def.ownerId forKey:@"ownerId"];
            [tmp setObject:def.numberOfFriends forKey:@"numberOfFriends"];
            [jsonCircles addObject:tmp];
            NSArray *friends = [connector getFriendsInCircle:def.name :def.ownerId];
            NSMutableArray *frArray = [NSMutableArray new];
            for (Friend *friend in friends) {
                NSMutableDictionary *friendsDict = [NSMutableDictionary new];
                [friendsDict setObject:friend.friendName forKey:@"friendName"];
                [friendsDict setObject:friend.circleName forKey:@"circleName"];
                [friendsDict setObject:friend.friendIndexInCircle forKey:@"friendIndexInCircle"];
                [friendsDict setObject:friend.balanceInCircle forKey:@"balanceInCircle"];
                [friendsDict setObject:friend.circleOwner forKey:@"circleOwner"];
                [frArray addObject:friendsDict];
            }
            [tmp setObject:frArray forKey:@"friends"];
        } else {
            if (![deleted containsObject:def.circleId]){
                [circleIndexes addObject:def.circleId];
            }
        }
    }
    [dict setObject:circleIndexes forKey:@"indexes"];
    [dict setObject:jsonCircles forKey:@"circles"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString* newStr = [[NSString alloc] initWithData:jsonData
                                              encoding:NSUTF8StringEncoding];
    if (!jsonData) {
        NSLog(@"JSON error: %@", error);
    } else {
        NSLog(newStr);
    }
    
    
    return jsonData;
}


@end
