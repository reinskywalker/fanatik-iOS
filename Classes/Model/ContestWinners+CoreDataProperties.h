//
//  ContestWinners+CoreDataProperties.h
//  Fanatik
//
//  Created by Erick Martin on 4/13/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ContestWinners.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContestWinners (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *contest_winners_id;
@property (nullable, nonatomic, retain) NSString *contest_winners_category;
@property (nullable, nonatomic, retain) NSNumber *contest_winners_position;
@property (nullable, nonatomic, retain) NSString *contest_winners_badge_url;
@property (nullable, nonatomic, retain) Clip *contest_winners_clip;
@property (nullable, nonatomic, retain) Contest *contest_winners_contest;

@end

NS_ASSUME_NONNULL_END
