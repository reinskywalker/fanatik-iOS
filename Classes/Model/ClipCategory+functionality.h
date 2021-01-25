//
//  ClipCategory+functionality.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/13/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ClipCategory.h"
#import "ClipSubCategoryModel.h"
#import "ClipCategoryModel.h"

@interface ClipCategory (functionality)

+(RKEntityMapping *)myMapping;
+(void)getAllClipCategoriesWithAccessToken:(NSString *)accessToken
                                   success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultArray))success
                                   failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getAllClipCategoriesModelWithAccessToken:(NSString *)accessToken
                                        success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultArray))success
                                        failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getClipCategoryWithId:(NSString *)objID
                  pageNumber:(NSNumber *)pageNum
              andAccessToken:(NSString *)accessToken
                     success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultArray))success
                     failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void)getSubCategoryWithCategoryId:(NSString *)objID
                     andAccessToken:(NSString *)accessToken
                            success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultArray))success
                            failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;


@end
