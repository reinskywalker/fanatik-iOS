//
//  User+CoreDataProperties.h
//  Fanatik
//
//  Created by Erick Martin on 5/17/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *user_biography;
@property (nullable, nonatomic, retain) NSDate *user_dob;
@property (nullable, nonatomic, retain) NSString *user_email;
@property (nullable, nonatomic, retain) NSNumber *user_featured;
@property (nullable, nonatomic, retain) NSString *user_gender;
@property (nullable, nonatomic, retain) NSString *user_id;
@property (nullable, nonatomic, retain) NSString *user_info;
@property (nullable, nonatomic, retain) NSString *user_name;
@property (nullable, nonatomic, retain) NSString *user_phone;
@property (nullable, nonatomic, retain) NSNumber *user_tester;
@property (nullable, nonatomic, retain) NSString *user_type;
@property (nullable, nonatomic, retain) NSString *user_username;
@property (nullable, nonatomic, retain) Avatar *user_avatar;
@property (nullable, nonatomic, retain) NSSet<Clip *> *user_clip;
@property (nullable, nonatomic, retain) ClipGroup *user_clip_group;
@property (nullable, nonatomic, retain) Club *user_club;
@property (nullable, nonatomic, retain) NSSet<Comment *> *user_comment;
@property (nullable, nonatomic, retain) Contest *user_contest;
@property (nullable, nonatomic, retain) CoverImage *user_cover_image;
@property (nullable, nonatomic, retain) Event *user_event;
@property (nullable, nonatomic, retain) Like *user_like;
@property (nullable, nonatomic, retain) Notification *user_notification;
@property (nullable, nonatomic, retain) Socialization *user_socialization;
@property (nullable, nonatomic, retain) NSSet<Thread *> *user_thread;
@property (nullable, nonatomic, retain) NSOrderedSet<Thread *> *user_thread_comments;
@property (nullable, nonatomic, retain) Timeline *user_timeline;
@property (nullable, nonatomic, retain) UserStats *user_user_stats;
@property (nullable, nonatomic, retain) Settings *user_settings;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addUser_clipObject:(Clip *)value;
- (void)removeUser_clipObject:(Clip *)value;
- (void)addUser_clip:(NSSet<Clip *> *)values;
- (void)removeUser_clip:(NSSet<Clip *> *)values;

- (void)addUser_commentObject:(Comment *)value;
- (void)removeUser_commentObject:(Comment *)value;
- (void)addUser_comment:(NSSet<Comment *> *)values;
- (void)removeUser_comment:(NSSet<Comment *> *)values;

- (void)addUser_threadObject:(Thread *)value;
- (void)removeUser_threadObject:(Thread *)value;
- (void)addUser_thread:(NSSet<Thread *> *)values;
- (void)removeUser_thread:(NSSet<Thread *> *)values;

- (void)insertObject:(Thread *)value inUser_thread_commentsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromUser_thread_commentsAtIndex:(NSUInteger)idx;
- (void)insertUser_thread_comments:(NSArray<Thread *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeUser_thread_commentsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInUser_thread_commentsAtIndex:(NSUInteger)idx withObject:(Thread *)value;
- (void)replaceUser_thread_commentsAtIndexes:(NSIndexSet *)indexes withUser_thread_comments:(NSArray<Thread *> *)values;
- (void)addUser_thread_commentsObject:(Thread *)value;
- (void)removeUser_thread_commentsObject:(Thread *)value;
- (void)addUser_thread_comments:(NSOrderedSet<Thread *> *)values;
- (void)removeUser_thread_comments:(NSOrderedSet<Thread *> *)values;

@end

NS_ASSUME_NONNULL_END
