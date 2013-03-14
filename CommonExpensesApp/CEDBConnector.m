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


-(NSString *) getUserPass: (NSString *)username {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:[NSPredicate predicateWithFormat:@"username == %@", username]];
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result == nil || result.count < 1) {
        return nil;
    }
    return [[result objectAtIndex:0] valueForKey:@"password"];
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

-(void) setDefaultUser:(NSString *)username {
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
    [context save:&error];
}

-(NSArray *) getCirclesForUser: (NSString *) userName {
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"CircleDefinition"
                inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (error || result.count < 1) {
        return nil;
    }
    return result;
}

@end
