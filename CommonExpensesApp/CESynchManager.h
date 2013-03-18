//
//  CESynchManager.h
//  CommonExpensesApp
//
//  Created by veseto on 18.03.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CESynchManager : NSObject

-(NSData *) syncAllUserData: (NSNumber *) userId;

@end
