//
//  Actor.h
//  Fanatik
//
//  Created by Erick Martin on 6/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Avatar, Timeline;

@interface Actor : NSManagedObject

@property (nonatomic, retain) NSString * actor_email;
@property (nonatomic, retain) NSString * actor_id;
@property (nonatomic, retain) NSString * actor_name;
@property (nonatomic, retain) NSString * actor_type;
@property (nonatomic, retain) Avatar *actor_avatar;
@property (nonatomic, retain) NSSet *actor_timeline;
@end

@interface Actor (CoreDataGeneratedAccessors)

- (void)addActor_timelineObject:(Timeline *)value;
- (void)removeActor_timelineObject:(Timeline *)value;
- (void)addActor_timeline:(NSSet *)values;
- (void)removeActor_timeline:(NSSet *)values;

@end
