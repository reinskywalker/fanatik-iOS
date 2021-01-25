//
//  Sticker.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/23/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Sticker : BaseModel

-(id)initWithDictionary:(NSDictionary *)jsonDict;
-(id)initWithFMResultSet:(FMResultSet *)result;
-(id)initWithCoder:(NSCoder *)decoder;
-(void)encodeWithCoder:(NSCoder *)encoder;

-(NSDictionary *)getDictionary;

@property (nonatomic, assign) int stickerId;
@property (nonatomic, assign) int artist_id;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSDate *visible_at;
@property (nonatomic, retain) NSDate *enable_at;
@property (nonatomic, copy) NSString *file;
@property (nonatomic, assign) int stickerCategoryId;
@property (nonatomic, retain) NSMutableArray *pricingArray;

@end