//
//  StartupInfo.h
//  CommonExpensesApp
//
//  Created by veseto on 14.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StartupInfo : NSManagedObject

@property (nonatomic, retain) NSString * defaultUsername;
@property (nonatomic, retain) NSNumber * alwaysOnSync;

@end
