//
//  CEDBConnector.m
//  CommonExpensesApp
//
//  Created by veseto on 04.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CEDBConnector.h"
#import "CEAppDelegate.h"
#import "User.h"
#import "StartupInfo.h"
#import "Friend.h"
#import "CircleDefinition.h"
#import "DeletedCircles.h"
#import "CEFriendHelper.h"
#import "HistoryRecord.h"

@implementation CEDBConnector

CEAppDelegate *delegate;
NSManagedObjectContext *context;

-(id)init {
    if ( self = [super init] ) {
    }
    delegate =[[UIApplication sharedApplication] delegate];
    context = [delegate managedObjectContext];

    return self;
}


-(CEUser *) getUser: (NSString *)username {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:[NSPredicate predicateWithFormat:@"username == %@", username]];
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result == nil || result.count < 1) {
        return nil;
    }
    CEUser *user = [CEUser new];
    user.userName = [[result objectAtIndex:0] valueForKey:@"username"];
    user.userId = [[result objectAtIndex:0] valueForKey:@"userid"];
    user.password = [[result objectAtIndex:0] valueForKey:@"password"];
    return user;
}

-(void) saveUser: (NSDictionary *) userAttributes {
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    [user setValue:[NSNumber numberWithInt:[[userAttributes objectForKey:@"userid"] intValue]] forKey:@"userid"];
    [user setValue:[userAttributes objectForKey:@"username"] forKey:@"username"];
    [user setValue:[userAttributes objectForKey:@"password"] forKey:@"password"];
    [user setValue:[userAttributes objectForKey:@"email"] forKey:@"email"];
    NSError *error;
    [context save:&error];
    
}

-(void) setDefaultUser: (NSString *) username :(NSNumber *)userId {
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"StartupInfo"
                inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    StartupInfo *startupInfo;
    if (result != nil && result.count > 0) {
        startupInfo = [result objectAtIndex:0];
    } else {
        startupInfo = [NSEntityDescription insertNewObjectForEntityForName:@"StartupInfo" inManagedObjectContext:context];
    }
    [startupInfo setValue:username forKey:@"defaultUsername"];
    [startupInfo setValue:userId forKey:@"defaultUserId"];

    [context save:&error];
}

-(NSArray *) getCirclesForUser: (NSString *) userId {
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"CircleDefinition"
                inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:[NSPredicate predicateWithFormat:@"ownerId == %@", userId]];
    [request setEntity:entityDesc];
    NSError *error; 
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (error || result.count < 1) {
        return nil;
    }
    return result;
}

-(CircleDefinition *) createCircle: (NSArray *) friends :(NSNumber *) ownerId :(NSString *) circleName  :(NSNumber *) circleId{
    //TODO add userId if any
    CircleDefinition *circleDef = [NSEntityDescription insertNewObjectForEntityForName:@"CircleDefinition" inManagedObjectContext:context];
    circleDef.name = circleName;
    circleDef.numberOfFriends = [NSNumber numberWithInt:friends.count];
    circleDef.ownerId = ownerId;
    circleDef.circleId = circleId;
    for (int i = 0; i < friends.count; i ++) {
        Friend *f = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:context];
        f.circleName = circleName;
        f.friendName = [friends objectAtIndex:i];;
        f.friendIndexInCircle = [NSNumber numberWithInt:i];
        f.circleOwner = ownerId;
    }
    
    NSError *error;
    [context save:&error];
    if (!error) {
        return circleDef;
    }
    return nil;
}


-(void) createCircleFromServer: (NSArray *) friends :(NSNumber *) ownerId :(NSString *) circleName  :(NSNumber *) circleId{
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"CircleDefinition"
                inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:[NSPredicate predicateWithFormat:@"ownerId == %@ && name == %@", ownerId, circleName]];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    CircleDefinition *circleDef;
    if (result != nil && result.count > 0) {
        circleDef = [result objectAtIndex:0];
    } else {
       circleDef = [NSEntityDescription insertNewObjectForEntityForName:@"CircleDefinition" inManagedObjectContext:context];
    }
    circleDef.name = circleName;
    circleDef.numberOfFriends = [NSNumber numberWithInt:friends.count];
    circleDef.ownerId = ownerId;
    circleDef.circleId = circleId;
    for (int i = 0; i < friends.count; i ++) {
        NSDictionary *dict = [friends objectAtIndex:i];
        NSEntityDescription *entityDescFr = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:context];
        NSFetchRequest *requestFr = [[NSFetchRequest alloc] init];
        [requestFr setPredicate:[NSPredicate predicateWithFormat:@"friendName == %@ && circleName == %@ && circleOwner == %@", [dict objectForKey:@"friendName"], circleName, ownerId]];
        [requestFr setEntity:entityDescFr];
        NSError *errorFr;
        NSArray *resultFr = [context executeFetchRequest:requestFr error:&errorFr];
        Friend *f;
        if (resultFr != nil && resultFr.count > 0) {
            f = [resultFr objectAtIndex:0];
        } else {
            f = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:context];
        }
        f.circleName = circleName;
        f.friendName = [dict objectForKey:@"friendName"];
        f.friendIndexInCircle = [NSNumber numberWithInt:[[dict objectForKey:@"friedIndexInCircle"] intValue]];
        if (![[dict objectForKey:@"friendId"] isEqual: [NSNull null]]) {
            f.friendId = [NSNumber numberWithInt:[[dict objectForKey:@"friendId"] intValue]];
        }
        f.balanceInCircle = [NSNumber numberWithInt:[[dict objectForKey:@"balanceInCircle"] intValue]];
        f.circleOwner = [NSNumber numberWithInt:[[dict objectForKey:@"circleOwner"] intValue]];
    }
    
    [context save:&error];
}



