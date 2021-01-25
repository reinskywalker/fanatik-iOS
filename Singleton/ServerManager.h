//
//  SettingsManager.h
//  Guestbook
//
//  Created by Teguh Hidayatullah on 12/17/2014.
//  Copyright 2014 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "UserWrapper.h"
#import <RestKit.h>
#define TheServerManager ([ServerManager sharedInstance])

extern NSString *const serverURL;

typedef enum {
    ContentClassNone = 0,
    ContentClassVideo,
    ContentClassLive
}ContentClass;
@interface ServerManager : NSObject {

}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(ServerManager)

-(void)requestAccessTokenWithCompletion:(void(^) (NSString *accessToken))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)registerWithUserDictionary:(NSDictionary *)userDict
                   withAccessToken:(NSString *)accessToken
                           success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                           failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

- (void)loginWithUserDictionary:(NSDictionary *)userDict
                withAccessToken:(NSString *)accessToken
                        success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                        failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure;
-(void)logoutWithCompletion:(void(^) (NSString *message))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)setGlobalHeaderForRequest:(NSMutableURLRequest *)request;
-(NSString *)RKRequestMethodString:(RKRequestMethod)requestMethod;
-(void)openPackagesForContentClass:(ContentClass)cont withID:(NSString*)contID;

-(void)getAllStickersWithCompletion:(void(^) (NSArray * stickersArray))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;
-(void)getStickerCategoriesWithCompletion:(void(^) (NSArray *categoriesArray))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;
-(void)getStickerByCategoryId:(int)catID withCompletion:(void(^) (StickerCategory *stickerCategory))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

-(void)getGoogleCampaignWithParams:(NSDictionary *)param withCompletion:(void(^) (id response))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
