//
//  CEDBConnector.h
//  CommonExpensesApp
//
//  Created by veseto on 04.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEDBConnector : NSObject

-(NSString *) getUserPass: (NSString *)username;
-(void) saveUser: (NSDictionary *) userAttributes;
-(void) setDefaultUser: (NSString *) username;
-(NSArray *) getCirclesForUser: (NSString *) userName;
-(NSNumber *) getUserId: (NSString *) userName;
@end
