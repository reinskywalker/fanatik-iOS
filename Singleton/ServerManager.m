//
//  SettingsManager.m
//  Guestbook
//
//  Created by Teguh Hidayatullah on 12/17/2014.
//  Copyright 2014 Domikado. All rights reserved.
//

#import "ServerManager.h"
#import "Sticker.h"
#import "NSDictionary+UrlEncoding.h"

@implementation ServerManager
SYNTHESIZE_SINGLETON_FOR_CLASS(ServerManager)


-(id)init {
	if (self = [super init]) {
        
    }
	return self;
}


#pragma mark - Access Token
-(void)requestAccessTokenWithCompletion:(void(^) (NSString *accessToken))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:TheConstantsManager.serverURL]];
    NSDateFormatter *df = [TheAppDelegate defaultDateFormatter];
    NSString *dateString = [df stringFromDate:[NSDate date]];

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"313a088384ccb0aab05346de38c8bbe0", @"app_id",
                            dateString, @"time",
                            [[NSString stringWithFormat:@"313a088384ccb0aab05346de38c8bbe09b311fe9cad5e944940e7d9d18b253cc%@",dateString] MD5], @"hash",
                            nil];
    if(SESSION_TOKEN() && ![TheSettingsManager.sessionToken isEqualToString:@""]){
        params[@"session"] = TheSettingsManager.sessionToken;
        NSLog(@"session token : %@",TheSettingsManager.sessionToken);
    }
    
    NSMutableURLRequest *req = [manager requestWithObject:self method:RKRequestMethodPOST path:@"access-tokens" parameters:params];
    [TheServerManager setGlobalHeaderForRequest:req];
    [TheAppDelegate writeLog:[NSString stringWithFormat:@"%@access-tokens",TheConstantsManager.serverURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:req];
    [operation start];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        

        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSString *resp = [NSString stringWithFormat:@"Response (request access token)"];
        WRITE_LOG(resp);
        WRITE_LOG(jsonDict);
        [TheSettingsManager saveAccessToken:jsonDict[@"access_token"][@"token"]];
        if(complete){
            complete(jsonDict[@"access_token"][@"token"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSString *resp = [NSString stringWithFormat:@"Response (request access token)"];
        WRITE_LOG(resp);
        WRITE_LOG(jsonDict);
        WRITE_LOG(@"ERROR");
        [TheAppDelegate writeLog:error.description];
        NSArray *messageArray = jsonDict[@"error"][@"messages"];
        NSString *message = [messageArray lastObject];
        if([message isEqualToString:@"Session Not Valid"]){
            [TheSettingsManager removeAccessToken];
            [TheSettingsManager removeSessionToken];
            [TheSettingsManager removeCurrentUserId];
            [TheSettingsManager resetSideMenuArray];
            [TheAppDelegate logoutSuccess];
            
        }
        if(failure){
            failure(operation, error);
        }
    }];


}

#pragma mark - LOGIN
- (void)loginWithUserDictionary:(NSDictionary *)userDict
              withAccessToken:(NSString *)accessToken
                     success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                     failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    
    RKEntityMapping *mappingEntity = [User userMapping];
    
    RKRequestMethod requestMethod = RKRequestMethodPOST;

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, @"access_token",
                                   userDict, @"user",
                                   nil];
    NSString *pathPattern = @"";
    BOOL isSocmed = userDict[@"provider"] && ![userDict[@"provider"] isEqualToString:@""]? YES : NO;
    if(isSocmed){
        pathPattern = @"auth/connect";
        
    }else{
        pathPattern = @"auth/login";
    }

    //Session Token Mapping
    RKEntityMapping *sessionTokenMapping = [RKEntityMapping mappingForEntityForName:@"SessionToken" inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    [sessionTokenMapping addAttributeMappingsFromDictionary:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                             @"session_token", @"session",
                                                             nil]];
    //===
    
    //Access Token Mapping
    RKEntityMapping *accessTokenMapping = [RKEntityMapping mappingForEntityForName:@"AccessToken" inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    [accessTokenMapping addAttributeMappingsFromDictionary:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                             @"access_token", @"token",
                                                             nil]];
    //===
    
    
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:mappingEntity
                                                 method:requestMethod
                                            pathPattern:pathPattern
                                                keyPath:@"user"
                                            statusCodes:statusCodes];
    
    //Session Token Response Descriptor
    RKResponseDescriptor *sessionResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:sessionTokenMapping
                                                 method:requestMethod
                                            pathPattern:pathPattern
                                                keyPath:@"session_token"
                                            statusCodes:statusCodes];
    //====
    
    //Access Token Response Descriptor
    RKResponseDescriptor *accessResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:accessTokenMapping
                                                 method:requestMethod
                                            pathPattern:pathPattern
                                                keyPath:@"access_token"
                                            statusCodes:statusCodes];
    //====
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:SERVER_URL()]];
    
    NSMutableURLRequest *request = [manager requestWithObject:self method:requestMethod path:pathPattern parameters:params];
    [TheServerManager setGlobalHeaderForRequest:request];
    NSArray *responseDescriptorArray = [NSArray arrayWithObjects:responseDescriptor, sessionResponseDescriptor, accessResponseDescriptor, nil];
    [manager addResponseDescriptorsFromArray:responseDescriptorArray];
    manager.managedObjectStore = [TheDatabaseManager managedObjectStore];
    
    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor, sessionResponseDescriptor, accessResponseDescriptor]];
    operation.managedObjectContext  = [TheDatabaseManager managedObjectStore].mainQueueManagedObjectContext;
    operation.managedObjectCache    = [TheDatabaseManager managedObjectStore].managedObjectCache;
    
    
    WRITE_LOG(@"=======================");
    NSString *paramString = [NSString stringWithFormat:@"param: %@",params];
    NSString *urlString = [NSString stringWithFormat:@"URL: %@%@",SERVER_URL(), pathPattern];
    WRITE_LOG(paramString);
    WRITE_LOG(urlString);
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        WRITE_LOG(result.dictionary);
        NSString *token = [(NSManagedObject*) result.dictionary[@"access_token"] valueForKey:@"access_token"];
        NSString *session = [(NSManagedObject*) result.dictionary[@"session_token"] valueForKey:@"session_token"];
        
        User *userObj = [result firstObject];
        NSString *userID = userObj.user_id;
        [TheSettingsManager saveAccessToken:token];
        [TheSettingsManager saveSessionToken:session];
        [TheSettingsManager saveCurrentUserId:userID];
        if(success){
            success(operation, result);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        if(failure){
            failure(operation, error);
        }
    }];
    
    [operation start];
}

