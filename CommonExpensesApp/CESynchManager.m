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
#import "HistoryRecord.h"

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
        NSArray *history = [[NSArray alloc] initWithArray:[connector getUnsyncedHistoryRecordsForCircle:def.name :userId]];
        if (def.circleId == nil || [def.circleId isEqualToNumber:[NSNumber numberWithInt:0]] || history.count > 0) {
            NSMutableDictionary *tmp = [NSMutableDictionary new];
            if (def.circleId == nil || [def.circleId isEqualToNumber:[NSNumber numberWithInt:0]]) {
                [tmp setObject:[NSNumber numberWithInt:0] forKey:@"id"];
            } else {
                [tmp setObject:def.circleId forKey:@"id"];
            }
            [tmp setObject:def.name forKey:@"name"];
            [tmp setObject:def.ownerId forKey:@"ownerId"];
            [tmp setObject:def.numberOfFriends forKey:@"numberOfFriends"];
            if (def.lastServerRevision == nil) {
                [tmp setObject:[NSNumber numberWithInt:0] forKey:@"lastRevision"];
            } else {
                [tmp setObject:def.lastServerRevision forKey:@"lastRevision"];
            }
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
            
            
            NSMutableArray *hArray = [NSMutableArray new];
            for (HistoryRecord *record in history) {
                NSMutableDictionary *historyDict = [NSMutableDictionary new];
                [historyDict setObject:record.authorId forKey:@"authorId"];
                [historyDict setObject:record.user forKey:@"user"];
                [historyDict setObject:record.centralId forKey:@"centralId"];
                [historyDict setObject:record.currency forKey:@"currency"];
                [historyDict setObject:record.sum forKey:@"sum"];
                [historyDict setObject:record.circleName forKey:@"circleName"];
                [historyDict setObject:record.circleOwner forKey:@"circleOwner"];

                [hArray addObject:historyDict];
            }
            [tmp setObject:hArray forKey:@"history"];
            
            
        }
        if (def.circleId!= nil && ![deleted containsObject:def.circleId]){
            NSMutableDictionary *circleRev = [NSMutableDictionary dictionaryWithObject:def.circleId forKey:@"id"];
            if (def.lastServerRevision == nil) {
                [circleRev setObject:0 forKey:@"lastRevision"];
            } else {
                [circleRev setObject:def.lastServerRevision forKey:@"lastRevision"];
            }
            [circleIndexes addObject:circleRev];
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
