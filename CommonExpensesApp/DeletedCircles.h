//
//  DeletedCircles.h
//  CommonExpensesApp
//
//  Created by veseto on 22.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DeletedCircles : NSManagedObject

@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * circleId;

@end
