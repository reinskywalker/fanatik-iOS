//
//  ClipGroup.m
//  Fanatik
//
//  Created by Erick Martin on 5/30/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "ClipGroup.h"
#import "Clip.h"
#import "Thumbnail.h"
#import "User.h"

typedef enum{
    ClipGroupRequestTypeDashboard = 0,
    ClipGroupRequestTypeGetByCategory = 1,
    ClipGroupRequestTypeShowClipGroup = 2
    
}ClipGroupRequestType;

@implementation ClipGroup

// Insert code here to add functionality to your managed object subclass
+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    mappingEntity.identificationAttributes = [NSArray arrayWithObject:@"clip_group_id"];
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"clip_group_id", @"id",
                                       @"clip_group_name", @"name",
                                       @"clip_group_description", @"description",
                                       @"clip_group_position", @"position",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *clipMapping = [Clip myMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"clips" toKeyPath:@"clip_group_clips" withMapping:clipMapping]];
    
    RKEntityMapping *thumbnailMapping = [Thumbnail thumbnailMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"thumbnail" toKeyPath:@"clip_group_thumbnail" withMapping:thumbnailMapping]];
    
    RKEntityMapping *userMapping = [User userMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"clip_group_user" withMapping:userMapping]];
    
    return mappingEntity;
    
}

+ (NSArray *)fetchDashboardMenu{
    RKManagedObjectStore *objStore = [TheDatabaseManager managedObjectStore];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([ClipGroup class]) inManagedObjectContext:objStore.mainQueueManagedObjectContext]];
    [fetchRequest setIncludesPropertyValues:YES];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSError *error = nil;
    NSArray *arrResult = [objStore.mainQueueManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"clip_group_position" ascending:YES];
    NSArray *sortedResults = [arrResult sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    return sortedResults;
}

#pragma mark - GET
+(void)getDashboardWithAccessToken:(NSString *)accessToken
                           success:(void(^)(RKObjectRequestOperation *operation, NSArray *clipsArray))success
                           failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqClipGroupWithClipGroupId:@"" andRequestType:ClipGroupRequestTypeDashboard withAccessToken:accessToken andPageNum:@(0) success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSArray *clipsArray = [NSArray arrayWithArray:result.array];
        if(success){
            success(operation, clipsArray);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

+(void)getClipGroupWithCategoryId:(NSString *)catID
                   andAccessToken:(NSString *)accessToken
                          success:(void(^)(RKObjectRequestOperation *operation, NSArray *clipsArray))success
                          failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqClipGroupWithClipGroupId:catID andRequestType:ClipGroupRequestTypeGetByCategory withAccessToken:accessToken andPageNum:@(0) success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSArray *clipsArray = [NSArray arrayWithArray:result.array];
        if(success){
            success(operation, clipsArray);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}

+(void)getClipsWithClipGroupId:(NSString *)clipGroupId
                andAccessToken:(NSString *)accessToken
                    andPageNum:(NSNumber *)pageNum
                       success:(void(^)(RKObjectRequestOperation *operation, ClipGroup *clipGroup))success
                       failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    [self reqClipGroupWithClipGroupId:clipGroupId andRequestType:ClipGroupRequestTypeShowClipGroup withAccessToken:accessToken andPageNum:pageNum success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        
        ClipGroup *clipGroup = [result firstObject];
        //        NSArray *clipsArray = [NSArray arrayWithArray:result.array];
        //        NSLog(@"clips array = %@", clipsArray);
        
        if(success){
            success(operation, clipGroup);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
    
    
}


#pragma mark - mother of all request
+ (void)reqClipGroupWithClipGroupId:(NSString *)clipID
                     andRequestType:(ClipGroupRequestType)reqType
                    withAccessToken:(NSString *)accessToken
                         andPageNum:(NSNumber *)pageNum
                            success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                            failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    NSString *keyPath;
    
    RKEntityMapping *mappingEntity = [self myMapping];
    
    RKRequestMethod requestMethod = RKRequestMethodGET;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, @"access_token",
                                   nil];
    
    NSString *pathPattern = @"";
    
    switch (reqType) {
        case ClipGroupRequestTypeDashboard:{
            pathPattern = @"dashboard";
            keyPath = @"clip_groups";
        }
            break;
        case ClipGroupRequestTypeGetByCategory:{
            pathPattern = [NSString stringWithFormat:@"clip-categories/%@/clip-groups",clipID];
            keyPath = @"clip_groups";
        }
            break;
        case ClipGroupRequestTypeShowClipGroup:{
            pathPattern = [NSString stringWithFormat:@"clip-groups/%@",clipID];
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
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    operation.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    //    operation.managedObjectCache    = [TheDatabaseManager managedObjectStore].managedObjectCache;
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
                
                [self reqClipGroupWithClipGroupId:clipID andRequestType:reqType withAccessToken:accessToken andPageNum:pageNum success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                    WRITE_LOG(operation.HTTPRequestOperation.responseString);
                    if(success){
                        success(operation, result);
                    }
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    WRITE_LOG(operation.HTTPRequestOperation.responseString);
                    if(failure){
                        failure(operation, error);
                    }
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
