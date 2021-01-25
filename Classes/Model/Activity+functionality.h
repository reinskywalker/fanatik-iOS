//
//  Activity+functionality.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/24/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "Activity.h"

@interface Activity (functionality)

+(RKEntityMapping *)myMapping;

#pragma mark - GET
+(void)getAllActivitiesWithUserId:(NSString *)userID
                  withAccessToken:(NSString *)accessToken
                    andPageNumber:(NSNumber *)pageNum
                          success:(void(^)(RKObjectRequestOperation *operation, NSArray *objectArray))success
                          failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;
@end