#pragma mark - LOGOUT

-(void)logoutWithCompletion:(void(^) (NSString *message))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:TheConstantsManager.serverURL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   ACCESS_TOKEN(), @"access_token",
                                   nil];
    
    
    NSMutableURLRequest *req = [manager requestWithObject:self method:RKRequestMethodPOST path:@"auth/logout" parameters:params];
    [TheServerManager setGlobalHeaderForRequest:req];
    [TheAppDelegate writeLog:[NSString stringWithFormat:@"logout: %@",TheConstantsManager.serverURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:req];
    [operation start];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [TheAppDelegate writeLog:[operation responseString]];
        [TheSettingsManager removeAccessToken];
        [TheSettingsManager removeSessionToken];
        [TheSettingsManager removeCurrentUserId];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        if(complete){
            complete(jsonDict[@"message"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [TheAppDelegate writeLog:[operation responseString]];
        if(failure){
            failure(operation, error);
        }
    }];
}

#pragma mark - REGISTER

- (void)registerWithUserDictionary:(NSDictionary *)userDict
                withAccessToken:(NSString *)accessToken
                        success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                        failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    
    RKEntityMapping *mappingEntity = [User userMapping];
    
    RKRequestMethod requestMethod = RKRequestMethodPOST;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, @"access_token",
                                   userDict, @"user",
                                   nil];
    NSString *pathPattern = @"user-registrations";
    
    
    //Session Token Mapping
    RKEntityMapping *sessionTokenMapping = [RKEntityMapping mappingForEntityForName:@"SessionToken" inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    
    [sessionTokenMapping addAttributeMappingsFromDictionary:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                             @"session_token", @"session",
                                                             nil]];
    //===
    
    //Access Token Mapping
    RKEntityMapping *accessTokenMapping = [RKEntityMapping mappingForEntityForName:@"AccessToken" inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    [accessTokenMapping addAttributeMappingsFromDictionary:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                            @"access_token", @"token",
                                                            nil]];
    //===
    
    
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:mappingEntity
                                                 method:requestMethod
                                            pathPattern:pathPattern
                                                keyPath:@"user"
                                            statusCodes:statusCodes];
    
    //Session Token Response Descriptor
    RKResponseDescriptor *sessionResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:sessionTokenMapping
                                                 method:requestMethod
                                            pathPattern:pathPattern
                                                keyPath:@"session_token"
                                            statusCodes:statusCodes];
    //====
    
    //Access Token Response Descriptor
    RKResponseDescriptor *accessResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:accessTokenMapping
                                                 method:requestMethod
                                            pathPattern:pathPattern
                                                keyPath:@"access_token"
                                            statusCodes:statusCodes];
    //====
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:SERVER_URL()]];
    
    NSMutableURLRequest *request = [manager requestWithObject:self method:requestMethod path:pathPattern parameters:params];
    [TheServerManager setGlobalHeaderForRequest:request];
    NSArray *responseDescriptorArray = [NSArray arrayWithObjects:responseDescriptor, sessionResponseDescriptor, accessResponseDescriptor, nil];
    [manager addResponseDescriptorsFromArray:responseDescriptorArray];
    manager.managedObjectStore = [TheDatabaseManager managedObjectStore];
    
    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor, sessionResponseDescriptor, accessResponseDescriptor]];
    operation.managedObjectContext  = [TheDatabaseManager managedObjectStore].mainQueueManagedObjectContext;
    operation.managedObjectCache    = [TheDatabaseManager managedObjectStore].managedObjectCache;
    
    
    WRITE_LOG(@"=======================");
    NSString *paramString = [NSString stringWithFormat:@"param: %@",params];
    NSString *urlString = [NSString stringWithFormat:@"URL: %@%@",SERVER_URL(), pathPattern];
    WRITE_LOG(paramString);
    WRITE_LOG(urlString);
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        WRITE_LOG(result.dictionary);
        NSString *token = [(NSManagedObject*) result.dictionary[@"access_token"] valueForKey:@"access_token"];
        NSString *session = [(NSManagedObject*) result.dictionary[@"session_token"] valueForKey:@"session_token"];
        
        User *userObj = [result firstObject];
        NSString *userID = userObj.user_id;
        [TheSettingsManager saveAccessToken:token];
        [TheSettingsManager saveSessionToken:session];
        [TheSettingsManager saveCurrentUserId:userID];
        if(success){
            success(operation, result);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        if(failure){
            failure(operation, error);
        }
    }];
    
    [operation start];
}

