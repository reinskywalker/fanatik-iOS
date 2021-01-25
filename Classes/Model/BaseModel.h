//
//  BaseModel.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 11/17/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject

-(id)initWithDictionary:(NSDictionary *)jsonDict;
-(id)initWithFMResultSet:(FMResultSet *)result;
-(id)initWithCoder:(NSCoder *)decoder;
-(void)encodeWithCoder:(NSCoder *)encoder;

-(BOOL)isNull:(id)jsonObj;
-(NSString *)stringFromJSONObject:(NSString *)jsonStr;
-(int)intFromJSONObject:(id)jsonObj;
-(float)floatFromJSONObject:(id)jsonObj;
-(BOOL)boolFromJSONObject:(id)jsonObj;

@end
