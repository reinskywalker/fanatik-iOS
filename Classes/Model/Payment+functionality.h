//
//  Payment+functionality.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/4/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "Payment.h"

@interface Payment (functionality)

+(RKEntityMapping *)myMapping;
+(void)orderWithPackageIdArray:(NSArray *)packageIdArray
                  andPaymentId:(NSString *)paymentID
               withAccessToken:(NSString *)accessToken
                 andCompletion:(void(^) (NSString *orderID))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
