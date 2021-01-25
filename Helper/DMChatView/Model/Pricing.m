//
//  Pricing.m
//  Fanatik
//
//  Created by Erick Martin on 11/26/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "Pricing.h"
@implementation Pricing

-(id)initWithDictionary:(NSDictionary *)jsonDict{
    if(self=[super init]){
        self.pricingId = [self intFromJSONObject:jsonDict[@"id"]];
        self.type = [self stringFromJSONObject:jsonDict[@"type"]];
        self.priced_type = [self stringFromJSONObject:jsonDict[@"priced_type"]];
        self.stickerId = [self intFromJSONObject:jsonDict[@"priced_id"]];
        self.price = [self stringFromJSONObject:jsonDict[@"price"]];
        self.duration = [self intFromJSONObject:jsonDict[@"duration"]];
        self.volume = [self intFromJSONObject:jsonDict[@"volume"]];
        self.info = [self stringFromJSONObject:jsonDict[@"info"]];
        self.price_str = [self stringFromJSONObject:jsonDict[@"price_str"]];
        self.price_int = [self intFromJSONObject:jsonDict[@"price_int"]];
    }
    return self;
}


-(id)initWithFMResultSet:(FMResultSet *)result{
    if(self = [super init]){
        self.pricingId = [result intForColumn:@"pricingId"];
        self.type = [result stringForColumn:@"type"];
        self.priced_type = [result stringForColumn:@"priced_type"];
        self.stickerId = [result intForColumn:@"stickerId"];
        self.price = [result stringForColumn:@"price"];
        self.duration = [result intForColumn:@"duration"];
        self.volume = [result intForColumn:@"volume"];
        self.info = [result stringForColumn:@"info"];
        self.price_str = [result stringForColumn:@"price_str"];
        self.price_int = [result intForColumn:@"price_int"];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)decoder{
    if(self=[super init]){
        self.pricingId = [decoder decodeIntForKey:@"pricingId"];
        self.type = [decoder decodeObjectForKey:@"type"];
        self.priced_type = [decoder decodeObjectForKey:@"priced_type"];
        self.stickerId = [decoder decodeIntForKey:@"stickerId"];
        self.price = [decoder decodeObjectForKey:@"price"];
        self.duration = [decoder decodeIntForKey:@"duration"];
        self.volume = [decoder decodeIntForKey:@"volume"];
        self.info = [decoder decodeObjectForKey:@"info"];
        self.price_str = [decoder decodeObjectForKey:@"price_str"];
        self.price_int = [decoder decodeIntForKey:@"price_int"];
    }
    return self;
}


-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeInt:self.pricingId forKey:@"pricingId"];
    [encoder encodeObject:self.type forKey:@"type"];
    [encoder encodeObject:self.priced_type forKey:@"priced_type"];
    [encoder encodeInt:self.stickerId forKey:@"stickerId"];
    [encoder encodeObject:self.price forKey:@"price"];
    [encoder encodeInt:self.duration forKey:@"duration"];
    [encoder encodeInt:self.volume forKey:@"volume"];
    [encoder encodeObject:self.info forKey:@"info"];
    [encoder encodeObject:self.price_str forKey:@"price_str"];
    [encoder encodeInt:self.price_int forKey:@"price_int"];
}

@end