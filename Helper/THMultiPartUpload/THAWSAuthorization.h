//
//  THAWSAuthorization.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 9/8/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    AWSRequestMethodGET = 0,
    AWSRequestMethodPOST,
    AWSRequestMethodPUT
}AWSRequestMethod;

@interface THAWSAuthorization : NSObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(THAWSAuthorization)
+(NSString *)getAuthorizationHeaderForRequestMethod:(AWSRequestMethod)method mimeType:(NSString *)mimeType withDate:(NSDate *)aDate bucket:(NSString *)bucketName awsPath:(NSString *)uploadPath fileName:(NSString *)filename subresourceDict:(NSDictionary *)subresource;
@end
