//
//  BaseModel.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 11/17/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

-(id)initWithDictionary:(NSDictionary *)jsonDict{
    if(self=[super init]){
        
    }
    return self;
}


-(id)initWithFMResultSet:(FMResultSet *)result{
    if(self=[super init]){
        
    }
    return self;
}

-(BOOL)isNull:(id)jsonObj{
    return (!jsonObj || [jsonObj isKindOfClass:[NSNull class]]);
}

-(NSString *)stringFromJSONObject:(NSString *)jsonStr{
    if([self isNull:jsonStr]){
        return @"";
    }
    return jsonStr;
}

-(int)intFromJSONObject:(id)jsonObj{
    if([self isNull:jsonObj]){
        return 0;
    }
    return [jsonObj intValue];
}

-(float)floatFromJSONObject:(id)jsonObj{
    if([self isNull:jsonObj]){
        return 0;
    }
    return [jsonObj floatValue];
}

-(BOOL)boolFromJSONObject:(id)jsonObj{
    if([self isNull:jsonObj]){
        return NO;
    }
    return [jsonObj boolValue];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    //    [encoder encodeObject:self.active forKey:@"active"];
    //    [encoder encodeObject:self.key forKey:@"key"];
    //    [encoder encodeObject:self.label forKey:@"label"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        //        self.active = [decoder decodeObjectForKey:@"active"];
        //        self.key = [decoder decodeObjectForKey:@"key"];
        //        self.label = [decoder decodeObjectForKey:@"label"];
    }
    return self;
}

@end