#pragma mark - Convenient Method

- (void)setGlobalHeaderForRequest:(NSMutableURLRequest *)request{
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    NSString *appVersion = infoDictionary[@"CFBundleShortVersionString"];
    
    if(appVersion != nil){
        [request setValue:appVersion forHTTPHeaderField:@"APP_VERSION"];
    }
    
    [request setValue:SYSTEM_VERSION forHTTPHeaderField:@"OS_VERSION"];
    [request setValue:@"ios" forHTTPHeaderField:@"OS"];
    [request setValue:TheConstantsManager.buildNumber forHTTPHeaderField:@"BUILDNUMBER"];
    
#ifdef DEBUG
    if(TheSettingsManager.debugOSVersion && ![TheSettingsManager.debugOSVersion isEqualToString:@""]){
        [request setValue:TheSettingsManager.debugOSVersion forHTTPHeaderField:@"OS_VERSION"];
    }
    if(TheSettingsManager.debugAppVersion && ![TheSettingsManager.debugAppVersion isEqualToString:@""]){
        [request setValue:TheSettingsManager.debugAppVersion forHTTPHeaderField:@"APP_VERSION"];
    }
#endif
    
    NSLog(@"header sent : %@", [request allHTTPHeaderFields]);
    
}

-(NSString *)RKRequestMethodString:(RKRequestMethod)requestMethod{
    if(requestMethod == RKRequestMethodGET){
        return @"RKRequestMethodGET";
    }else if (requestMethod == RKRequestMethodHEAD){
        return @"RKRequestMethodHEAD";
    }else if (requestMethod == RKRequestMethodOPTIONS){
        return @"RKRequestMethodOPTIONS";
    }else if (requestMethod == RKRequestMethodDELETE){
        return @"RKRequestMethodDELETE";
    }else if (requestMethod == RKRequestMethodPATCH){
        return @"RKRequestMethodPATCH";
    }else if (requestMethod == RKRequestMethodPOST){
        return @"RKRequestMethodPOST";
    }else if (requestMethod == RKRequestMethodPUT){
        return @"RKRequestMethodPUT";
    }
    
    return @"UNKNOWN";
}

-(void)openPackagesForContentClass:(ContentClass)cont withID:(NSString*)contID{
    NSString *contClass;
    switch (cont) {
        case ContentClassVideo:
            contClass = @"video";
            break;
        case ContentClassLive:
            contClass = @"live";
            break;
            
        default:
            contClass = @"";
            break;
    }

    NSString *packageURL;
    if ((contID && ![contID isEqualToString:@""]) && (contClass && ![contClass isEqualToString:@""])) {
        packageURL = [NSString stringWithFormat:@"%@/packages/%@/%@?access_token=%@", ConstStr(@"website_url"),contClass, contID,ACCESS_TOKEN()];
    }else{
        packageURL = [NSString stringWithFormat:@"%@/packages?access_token=%@", ConstStr(@"website_url"),ACCESS_TOKEN()];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:packageURL]];
}

#pragma mark - GAI Google Campaign

