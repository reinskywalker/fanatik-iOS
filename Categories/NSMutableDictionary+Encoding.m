//
//  NSMutableDictionary+Encoding.m
//  Fanatik
//
//  Created by Erick Martin on 12/17/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "NSMutableDictionary+Encoding.h"

@implementation NSMutableDictionary (Encoding)

- (void)dictionaryByReplacingNullsWithStrings{
    const id nul = [NSNull null];
    const NSString *blank = @"";
    
    for(NSString *key in [self allKeys]) {
        const id object = [self objectForKey:key];
        if(object == nul) {
            //pointer comparison is way faster than -isKindOfClass:
            //since [NSNull null] is a singleton, they'll all point to the same
            //location in memory.
            [self setObject:blank
                         forKey:key];
        }
    }
}

-(void)removeUnusedCharacterInDictionary{
    
    for(NSString *key in [self allKeys]){
        id value = [self objectForKey:key];
        
        NSCharacterSet *trim = [NSCharacterSet characterSetWithCharactersInString:@"&"];
        NSString *keyResult = [[key componentsSeparatedByCharactersInSet:trim] componentsJoinedByString:@""];
        
        [self setObject:value forKey:keyResult];
    }
}

-(NSDictionary *)removeUnusedCharacterAndNull{

    const id nul = [NSNull null];
    
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    
    for(NSString *key in [self allKeys]) {
        id value = [self objectForKey:key];
        
        NSCharacterSet *trim = [NSCharacterSet characterSetWithCharactersInString:@"&"];
        NSString *keyResult = [[key componentsSeparatedByCharactersInSet:trim] componentsJoinedByString:@""];
    
        if(value == nul) {
            value = @"";
        }
    
        [mutableDict setObject:value forKey:keyResult];
    }
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

@end
