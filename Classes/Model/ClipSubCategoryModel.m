//
//  ClipSubCategory.m
//  Fanatik
//
//  Created by Erick Martin on 6/4/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ClipSubCategoryModel.h"

@implementation ClipSubCategoryModel
@synthesize clip_subcategory_description, clip_subcategory_id, clip_subcategory_name;

-(id)initWithDictionary:(NSDictionary *)jsonDict{
    if(self=[super init]){
        self.clip_subcategory_id = jsonDict[@"id"];
        self.clip_subcategory_name = jsonDict[@"name"];
        self.clip_subcategory_description = [jsonDict[@"description"] isKindOfClass:[NSNull class]]?@"":jsonDict[@"description"];
        self.isChecked = NO;
    }
    return self;
}

@end
