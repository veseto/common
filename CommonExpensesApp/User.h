//
//  User.h
//  CommonExpensesApp
//
//  Created by veseto on 14.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * userid;
@property (nonatomic, retain) NSString * username;

@end
