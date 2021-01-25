//
//  Settings.h
//  Fanatik
//
//  Created by Erick Martin on 5/17/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Settings : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(RKEntityMapping *)myMapping;
+(void)setUserSetting:(NSDictionary *)settingDict withAccessToken:(NSString *)accessToken
              success:(void(^)(RKObjectRequestOperation *operation, Settings *result))success
              failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END

#import "Settings+CoreDataProperties.h"
