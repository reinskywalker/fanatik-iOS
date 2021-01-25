//
//  ClipSubCategory.m
//  Fanatik
//
//  Created by Erick Martin on 6/4/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ClipCategoryModel.h"

@implementation ClipCategoryModel
@synthesize clip_category_description, clip_category_id, clip_category_name, clip_sub_category_array;

-(id)initWithDictionary:(NSDictionary *)jsonDict{
    if(self=[super init]){
        self.clip_category_id = jsonDict[@"id"];
        self.clip_category_name = jsonDict[@"name"];
        self.clip_category_description = [jsonDict[@"description"] isKindOfClass:[NSNull class]]?@"":jsonDict[@"description"];
        
        self.clip_sub_category_array = [NSMutableArray array];
        for(NSDictionary *subCatDict in jsonDict[@"sub_categories"]){
            ClipSubCategoryModel *subCatModel = [[ClipSubCategoryModel alloc] initWithDictionary:subCatDict];
            [self.clip_sub_category_array addObject:subCatModel];
        }
    }
    return self;
}

@end
