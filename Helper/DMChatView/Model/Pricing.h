//
//  Pricing.h
//  Fanatik
//
//  Created by Erick Martin on 11/26/15.
//  Copyright © 2015 Domikado. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Pricing : BaseModel

-(id)initWithDictionary:(NSDictionary *)jsonDict;
-(id)initWithFMResultSet:(FMResultSet *)result;
-(id)initWithCoder:(NSCoder *)decoder;
-(void)encodeWithCoder:(NSCoder *)encoder;

@property (nonatomic, assign) int pricingId;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *priced_type;
@property (nonatomic, assign) int stickerId;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, assign) int duration;
@property (nonatomic, assign) int volume;
@property (nonatomic, copy) NSString *info;
@property (nonatomic, copy) NSString *price_str;
@property (nonatomic, assign) int price_int;

@end