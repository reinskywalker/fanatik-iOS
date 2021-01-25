//
//  BroadcasterOnline.h
//  Fanatik
//
//  Created by Erick Martin on 3/2/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface BroadcasterOnline : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(void)getHistoryBroadcastersListWithAccessToken:(NSString *)accessToken
                                      pageNumber:(NSNumber *)pageNum
                                         success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                                         failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;
@end

NS_ASSUME_NONNULL_END

#import "BroadcasterOnline+CoreDataProperties.h"
