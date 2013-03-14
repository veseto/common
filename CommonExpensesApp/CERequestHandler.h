//
//  CERequestHandler.h
//  CommonExpensesApp
//
//  Created by veseto on 28.02.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CERequestHandler : NSObject

-(NSDictionary *) sendRequest:(NSDictionary *)params :(NSString *)alias;

@end
