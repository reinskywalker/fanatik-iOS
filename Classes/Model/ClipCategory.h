//
//  ClipCategory.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/13/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Clip;

@interface ClipCategory : NSManagedObject

@property (nonatomic, retain) NSString * clip_category_id;
@property (nonatomic, retain) NSString * clip_category_name;
@property (nonatomic, retain) NSString * clip_category_description;
@property (nonatomic, retain) NSSet *clipcategory_clip;
@end

@interface ClipCategory (CoreDataGeneratedAccessors)

- (void)addClipcategory_clipObject:(Clip *)value;
- (void)removeClipcategory_clipObject:(Clip *)value;
- (void)addClipcategory_clip:(NSSet *)values;
- (void)removeClipcategory_clip:(NSSet *)values;

@end
