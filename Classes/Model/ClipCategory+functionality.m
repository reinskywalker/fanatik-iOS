//
//  ClipCategory+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/13/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ClipCategory+functionality.h"
#import "Clip.h"

typedef enum {
    ClipCategoryRequestTypeGetAll,
    ClipCategoryRequestTypeGetByID,
    ClipCategoryRequestTypeGetSubCategory
}ClipCategoryRequestType;

@implementation ClipCategory (functionality)

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    mappingEntity.identificationAttributes = @[@"clip_category_id"];
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"clip_category_id", @"id",
                                       @"clip_category_name", @"name",
                                       @"clip_category_description", @"description",
                                       nil];
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *clipMapping = [Clip myMapping];
    
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"clips" toKeyPath:@"clipcategory_clip" withMapping:clipMapping]];
    
    return mappingEntity;
}

#pragma mark - GET
+(void)getAllClipCategoriesWithAccessToken:(NSString *)accessToken
        success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultArray))success
        failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqClipCategoryWithId:nil pageNumber:nil andRequestType:ClipCategoryRequestTypeGetAll withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
            if(success){
                success(operation, result.array);
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            if(failure)
                failure(operation, error);
    }];
}


+(void)getAllClipCategoriesModelWithAccessToken:(NSString *)accessToken
                     success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultArray))success
                     failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    NSString *keyPath = @"clip_categories";
    
    RKEntityMapping *mappingEntity = [self myMapping];
    
    RKRequestMethod requestMethod = RKRequestMethodGET;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, @"access_token",
                                   nil];
    
    NSString *pathPattern = @"clip-categories";
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:mappingEntity
                                                 method:requestMethod
                                            pathPattern:pathPattern
                                                keyPath:keyPath
                                            statusCodes:statusCodes];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:SERVER_URL()]];
    
    NSMutableURLRequest *request = [manager requestWithObject:self method:requestMethod path:pathPattern parameters:params];
    [TheServerManager setGlobalHeaderForRequest:request];
    [manager addResponseDescriptor:responseDescriptor];
    manager.managedObjectStore = [TheDatabaseManager managedObjectStore];
    
    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    operation.managedObjectContext  = [TheDatabaseManager managedObjectStore].mainQueueManagedObjectContext;
    operation.managedObjectCache    = [TheDatabaseManager managedObjectStore].managedObjectCache;
    WRITE_LOG(@"============================");
    NSString *paramString = [NSString stringWithFormat:@"param: %@",params];
    NSString *urlString = [NSString stringWithFormat:@"URL: %@%@?access_token=%@",SERVER_URL(), pathPattern, accessToken];
    
    NSString *requestType = [NSString stringWithFormat:@"req type: %@",[TheServerManager RKRequestMethodString:requestMethod]];
    WRITE_LOG(requestType);
    WRITE_LOG(paramString);
    WRITE_LOG(urlString);
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSString *resp = [NSString stringWithFormat:@"Response (%@)",pathPattern];
        WRITE_LOG(resp);
        WRITE_LOG(jsonDict);
        
        
        NSMutableArray *resultArray = [NSMutableArray array];
        
        for(NSDictionary *catDict in jsonDict[@"clip_categories"]){
            ClipCategoryModel *catMod = [[ClipCategoryModel alloc]initWithDictionary: catDict];
            [resultArray addObject:catMod];
        }
        
        if(success){
            success(operation, resultArray);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode == StatusCodeExpired || statusCode == StatusCodeForbidden){
            [TheServerManager requestAccessTokenWithCompletion:^(NSString *accessToken) {
                
                [self getAllClipCategoriesWithAccessToken:accessToken success:^(RKObjectRequestOperation *operation, NSArray *resultArray) {
                    if(success){
                        success(operation, resultArray);
                    }
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    if(failure){
                        failure(operation, error);
                    }
                }];
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        }
        
        if(operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            NSString *resp = [NSString stringWithFormat:@"Response (%@)",pathPattern];
            WRITE_LOG(resp);
            WRITE_LOG(jsonDict);
            WRITE_LOG(@"ERROR : ");
            WRITE_LOG(operation.HTTPRequestOperation.responseString);
        }
        
        
        if(failure){
            failure(operation, error);
        }
    }];
    
    [operation start];

    /*
    [self reqClipCategoryWithId:nil pageNumber:nil andRequestType:ClipCategoryRequestTypeGetAll withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            NSLog(@"result object : %@", result.array);
            success(operation, result.array);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
     */
}

