//
//  ClipGroup.h
//  Fanatik
//
//  Created by Erick Martin on 5/30/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Clip, Thumbnail, User;

NS_ASSUME_NONNULL_BEGIN

@interface ClipGroup : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(RKEntityMapping *)myMapping;

+(void)getDashboardWithAccessToken:(NSString *)accessToken
                           success:(void(^)(RKObjectRequestOperation *operation, NSArray *clipsArray))success
                           failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getClipGroupWithCategoryId:(NSString *)catID
                   andAccessToken:(NSString *)accessToken
                          success:(void(^)(RKObjectRequestOperation *operation, NSArray *clipsArray))success
                          failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getClipsWithClipGroupId:(NSString *)clipGroupId
                andAccessToken:(NSString *)accessToken
                    andPageNum:(NSNumber *)pageNum
                       success:(void(^)(RKObjectRequestOperation *operation, ClipGroup *clipGroup))success
                       failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+ (NSArray *)fetchDashboardMenu;

@end

NS_ASSUME_NONNULL_END

#import "ClipGroup+CoreDataProperties.h"
