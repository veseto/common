//
//  CircleDefinition.h
//  CommonExpensesApp
//
//  Created by veseto on 28.04.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CircleDefinition : NSManagedObject

@property (nonatomic, retain) NSNumber * circleId;
@property (nonatomic, retain) NSNumber * lastServerRevision;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberOfFriends;
@property (nonatomic, retain) NSNumber * ownerId;
@property (nonatomic, retain) NSDate * lastUpdated;

@end
