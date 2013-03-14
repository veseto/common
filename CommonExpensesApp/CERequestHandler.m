//
//  CERequestHandler.m
//  CommonExpensesApp
//
//  Created by veseto on 28.02.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import "CERequestHandler.h"
#import "CEConstants.h"

@implementation CERequestHandler

-(NSDictionary *) sendRequest:(NSDictionary *)params :(NSString *)alias {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, alias]]];
    [request setHTTPMethod:@"post"];
    NSEnumerator *keyEnum = [params keyEnumerator];
    NSString *key = [keyEnum nextObject];
    NSString *postString = [[NSString alloc] init];
    while (key != nil) {
        postString = [postString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, [params objectForKey:key]]];
        key = [keyEnum nextObject];
    }
    postString = [postString stringByAppendingString:@"ios=true"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error;
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *test = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(test);
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:
                          NSJSONReadingMutableContainers error:&error];
    return json;
}
@end
