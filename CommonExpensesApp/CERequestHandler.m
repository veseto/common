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
    postString = [postString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        return [NSDictionary dictionaryWithObject:error forKey:@"error"];
    } else {
        NSLog([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:
                          NSJSONReadingMutableContainers error:&error];
        return json;
    }
}

-(NSDictionary *) sendJsonRequest: (NSData *) json :(NSString *) alias {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, alias]]];
    [request setHTTPMethod:@"post"];
    [request setHTTPBody:json];
    NSString *postString = [[NSString alloc] init];
    NSURLResponse *response;
    NSError *error;
    postString = [postString stringByAppendingString:@"ios=true"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        return [NSDictionary dictionaryWithObject:error forKey:@"error"];
    } else {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:
                              NSJSONReadingMutableContainers error:&error];
        return json;
    }
    
}
@end
