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

@interface CEDBConnector : NSObject

-(CEUser *) getUser: (NSString *)username;
-(void) saveUser: (NSDictionary *) userAttributes;
-(void) setDefaultUser: (NSString *) username :(NSNumber *)userId;
-(NSArray *) getCirclesForUser: (NSNumber *) userId;
-(void) createCircle: (NSArray *) friends :(NSNumber *) ownerId :(NSString *) circleName :(NSNumber *) circleId;
-(void) createCircleFromServer: (NSArray *) friends :(NSNumber *) ownerId :(NSString *) circleName :(NSNumber *) circleId;
-(NSArray *) getFriendsInCircle: (NSString *) circleName;
-(UserSettings *) getUserSettings: (NSNumber *)userid;
-(void) removeDefaultUser;
-(BOOL) circleExistsForUser:(NSString *) circleName :(NSNumber *) userId;
-(void) addDeletedCircle: (NSNumber *) circleId :(NSNumber *) userId;
-(NSArray *) getDeletedCirclesForUser: (NSNumber *) userId;
-(void) deleteCircle: (NSString *) circleName :(NSNumber *) userId;
@end
