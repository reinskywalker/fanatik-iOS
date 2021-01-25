//
//  Package+functionality.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/19/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "Package.h"

@interface Package (functionality)

+(RKEntityMapping *)myMapping;
+(void)getPackageListWithAccessToken:(NSString *)accessToken
                             success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                             failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;
+(void)getUserPackageListWithAccessToken:(NSString *)accessToken
                                 success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                                 failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end
