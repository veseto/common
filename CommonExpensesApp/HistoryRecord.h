//
//  HistoryRecord.h
//  CommonExpensesApp
//
//  Created by veseto on 14.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HistoryRecord : NSManagedObject

@property (nonatomic, retain) NSNumber * centralId;
@property (nonatomic, retain) NSNumber * authorId;
@property (nonatomic, retain) NSString * user;
@property (nonatomic, retain) NSNumber * sum;
@property (nonatomic, retain) NSString * currency;

@end
