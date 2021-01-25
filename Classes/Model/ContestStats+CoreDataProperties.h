//
//  ContestStats+CoreDataProperties.h
//  Fanatik
//
//  Created by Erick Martin on 4/13/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ContestStats.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContestStats (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *contest_stats_videos;
@property (nullable, nonatomic, retain) NSNumber *contest_stats_contestants;
@property (nullable, nonatomic, retain) Contest *contest_stats_contest;

@end

NS_ASSUME_NONNULL_END
