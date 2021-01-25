//
//  SectionMenu+functionality.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "SectionMenu.h"

@interface SectionMenu (functionality)

+(RKEntityMapping *)myMapping;
+ (void)getSectionMenuWithAccessToken:(NSString *)accessToken
                              success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultArray))success
                              failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

+ (NSArray *)fetchSectionMenu;
@end
