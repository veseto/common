//
//  CEFriendHelper.h
//  CommonExpensesApp
//
//  Created by veseto on 28.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEFriendHelper : NSObject

@property NSString *userName;
@property NSString *currency;
@property NSString *amount;

-(CEFriendHelper *) initWithName:(NSString *) name;

@end
