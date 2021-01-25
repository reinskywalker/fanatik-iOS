//
//  StickerCategory.m
//  Fanatik
//
//  Created by Erick Martin on 11/26/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "StickerCategory.h"
@implementation StickerCategory

-(id)initWithDictionary:(NSDictionary *)jsonDict{
    if(self=[super init]){
        self.stickerCategoryId = [self intFromJSONObject:jsonDict[@"id"]];
        self.name = [self stringFromJSONObject:jsonDict[@"name"]];
        self.visible_at = [jsonDict objectForKey:@"visible_at"];
        self.enable_at = [jsonDict objectForKey:@"enable_at"];
        
        NSArray *stickerArr = jsonDict[@"stickers"];
        self.stickerArray = [NSMutableArray array];
        for(NSDictionary *stickerDict in stickerArr){
            Sticker *st = [[Sticker alloc] initWithDictionary:stickerDict];
            st.stickerCategoryId = self.stickerCategoryId;
            [TheDatabaseManager updateSticker:st];
            [self.stickerArray addObject:st];
        }
    }
    
    return self;
}


-(id)initWithFMResultSet:(FMResultSet *)result{
    if(self = [super init]){
        self.stickerCategoryId = [result intForColumn:@"stickerCategoryId"];
        self.name = [result stringForColumn:@"name"];
        self.visible_at = [result dateForColumn:@"visible_at"];
        self.enable_at = [result dateForColumn:@"enable_at"];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)decoder{
    if(self=[super init]){
        self.stickerCategoryId = [decoder decodeIntForKey:@"stickerCategoryId"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.visible_at = [decoder decodeObjectForKey:@"visible_at"];
        self.enable_at = [decoder decodeObjectForKey:@"enable_at"];
    }
    return self;
}


-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeInt:self.stickerCategoryId forKey:@"stickerCategoryId"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.visible_at forKey:@"visible_at"];
    [encoder encodeObject:self.enable_at forKey:@"enable_at"];
}

@end