//
//  CEDBConnector.h
//  CommonExpensesApp
//
//  Created by veseto on 04.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEUser.h"
#import "UserSettings.h"
#import "CircleDefinition.h"

@interface CEDBConnector : NSObject

-(CEUser *) getUser: (NSString *)username;
-(void) saveUser: (NSDictionary *) userAttributes;
-(void) setDefaultUser: (NSString *) username :(NSNumber *)userId;
-(NSArray *) getCirclesForUser: (NSNumber *) userId;
-(CircleDefinition *) createCircle:(CEUser *) owner :(NSString *) circleName;

-(void) updateCircle: (NSArray *) friends :(NSNumber *) ownerId :(NSString *) circleName ;


-(void) createCircleFromServer: (NSArray *) friends :(NSArray *) history :(NSNumber *) ownerId :(NSString *) circleName  :(NSNumber *) circleId :(NSNumber *) lastRevision;
-(NSMutableArray *) getFriendsInCircle: (NSString *) circleName :(NSNumber *)circleOwner;
-(UserSettings *) getUserSettings: (NSNumber *)userid;
-(void) removeDefaultUser;
-(BOOL) circleExistsForUser:(NSString *) circleName :(NSNumber *) userId;
-(void) addDeletedCircle: (NSNumber *) circleId :(NSNumber *) userId;
-(NSArray *) getDeletedCirclesForUser: (NSNumber *) userId;
-(void) removeDeletedCirclesForUser: (NSArray *) circleIds :(NSNumber *) userId;
-(void) deleteCircle: (NSString *) circleName :(NSNumber *) userId;
-(void) addHistoryRecords: (NSArray *) friendsArray :(NSString  *) circleName :(NSNumber *) circleOwner :(NSNumber *)authorId;
-(NSArray *) getHistoryRecords:(NSString  *) circleName :(NSNumber *) circleOwner;
-(NSArray *) getUnsyncedHistoryRecordsForCircle: (NSString *) circleName :(NSNumber *) ownerId;
@end