+(void)getClipCategoryWithId:(NSString *)objID
                  pageNumber:(NSNumber *)pageNum
              andAccessToken:(NSString *)accessToken
             success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultArray))success
             failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqClipCategoryWithId:objID pageNumber:pageNum andRequestType:ClipCategoryRequestTypeGetByID withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, [result array]);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}

#pragma mark - SubCategory
+(void)getSubCategoryWithCategoryId:(NSString *)objID
                 andAccessToken:(NSString *)accessToken
                        success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultArray))success
                        failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    [self reqClipCategoryWithId:objID pageNumber:0 andRequestType:ClipCategoryRequestTypeGetSubCategory withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, [result array]);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);

    }];
}

#pragma mark - mother of all request
+ (void)reqClipCategoryWithId:(NSString *)objID
                pageNumber:(NSNumber *)pageNum
           andRequestType:(ClipCategoryRequestType)reqType
          withAccessToken:(NSString *)accessToken
                  success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                  failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    NSString *keyPath = @"";
    
    RKEntityMapping *mappingEntity = [self myMapping];
    
    RKRequestMethod requestMethod = RKRequestMethodGET;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, @"access_token",
                                   nil];
    
    NSString *pathPattern = @"";
    
    switch (reqType) {
        case ClipCategoryRequestTypeGetAll:{
            pathPattern = @"clip-categories";
            keyPath = @"clip_categories";
        }
            break;
        case ClipCategoryRequestTypeGetByID:{
            pathPattern = [NSString stringWithFormat:@"clip-categories/%@",objID];
            keyPath = @"clips";
            mappingEntity = [Clip myMapping];
        }
            break;
        case ClipCategoryRequestTypeGetSubCategory:{
            pathPattern = [NSString stringWithFormat:@"clip-categories/%@/sub-categories",objID];
            keyPath = @"clip_categories";
        }
            break;

        default:
            break;
    }
    
    if(pageNum){
        params[@"page"] = pageNum;
    }
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:mappingEntity
                                                 method:requestMethod
                                            pathPattern:pathPattern
                                                keyPath:keyPath
                                            statusCodes:statusCodes];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:SERVER_URL()]];
    
    NSMutableURLRequest *request = [manager requestWithObject:self method:requestMethod path:pathPattern parameters:params];
    [TheServerManager setGlobalHeaderForRequest:request];
    [manager addResponseDescriptor:responseDescriptor];
    manager.managedObjectStore = [TheDatabaseManager managedObjectStore];
    
    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    operation.managedObjectContext  = [TheDatabaseManager managedObjectStore].mainQueueManagedObjectContext;
    operation.managedObjectCache    = [TheDatabaseManager managedObjectStore].managedObjectCache;
    WRITE_LOG(@"============================");
    NSString *paramString = [NSString stringWithFormat:@"param: %@",params];
    NSString *urlString = [NSString stringWithFormat:@"URL: %@%@?access_token=%@",SERVER_URL(), pathPattern, accessToken];
    
    NSString *requestType = [NSString stringWithFormat:@"req type: %@",[TheServerManager RKRequestMethodString:requestMethod]];
    WRITE_LOG(requestType);
    WRITE_LOG(paramString);
    WRITE_LOG(urlString);
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSString *resp = [NSString stringWithFormat:@"Response (%@)",pathPattern];
        WRITE_LOG(resp);
        WRITE_LOG(jsonDict);
        if(success){
            success(operation, result);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode == StatusCodeExpired || statusCode == StatusCodeForbidden){
           if(statusCode == StatusCodeForbidden){
                [TheSettingsManager removeAccessToken];
                [TheSettingsManager removeSessionToken];
                [TheSettingsManager removeCurrentUserId];
                [TheSettingsManager resetSideMenuArray];
                
            }
            
            [TheServerManager requestAccessTokenWithCompletion:^(NSString *accessToken) {
                if(statusCode == StatusCodeForbidden){
                    [TheAppDelegate logoutSuccess];
                }

                [self reqClipCategoryWithId:objID pageNumber:pageNum andRequestType:reqType withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                    if(success){
                        success(operation, result);
                    }
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    if(failure){
                        failure(operation, error);
                    }
                }];
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        }
        
        if(operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            NSString *resp = [NSString stringWithFormat:@"Response (%@)",pathPattern];
            WRITE_LOG(resp);
            WRITE_LOG(jsonDict);
            WRITE_LOG(@"ERROR : ");
            WRITE_LOG(operation.HTTPRequestOperation.responseString);
        }
        

        if(failure){
            failure(operation, error);
        }
    }];
    
    [operation start];
}



@end
