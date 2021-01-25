//
//  Notification.h
//  Fanatik
//
//  Created by Erick Martin on 5/2/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum{
    NotifTypeNone = 0,
    NotifTypeLikeClip = 1,
    NotifTypeNewClipUploaded = 2,
    NotifTypeFollowUser = 3,
    NotifTypeCommentClip = 4,
    NotifTypeCommentEvent = 5,
    NotifTypeCommentThread = 6,
    NotifTypeMentionClip = 7,
    NotifTypeMentionTVChannel = 8
} NotifType;

@class Clip, Comment, Like, User, Mention;

NS_ASSUME_NONNULL_BEGIN

@interface Notification : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(RKEntityMapping *)myMapping;

+(void)getNotificationWithPageNumber:(NSNumber *)pageNum
                     withAccessToken:(NSString *)accessToken
                 success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultArray))success
                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)readNotificationWithNotifID:(NSNumber *)notifID
                     withAccessToken:(NSString *)accessToken
                             success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                             failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

-(NotifType)notifType;
-(NSString*)dateString;

@end

NS_ASSUME_NONNULL_END

#import "Notification+CoreDataProperties.h"
