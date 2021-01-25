//
//  THAWSAuthorization.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 9/8/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "THAWSAuthorization.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

#define SECRET_KEY @"GOlr544sqPa58KNZyPG/HCuALacw8D7z/Hpk6FI4"
#define ACCESS_KEY @"AKIAIDG3MGI7UEGGXL5A"
@implementation THAWSAuthorization
SYNTHESIZE_SINGLETON_FOR_CLASS(THAWSAuthorization)
+(NSString *)getAuthorizationHeaderForRequestMethod:(AWSRequestMethod)method mimeType:(NSString *)mimeType withDate:(NSDate *)aDate bucket:(NSString *)bucketName awsPath:(NSString *)uploadPath fileName:(NSString *)filename subresourceDict:(NSDictionary *)subresource{
    NSString *HTTPVerb;
    switch (method) {
        case AWSRequestMethodGET:
            HTTPVerb = @"GET";
            break;
        case AWSRequestMethodPOST:
            HTTPVerb = @"POST";
            break;
        case AWSRequestMethodPUT:
            HTTPVerb = @"PUT";
            break;
            
        default:
            break;
    }
    NSString *subresourcePath;
    if (subresource.count > 0) {
        subresourcePath = @"?";
    }
    NSArray *allKeys = [subresource allKeys];
    int i = 1;
    for (NSString *key in allKeys) {
        if (subresource[key] && ![subresource[key] isEqualToString:@""]) {
            subresourcePath = [subresourcePath stringByAppendingFormat:@"%@=%@", key, subresource[key]];
        }else{
            subresourcePath = [subresourcePath stringByAppendingFormat:@"%@", key];
        }
        if(i < [allKeys count]){
            subresourcePath = [subresourcePath stringByAppendingString:@"&"];
        }
        i++;
        
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"E, dd MMM yyyy HH:mm:ss ZZZZ";
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [df setTimeZone:timeZone];

    
    NSString *dateString = [df stringFromDate:aDate];
    NSString *stringToSign = [NSString stringWithFormat:@"%@\n\n%@\n%@\n/%@/%@%@%@",HTTPVerb, mimeType, dateString, bucketName, uploadPath, filename, subresourcePath];
    NSLog(@"stringtoSign = %@",stringToSign);
    NSData *signature = [[THAWSAuthorization sharedInstance] hmacsha1:[stringToSign stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] secret:SECRET_KEY];
    
    
    NSString *base64 = [[THAWSAuthorization sharedInstance] encodeDataToBase64:signature];
    NSString *authorization = [NSString stringWithFormat:@"AWS %@:%@",ACCESS_KEY, base64];
    return authorization;
}


- (NSData *)hmacsha1:(NSString *)data secret:(NSString *)key {
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMACData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    return HMACData;
}

- (NSString*)encodeDataToBase64:(NSData*)fromData
{
    NSString *base64String;
    base64String = [fromData base64EncodedStringWithOptions:kNilOptions];
    return base64String;
}




@end
