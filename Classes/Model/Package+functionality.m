//
//  Package+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/19/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "Package+functionality.h"

typedef enum {
    PackageRequestTypeGetList = 0,
    PackageRequestTypeUserPackage
}PackageRequestType;
@implementation Package (functionality)

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    mappingEntity.identificationAttributes = [NSArray arrayWithObjects:
                                              @"package_id",
                                              nil];
    
    NSDictionary *dictEntity = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"package_id", @"id",
                                @"package_renewal_id", @"package_id",
                                @"package_name", @"name",
                                @"package_price", @"price",
                                @"package_active_at", @"active_at",
                                @"package_inactive_at", @"inactive_at",
                                @"package_expired_at", @"expired_at",
                                @"package_active", @"active",
                                nil];
    
       
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    
    
    return mappingEntity;
}

#pragma mark - GET
+(void)getPackageListWithAccessToken:(NSString *)accessToken
                             success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                             failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqPackageWithPackageId:nil andAccessToken:accessToken andRequestType:PackageRequestTypeGetList success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, result.array);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}

+(void)getUserPackageListWithAccessToken:(NSString *)accessToken
                             success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultsArray))success
                             failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqPackageWithPackageId:nil andAccessToken:accessToken andRequestType:PackageRequestTypeUserPackage success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, result.array);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}

+(void)reqPackageWithPackageId:(NSString *)packageID andAccessToken:(NSString *)accessToken
            andRequestType:(PackageRequestType)reqType
                       success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                       failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    NSString *keyPath = @"";
    NSString *pathPattern = @"";
    RKMapping *mappingEntity = [self myMapping];
    RKRequestMethod requestMethod = RKRequestMethodGET;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:accessToken, @"access_token", nil];
    switch (reqType) {
        case PackageRequestTypeGetList:{
            pathPattern = @"packages";
            keyPath = @"packages";
        }
            break;
        case PackageRequestTypeUserPackage:{
            pathPattern = @"subscriptions";
            keyPath = @"user_packages";
        };
            break;
            
        default:
            break;
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
    operation.managedObjectContext = [TheDatabaseManager managedObjectStore].mainQueueManagedObjectContext;
    operation.managedObjectCache = [TheDatabaseManager managedObjectStore].managedObjectCache;
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        WRITE_LOG(operation.HTTPRequestOperation.responseString);
        if(success)
            success(operation, mappingResult);
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

                [self reqPackageWithPackageId:packageID andAccessToken:accessToken andRequestType:reqType success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                    if(success)
                        success(operation, result);
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    if(failure)
                        failure(operation, error);
                }];
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [TheAppDelegate writeLog:error.description];
                
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
