//
//  ClipGroup+CoreDataProperties.h
//  Fanatik
//
//  Created by Erick Martin on 7/27/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ClipGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface ClipGroup (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *clip_group_description;
@property (nullable, nonatomic, retain) NSNumber *clip_group_id;
@property (nullable, nonatomic, retain) NSString *clip_group_name;
@property (nullable, nonatomic, retain) NSNumber *clip_group_position;
@property (nullable, nonatomic, retain) NSOrderedSet<Clip *> *clip_group_clips;
@property (nullable, nonatomic, retain) Thumbnail *clip_group_thumbnail;
@property (nullable, nonatomic, retain) User *clip_group_user;

@end

@interface ClipGroup (CoreDataGeneratedAccessors)

- (void)insertObject:(Clip *)value inClip_group_clipsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromClip_group_clipsAtIndex:(NSUInteger)idx;
- (void)insertClip_group_clips:(NSArray<Clip *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeClip_group_clipsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInClip_group_clipsAtIndex:(NSUInteger)idx withObject:(Clip *)value;
- (void)replaceClip_group_clipsAtIndexes:(NSIndexSet *)indexes withClip_group_clips:(NSArray<Clip *> *)values;
- (void)addClip_group_clipsObject:(Clip *)value;
- (void)removeClip_group_clipsObject:(Clip *)value;
- (void)addClip_group_clips:(NSOrderedSet<Clip *> *)values;
- (void)removeClip_group_clips:(NSOrderedSet<Clip *> *)values;

@end

NS_ASSUME_NONNULL_END
