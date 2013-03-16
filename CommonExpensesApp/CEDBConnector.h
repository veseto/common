//
//  CEDBConnector.h
//  CommonExpensesApp
//
//  Created by veseto on 04.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEUser.h"

@interface CEDBConnector : NSObject

-(CEUser *) getUser: (NSString *)username :(NSString *)password;
-(void) saveUser: (NSDictionary *) userAttributes;
-(void) setDefaultUser: (NSString *) username :(NSNumber *)userId;
-(NSArray *) getCirclesForUser: (NSNumber *) userId;
-(void) createCircle: (NSArray *) friends :(NSNumber *) ownerId :(NSString *) circleName;
@end
