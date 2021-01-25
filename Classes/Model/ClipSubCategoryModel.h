//
//  ClipSubCategory.h
//  Fanatik
//
//  Created by Erick Martin on 6/4/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClipSubCategoryModel : NSObject

@property (nonatomic, copy) NSString * clip_subcategory_id;
@property (nonatomic, copy) NSString * clip_subcategory_name;
@property (nonatomic, copy) NSString * clip_subcategory_description;
@property (nonatomic, assign) BOOL isChecked;

-(id)initWithDictionary:(NSDictionary *)jsonDict;

@end
