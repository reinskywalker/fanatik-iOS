//
//  chat.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/23/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "Sticker.h"
@implementation Sticker

-(id)initWithDictionary:(NSDictionary *)jsonDict{
    if(self=[super init]){
        self.stickerId = [self intFromJSONObject:jsonDict[@"id"]];
        self.artist_id = [self intFromJSONObject:jsonDict[@"artist_id"]];
        self.code = [self stringFromJSONObject:jsonDict[@"code"]];
        self.name = [self stringFromJSONObject:jsonDict[@"name"]];
        self.visible_at = [jsonDict objectForKey:@"visible_at"];
        self.enable_at = [jsonDict objectForKey:@"enable_at"];
        self.file = [self stringFromJSONObject:jsonDict[@"file"]];
        self.stickerCategoryId = [self intFromJSONObject:jsonDict[@"stickerCategoryId"]];
        
        NSArray *pricingArr = jsonDict[@"pricings"];
        self.pricingArray = [NSMutableArray array];
        for(NSDictionary *pricingDict in pricingArr){
            Pricing *pr = [[Pricing alloc] initWithDictionary:pricingDict];
            pr.stickerId = self.stickerId;
            [TheDatabaseManager updatePricing:pr];
            [self.pricingArray addObject:pr];
        }
    }
    return self;
}


-(id)initWithFMResultSet:(FMResultSet *)result{
    if(self = [super init]){
        self.stickerId = [result intForColumn:@"stickerId"];
        self.artist_id = [result intForColumn:@"artist_id"];
        self.code = [result stringForColumn:@"code"];
        self.name = [result stringForColumn:@"name"];
        self.visible_at = [result dateForColumn:@"visible_at"];
        self.enable_at = [result dateForColumn:@"enable_at"];
        self.file = [result stringForColumn:@"file"];
        self.stickerCategoryId = [result intForColumn:@"stickerCategoryId"];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)decoder{
    if(self=[super init]){
        self.stickerId = [decoder decodeIntForKey:@"stickerId"];
        self.artist_id = [decoder decodeIntForKey:@"artist_id"];
        self.code = [decoder decodeObjectForKey:@"code"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.visible_at = [decoder decodeObjectForKey:@"visible_at"];
        self.enable_at = [decoder decodeObjectForKey:@"enable_at"];
        self.file = [decoder decodeObjectForKey:@"file"];
        self.stickerCategoryId = [decoder decodeIntForKey:@"stickerCategoryId"];
    }
    return self;
}


-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeInt:self.stickerId forKey:@"stickerId"];
    [encoder encodeInt:self.artist_id forKey:@"artist_id"];
    [encoder encodeObject:self.code forKey:@"code"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.visible_at forKey:@"visible_at"];
    [encoder encodeObject:self.enable_at forKey:@"enable_at"];
    [encoder encodeObject:self.file forKey:@"file"];
    [encoder encodeInt:self.stickerCategoryId forKey:@"stickerCategoryId"];
}

-(NSDictionary *)getDictionary{
    NSDictionary *dict = @{
                           @"id":@(self.stickerId),
                           @"code":self.code,
                           @"name":self.name,
                           @"file":self.file
                           };
    return dict;
}

@end