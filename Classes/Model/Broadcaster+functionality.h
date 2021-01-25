//
//  Broadcaster+functionality.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 11/16/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "Broadcaster.h"
#define BroadcasterStatusLive @"live"
#define BroadcasterStatusOffline @"offline"

@interface Broadcaster (functionality)

+(void)getBroadcastersListWithAccessToken:(NSString *)accessToken
                               pageNumber:(NSNumber *)pageNum
                                  success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                                  failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end