-(void)getGoogleCampaignWithParams:(NSDictionary *)param withCompletion:(void(^) (id response))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
//    NSDictionary *jsonDictionary = @{@"referrer": param};
    NSString *queryString = [param urlEncodedString];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/campaigns/tracking/ios?%@", TheConstantsManager.baseAPI, queryString]]];

    NSMutableURLRequest *req = [manager requestWithObject:self method:RKRequestMethodGET path:@"" parameters:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:req];
    [operation start];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        WRITE_LOG(responseObject);
        WRITE_LOG(jsonDict);
        
        if(complete){
            complete(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSString *resp = [NSString stringWithFormat:@"Response (getGoogleCampaigns)"];
        WRITE_LOG(resp);
        WRITE_LOG(jsonDict);
        WRITE_LOG(@"ERROR");
        [TheAppDelegate writeLog:error.description];
        
        if(failure){
            failure(operation, error);
        }
    }];
}

#pragma mark - DMChatView Stickers
-(void)getStickerCategoriesWithCompletion:(void(^) (NSArray *categoriesArray))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableArray *resultsArray = [NSMutableArray array];
    
    NSString *stickerURL = [NSString stringWithFormat:@"%@%@/",TheConstantsManager.stickerURL, TheConstantsManager.apiVersion];
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:stickerURL]];
    
    NSMutableURLRequest *req = [manager requestWithObject:self method:RKRequestMethodGET path:@"getStickerCategories" parameters:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:req];
    [operation start];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSString *resp = [NSString stringWithFormat:@"Response (getStickerCategories)"];
        WRITE_LOG(resp);
        WRITE_LOG(jsonDict);
        for (NSDictionary *stickCatDict in jsonDict) {
            StickerCategory *stickCat = [[StickerCategory alloc] initWithDictionary:stickCatDict];
            [resultsArray addObject:stickCat];
        }

        if(complete){
            complete(resultsArray);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSString *resp = [NSString stringWithFormat:@"Response (getStickerCategories)"];
        WRITE_LOG(resp);
        WRITE_LOG(jsonDict);
        WRITE_LOG(@"ERROR");
        [TheAppDelegate writeLog:error.description];
        
        if(failure){
            failure(operation, error);
        }
    }];
}

-(void)getAllStickersWithCompletion:(void(^) (NSArray * stickerCategoryArray))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    NSMutableArray *resultsArray = [NSMutableArray array];
    NSString *stickerURL = [NSString stringWithFormat:@"%@%@/",TheConstantsManager.stickerURL, TheConstantsManager.apiVersion];
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:stickerURL]];
    
    NSMutableURLRequest *req = [manager requestWithObject:self method:RKRequestMethodGET path:@"getAllStickers" parameters:nil];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:req];
    [operation start];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSString *resp = [NSString stringWithFormat:@"Response (getAllStickers)"];
        WRITE_LOG(resp);
        WRITE_LOG(jsonDict);
        
        [TheDatabaseManager deleteAllPricings];
        [TheDatabaseManager deleteAllStickers];
        [TheDatabaseManager deleteAllStickerCategorys];
        
        for (NSDictionary *stickCatDict in jsonDict) {
            StickerCategory *stickCat = [[StickerCategory alloc] initWithDictionary:stickCatDict];
            [TheDatabaseManager updateStickerCategory:stickCat];
            [resultsArray addObject:stickCat];
        }
        
        if(complete){
            complete(resultsArray);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(operation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
            NSString *resp = [NSString stringWithFormat:@"Response (getAllStickers)"];
            WRITE_LOG(resp);
            WRITE_LOG(jsonDict);
            WRITE_LOG(@"ERROR");
            [TheAppDelegate writeLog:error.description];
        
        }
        if(failure){
            failure(operation, error);
        }
    }];
}

-(void)getStickerByCategoryId:(int)catID withCompletion:(void(^) (StickerCategory *stickerCategory))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *stickerURL = [NSString stringWithFormat:@"%@%@/",TheConstantsManager.stickerURL, TheConstantsManager.apiVersion];
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:stickerURL]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @(catID), @"id",
                                   nil];

    NSMutableURLRequest *req = [manager requestWithObject:self method:RKRequestMethodGET path:@"getStickersByCategory" parameters:params];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:req];
    [operation start];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSString *resp = [NSString stringWithFormat:@"Response (getStickersByCategory)"];
        WRITE_LOG(resp);
        WRITE_LOG(jsonDict);
        StickerCategory *stickCat = [[StickerCategory alloc] initWithDictionary:jsonDict];
        
        
        if(complete){
            complete(stickCat);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSString *resp = [NSString stringWithFormat:@"Response (getStickersByCategory)"];
        WRITE_LOG(resp);
        WRITE_LOG(jsonDict);
        WRITE_LOG(@"ERROR");
        [TheAppDelegate writeLog:error.description];
        
        if(failure){
            failure(operation, error);
        }
    }];
}

@end

