//
//  SectionMenu+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "SectionMenu+functionality.h"
#import "RowMenu+functionality.h"

@implementation SectionMenu (functionality)

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    RKEntityMapping *rowMenuMapping = [RowMenu myMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"section_menu" toKeyPath:@"section_menu_row_menus" withMapping:rowMenuMapping]];
    return mappingEntity;
}

+ (void)getSectionMenuWithAccessToken:(NSString *)accessToken
                           success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultArray))success
                           failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    NSString *keyPath = @"menus";
    
    RKEntityMapping *mappingEntity = [self myMapping];
    
    RKRequestMethod requestMethod = RKRequestMethodGET;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, @"access_token",
                                   nil];
    
    NSString *pathPattern = @"application-menu";
    
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
            success(operation, [result array]);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode == StatusCodeExpired || statusCode == StatusCodeForbidden){
            if(statusCode == StatusCodeForbidden){
                [TheSettingsManager removeAccessToken];
                [TheSettingsManager removeSessionToken];
                [TheSettingsManager removeCurrentUserId];
                [TheSettingsManager resetSideMenuArray];
                if([TheSettingsManager.selectedMenu isEqualToString:MenuPageTimeline] || [TheSettingsManager.selectedMenu isEqualToString:MenuPageFollowing] || [TheSettingsManager.selectedMenu isEqualToString:MenuPagePlaylist] || [TheSettingsManager.selectedMenu isEqualToString:MenuPageClub] || [TheSettingsManager.selectedMenu isEqualToString:MenuPageClubDetail] || [TheSettingsManager.selectedMenu isEqualToString:MenuPageThread] || [TheSettingsManager.selectedMenu isEqualToString:MenuPageThreadDetail] ||
                    [TheSettingsManager.selectedMenu isEqualToString:MenuPageEventDetail] ||
                    [TheSettingsManager.selectedMenu isEqualToString:MenuPageVideoDetail] ||
                    [TheSettingsManager.selectedMenu isEqualToString:MenuPageNotification])
                {
                    [TheSettingsManager saveSelectedMenu:MenuPageHome];
                    [TheAppDelegate changeCenterController:[TheAppDelegate getViewControllerById:TheSettingsManager.selectedMenu withParamId:nil]];
                }
                
                
//                gw wajib tanya teguh mksd code di bawah itu apahhh
//                [TheAppDelegate removeLocalData];
            }
            if(ACCESS_TOKEN() && ![ACCESS_TOKEN() isEqualToString:@""]){
                [self getSectionMenuWithAccessToken:accessToken success:^(RKObjectRequestOperation *operation, NSArray *resultArray) {
                    WRITE_LOG(operation.HTTPRequestOperation.response);
                    if (success) {
                        success(operation, resultArray);
                    }
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    WRITE_LOG(error.localizedDescription);
                }];

            }else{
                [TheServerManager requestAccessTokenWithCompletion:^(NSString *accessToken) {
                    [self getSectionMenuWithAccessToken:accessToken success:^(RKObjectRequestOperation *operation, NSArray *resultArray) {
                        WRITE_LOG(operation.HTTPRequestOperation.response);
                        if (success) {
                            success(operation, resultArray);
                        }
                    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                        WRITE_LOG(error.localizedDescription);
                    }];
                    
                } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [TheAppDelegate writeLog:error.description];
                }];
            }
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


+ (NSArray *)fetchSectionMenu{
    RKManagedObjectStore *objStore = [TheDatabaseManager managedObjectStore];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([SectionMenu class]) inManagedObjectContext:objStore.mainQueueManagedObjectContext]];
    [fetchRequest setIncludesPropertyValues:YES];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    
    NSError *error = nil;
    NSArray *arrResult = [objStore.mainQueueManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    return arrResult;
}


@end
