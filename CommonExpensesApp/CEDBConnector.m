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
    [user setValue:[NSNumber numberWithInt:[[userAttributes objectForKey:@"userid"] integerValue]] forKey:@"userid"];
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

-(void) createCircle: (NSArray *) friends :(NSNumber *) ownerId :(NSString *) circleName {
    CircleDefinition *circleDef = [NSEntityDescription insertNewObjectForEntityForName:@"CircleDefinition" inManagedObjectContext:context];
    circleDef.name = circleName;
    circleDef.numberOfFriends = [NSNumber numberWithInt:friends.count];
    circleDef.ownerId = ownerId;
    
    for (int i = 0; i < friends.count; i ++) {
        Friend *f = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:context];
        f.circleName = circleName;
        f.friendName = [friends objectAtIndex:i];;
        f.friendIndexInCircle = [NSNumber numberWithInt:i];
        f.circleOwner = ownerId;
    }
    
    NSError *error;
    [context save:&error];
}

-(NSArray *) getFriendsInCircle: (NSString *) circleName {
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Friend"
                inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:[NSPredicate predicateWithFormat:@"circleName == %@", circleName]];
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
    
}
@end
