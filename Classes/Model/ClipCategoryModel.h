//
//  ClipSubCategory.h
//  Fanatik
//
//  Created by Erick Martin on 6/4/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClipSubCategoryModel.h"

@interface ClipCategoryModel : NSObject

@property (nonatomic, copy) NSString * clip_category_id;
@property (nonatomic, copy) NSString * clip_category_name;
@property (nonatomic, copy) NSString * clip_category_description;
@property (nonatomic, retain) NSMutableArray *clip_sub_category_array;

-(id)initWithDictionary:(NSDictionary *)jsonDict;

@end
