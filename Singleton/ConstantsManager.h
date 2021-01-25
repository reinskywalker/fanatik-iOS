//
//  ConstantsManager.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/17/2014.
//  Copyright 2014 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

#define TheConstantsManager ([ConstantsManager sharedInstance])
#define ConstStr(strID) ([TheConstantsManager getStringProperty:strID])

typedef enum {
    StatusCodeForbidden = 403,
    StatusCodeExpired = 498,
    StatusCodeUnauthorized = 422,
    StatusCodePremiumContent = 402,
    StatusCodeNotLoggedIn = 401
}StatusCode;

@interface ConstantsManager : NSObject {
	NSDictionary* plist;
}

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(ConstantsManager)

@property (nonatomic, retain) NSDictionary *plist;

- (void) setFile:(NSString*)file;
- (NSString*)getStringProperty:(NSString*)property;
-(int)getIntegerProperty:(NSString *)property;
- (UIColor*)getColorProperty:(NSString*)property;
-(BOOL)hasProperty:(NSString*)property;

-(NSString *)facebookApiKey;

#define SERVER_URL() ([TheConstantsManager serverURL])
-(NSString *)serverURL;

#define FAYE_SERVER_URL() ([TheConstantsManager fayeServerURL])
-(NSString *)fayeServerURL;

-(NSString *)iosAppId;
-(int)timeInterval;

-(NSString *)defaultDateFormatMonthAndDateOnly;
-(NSString *)defaultDateTimeFormat;
-(NSString *)defaultDateFormat;
-(NSString *)defaultTimeFormat;


-(NSString *)parseClientKey;
-(NSString *)parseApplicationID;

-(NSString *)twitterCustomerKey;
-(NSString *)twitterCustomerSecret;
-(NSString *)wundergroundKey;

-(int)maxCloudRetryCount;

-(float)searchMiles;

-(NSString *)partnerName;
-(NSString *)apiVersion;
-(NSString *)baseAPI;
-(NSString *)chatURL;
-(NSString *)stickerURL;
-(NSString *)buildNumber;

#define GOOGLE_ID() ([TheConstantsManager googleClientID])
-(NSString *)googleClientID;

@end
