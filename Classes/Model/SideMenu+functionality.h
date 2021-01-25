//
//  SideMenu+functionality.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "SideMenu.h"

@interface SideMenu (functionality)

+ (void)getSideMenuWithAccessToken:(NSString *)accessToken
                              success:(void(^)(RKObjectRequestOperation *operation, SideMenu *object))success
                              failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;
+(RKEntityMapping *)myMapping;

@end
