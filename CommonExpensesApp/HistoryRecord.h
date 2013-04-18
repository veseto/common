//
//  HistoryRecord.h
//  CommonExpensesApp
//
//  Created by veseto on 01.04.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HistoryRecord : NSManagedObject

@property (nonatomic, retain) NSNumber * authorId;
@property (nonatomic, retain) NSNumber * centralId;
@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSNumber * sum;
@property (nonatomic, retain) NSString * user;
@property (nonatomic, retain) NSString * circleName;
@property (nonatomic, retain) NSNumber * circleOwner;
@property (nonatomic, retain) NSNumber * lastServerRevision;

@end
