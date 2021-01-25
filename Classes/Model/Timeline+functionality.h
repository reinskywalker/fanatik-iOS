//
//  Timeline+functionality.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "Timeline.h"

@interface Timeline (functionality)

+ (RKEntityMapping *)myMapping;

+(void)getTimelineWithAccessToken:(NSString *)accessToken
                    andPageNumber:(NSNumber *)pageNum
                          success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                          failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end