-(NSArray *) getFriendsInCircle: (NSString *) circleName :(NSNumber *)circleOwner{
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Friend"
                inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:[NSPredicate predicateWithFormat:@"circleName == %@ && circleOwner == %d", circleName, circleOwner.intValue]];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (error || result.count < 1) {
        return nil;
    }
    return result;
}

-(UserSettings *) getUserSettings: (NSNumber *)userid {
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"UserSettings"
                inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:[NSPredicate predicateWithFormat:@"userid == %@", userid]];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (error || result.count < 1) {
        return nil;
    }
    return [result objectAtIndex:0];
    
}

-(void) removeDefaultUser {
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"StartupInfo"
                inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    StartupInfo *startupInfo;
    if (result != nil && result.count > 0) {
        startupInfo = [result objectAtIndex:0];
        [context deleteObject:startupInfo];
    } 
    [context save:&error];
}


-(BOOL) circleExistsForUser:(NSString *) circleName :(NSNumber *) userId {
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"CircleDefinition"
                inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:[NSPredicate predicateWithFormat:@"ownerId == %@ && name == %@", userId, circleName]];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result == nil || result.count < 1) return NO;
    return YES;
}

-(void) addDeletedCircle: (NSNumber *) circleId :(NSNumber *) userId {
    DeletedCircles *deletedCircle = [NSEntityDescription insertNewObjectForEntityForName:@"DeletedCircles" inManagedObjectContext:context];
    deletedCircle.userId = userId;
    deletedCircle.circleId = circleId;
        NSError *error;
    [context save:&error];
}

-(NSArray *) getDeletedCirclesForUser: (NSNumber *) userId {
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"DeletedCircles" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:[NSPredicate predicateWithFormat:@"userId == %@", userId]];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (error || result.count < 1) {
        return [NSArray new];
    }
    NSMutableArray *resArray = [NSMutableArray new];
    for (DeletedCircles *delCircle in result) {
        [resArray addObject:delCircle.circleId];
    }
    return resArray;
}

-(void) removeDeletedCirclesForUser: (NSArray *) circleIds :(NSNumber *) userId{
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"DeletedCircles"
                inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:[NSPredicate predicateWithFormat:@"userId == %@", userId]];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result != nil && result.count > 0) {
        for (DeletedCircles *d in result) {
            if ([circleIds containsObject:d.circleId]) {
                [context deleteObject:d];
            }
        }
    }
    [context save:&error];
}

-(void) deleteCircle: (NSString *) circleName :(NSNumber *) userId {
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"CircleDefinition"
                inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@ and ownerId == %@", circleName, userId]];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result != nil && result.count > 0) {
        CircleDefinition *def = [result objectAtIndex:0];
        NSArray *friends = [self getFriendsInCircle:circleName :userId];
        for (Friend *f in friends) {
            [context deleteObject:f];
        }
        [context deleteObject:def];
    }
    [context save:&error];
}

-(void) addHistoryRecords: (NSArray *) friendsArray :(NSString  *) circleName :(NSNumber *) circleOwner :(NSNumber *)authorId {
    double sum = 0;
    for (CEFriendHelper *frHelper in friendsArray) {
        if (frHelper.amount > 0) {
            HistoryRecord *record = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryRecord" inManagedObjectContext:context];
            record.user = frHelper.userName;
            record.sum = [NSNumber numberWithDouble: frHelper.amount.doubleValue];
            record.currency = frHelper.currency;
            record.circleName = circleName;
            record.circleOwner = circleOwner;
            record.authorId = authorId;
            sum += record.sum.doubleValue;
        }
    }
    NSArray *friendsInCircle = [[NSArray alloc] initWithArray:[self getFriendsInCircle:circleName :circleOwner]];
    for (Friend *f in friendsInCircle) {
        for (CEFriendHelper *frHelper in friendsArray) {
            if ([frHelper.userName isEqualToString:f.friendName]) {
                f.balanceInCircle = [NSNumber numberWithDouble:f.balanceInCircle.doubleValue + frHelper.amount.doubleValue - sum/friendsInCircle.count];
            }
        }
    }
    NSError *error;
    [context save:&error];
    
}

-(NSArray *) getHistoryRecords:(NSString  *) circleName :(NSNumber *) circleOwner {
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"HistoryRecord" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:[NSPredicate predicateWithFormat:@"circleOwner == %d && circleName == %@", circleOwner.intValue, circleName]];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (error || result.count < 1) {
        return [NSArray new];
    }
    return result;
}

-(void) updateFriendsInCircle:(NSArray *) friends :circleName :(NSNumber *) circleOwner{
    NSArray *friendsInCircle = [self getFriendsInCircle:circleName :circleOwner];
    for (Friend *f in friendsInCircle) {
        for (CEFriendHelper *h in friends) {
            if ([f.friendName isEqualToString:h.userName]) {
                
            }
        }
    }
}

@end
