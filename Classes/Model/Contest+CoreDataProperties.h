//
//  Contest+CoreDataProperties.h
//  Fanatik
//
//  Created by Erick Martin on 4/14/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Contest.h"

NS_ASSUME_NONNULL_BEGIN

@interface Contest (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *contest_avatar_url;
@property (nullable, nonatomic, retain) NSString *contest_badge_background;
@property (nullable, nonatomic, retain) NSString *contest_badge_color;
@property (nullable, nonatomic, retain) NSString *contest_badge_text;
@property (nullable, nonatomic, retain) NSString *contest_cover_image_url;
@property (nullable, nonatomic, retain) NSString *contest_description;
@property (nullable, nonatomic, retain) NSDate *contest_end_time;
@property (nullable, nonatomic, retain) NSNumber *contest_expired;
@property (nullable, nonatomic, retain) NSNumber *contest_id;
@property (nullable, nonatomic, retain) NSString *contest_name;
@property (nullable, nonatomic, retain) NSDate *contest_start_time;
@property (nullable, nonatomic, retain) NSNumber *contest_visible;
@property (nullable, nonatomic, retain) NSOrderedSet<Clip *> *contest_clips;
@property (nullable, nonatomic, retain) ContestStats *contest_contest_stats;
@property (nullable, nonatomic, retain) ContestVideo *contest_contest_video;
@property (nullable, nonatomic, retain) NSOrderedSet<ContestWinners *> *contest_contest_winners;
@property (nullable, nonatomic, retain) NSOrderedSet<User *> *contest_user;
@property (nullable, nonatomic, retain) Pagination *contest_clips_pagination;
@property (nullable, nonatomic, retain) Pagination *contest_user_pagination;

@end

@interface Contest (CoreDataGeneratedAccessors)

- (void)insertObject:(Clip *)value inContest_clipsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromContest_clipsAtIndex:(NSUInteger)idx;
- (void)insertContest_clips:(NSArray<Clip *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeContest_clipsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInContest_clipsAtIndex:(NSUInteger)idx withObject:(Clip *)value;
- (void)replaceContest_clipsAtIndexes:(NSIndexSet *)indexes withContest_clips:(NSArray<Clip *> *)values;
- (void)addContest_clipsObject:(Clip *)value;
- (void)removeContest_clipsObject:(Clip *)value;
- (void)addContest_clips:(NSOrderedSet<Clip *> *)values;
- (void)removeContest_clips:(NSOrderedSet<Clip *> *)values;

- (void)insertObject:(ContestWinners *)value inContest_contest_winnersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromContest_contest_winnersAtIndex:(NSUInteger)idx;
- (void)insertContest_contest_winners:(NSArray<ContestWinners *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeContest_contest_winnersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInContest_contest_winnersAtIndex:(NSUInteger)idx withObject:(ContestWinners *)value;
- (void)replaceContest_contest_winnersAtIndexes:(NSIndexSet *)indexes withContest_contest_winners:(NSArray<ContestWinners *> *)values;
- (void)addContest_contest_winnersObject:(ContestWinners *)value;
- (void)removeContest_contest_winnersObject:(ContestWinners *)value;
- (void)addContest_contest_winners:(NSOrderedSet<ContestWinners *> *)values;
- (void)removeContest_contest_winners:(NSOrderedSet<ContestWinners *> *)values;

- (void)insertObject:(User *)value inContest_userAtIndex:(NSUInteger)idx;
- (void)removeObjectFromContest_userAtIndex:(NSUInteger)idx;
- (void)insertContest_user:(NSArray<User *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeContest_userAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInContest_userAtIndex:(NSUInteger)idx withObject:(User *)value;
- (void)replaceContest_userAtIndexes:(NSIndexSet *)indexes withContest_user:(NSArray<User *> *)values;
- (void)addContest_userObject:(User *)value;
- (void)removeContest_userObject:(User *)value;
- (void)addContest_user:(NSOrderedSet<User *> *)values;
- (void)removeContest_user:(NSOrderedSet<User *> *)values;

@end

NS_ASSUME_NONNULL_END
