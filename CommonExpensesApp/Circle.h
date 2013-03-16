//
//  Circle.h
//  CommonExpensesApp
//
//  Created by veseto on 14.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Circle : NSManagedObject

@property (nonatomic, retain) NSString * circleName;
@property (nonatomic, retain) NSNumber * friendId;
@property (nonatomic, retain) NSNumber * friendIndexInCircle;
@property (nonatomic, retain) NSString * friendName;

@end
