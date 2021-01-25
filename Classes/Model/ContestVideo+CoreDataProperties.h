//
//  ContestVideo+CoreDataProperties.h
//  Fanatik
//
//  Created by Erick Martin on 4/13/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ContestVideo.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContestVideo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *contest_video_url;
@property (nullable, nonatomic, retain) NSString *contest_video_thumbnail_url;
@property (nullable, nonatomic, retain) Contest *contest_video_contest;

@end

NS_ASSUME_NONNULL_END
