//
//  Clip.h
//  Fanatik
//
//  Created by Erick Martin on 4/19/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>

@class ClipCategory, ClipGroup, ClipStats, Comment, Contest, ContestWinners, Event, Pagination, Playlist, Shareable, Timeline, User, Video, Like, Notification;

NS_ASSUME_NONNULL_BEGIN

@interface Clip : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+ (RKEntityMapping *)myMapping;
+ (RKEntityMapping *)baseMapping;
+ (RKEntityMapping *)relatedClipMapping;

+(void)getClipWithUserId:(NSString *)userID
           andPageNumber:(NSNumber *)pageNum
         withAccessToken:(NSString *)accessToken
                 success:(void(^)(RKObjectRequestOperation *operation, NSArray *clipsArray))success
                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;


+(void)getClipWithId:(NSNumber *)clipID andPageNumber:(NSNumber *)page
     withAccessToken:(NSString *)accessToken
             success:(void(^)(RKObjectRequestOperation *operation, Clip *object))success
             failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)searchClipWithQuery:(NSString *)q
             andPageNumber:(NSNumber *)pageNum
           withAccessToken:(NSString *)accessToken
                   success:(void(^)(RKObjectRequestOperation *operation, NSArray *clipsArray))success
                   failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getContestClipsWithContestID:(NSNumber *)contestID
                    withAccessToken:(NSString *)accessToken
                         andPageNum:(NSNumber *)pageNum
                            success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                            failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END

#import "Clip+CoreDataProperties.h"
