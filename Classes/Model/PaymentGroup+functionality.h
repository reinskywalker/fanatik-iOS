//
//  PaymentGroup+functionality.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/4/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "PaymentGroup.h"

@interface PaymentGroup (functionality)

+(RKEntityMapping *)myMapping;
+(void)getPaymentGroupWithAccessToken:(NSString *)accessToken
                              success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                              failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;
@end
