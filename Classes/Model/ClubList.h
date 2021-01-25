//
//  ClubList.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/11/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Club;

@interface ClubList : NSManagedObject

@property (nonatomic, retain) NSOrderedSet *clublist_my_clubs;
@property (nonatomic, retain) NSOrderedSet *clublist_recommended_clubs;
@end

@interface ClubList (CoreDataGeneratedAccessors)

- (void)insertObject:(Club *)value inClublist_my_clubsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromClublist_my_clubsAtIndex:(NSUInteger)idx;
- (void)insertClublist_my_clubs:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeClublist_my_clubsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInClublist_my_clubsAtIndex:(NSUInteger)idx withObject:(Club *)value;
- (void)replaceClublist_my_clubsAtIndexes:(NSIndexSet *)indexes withClublist_my_clubs:(NSArray *)values;
- (void)addClublist_my_clubsObject:(Club *)value;
- (void)removeClublist_my_clubsObject:(Club *)value;
- (void)addClublist_my_clubs:(NSOrderedSet *)values;
- (void)removeClublist_my_clubs:(NSOrderedSet *)values;
- (void)insertObject:(Club *)value inClublist_recommended_clubsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromClublist_recommended_clubsAtIndex:(NSUInteger)idx;
- (void)insertClublist_recommended_clubs:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeClublist_recommended_clubsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInClublist_recommended_clubsAtIndex:(NSUInteger)idx withObject:(Club *)value;
- (void)replaceClublist_recommended_clubsAtIndexes:(NSIndexSet *)indexes withClublist_recommended_clubs:(NSArray *)values;
- (void)addClublist_recommended_clubsObject:(Club *)value;
- (void)removeClublist_recommended_clubsObject:(Club *)value;
- (void)addClublist_recommended_clubs:(NSOrderedSet *)values;
- (void)removeClublist_recommended_clubs:(NSOrderedSet *)values;
@end
