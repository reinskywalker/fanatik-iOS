//
//  ClubList+functionality.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/11/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ClubList.h"

@interface ClubList (functionality)

+ (RKEntityMapping *)myMapping;
+ (void)reqClubListWithAccesToken:(NSString *)accessToken
                    andPageNumber:(NSNumber *)pageNum
                          success:(void(^)(RKObjectRequestOperation *operation, ClubList *result,
                                           NSArray *myClubsArray,
                                           NSArray *recommendedClubsArray))success
                          failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;
@end
