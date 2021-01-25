//
//  Payment+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/4/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "Payment+functionality.h"

@implementation Payment (functionality)
+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    mappingEntity.identificationAttributes = @[@"payment_id"];
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"payment_id", @"id",
                                       @"payment_name", @"name",
                                       @"payment_logo", @"logo",
                                       nil];
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    return mappingEntity;
}


#pragma mark - ORDER
+(void)orderWithPackageIdArray:(NSArray *)packageIdArray
        andPaymentId:(NSString *)paymentID
          withAccessToken:(NSString *)accessToken
            andCompletion:(void(^) (NSString *orderID))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:TheConstantsManager.serverURL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   ACCESS_TOKEN(), @"access_token",
                                   nil];
    NSDictionary *orderDict = [NSDictionary dictionaryWithObjectsAndKeys:packageIdArray, @"package_ids", paymentID, @"payment_method_id", nil];
    params[@"order"] = orderDict;
    NSMutableURLRequest *req = [manager requestWithObject:self method:RKRequestMethodPOST path:@"orders" parameters:params];
    [TheServerManager setGlobalHeaderForRequest:req];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:req];
    WRITE_LOG(@"=======================");
    NSString *paramString = [NSString stringWithFormat:@"param: %@",params];
    NSString *urlString = [NSString stringWithFormat:@"URL: %@%@",SERVER_URL(), @"orders"];
    WRITE_LOG(paramString);
    WRITE_LOG(urlString);
//    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    [operation start];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [TheAppDelegate writeLog:[operation responseString]];
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        if(complete){
            complete(jsonDict[@"number"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSUInteger statusCode = operation.response.statusCode;
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

                [self orderWithPackageIdArray:packageIdArray andPaymentId:paymentID withAccessToken:accessToken andCompletion:^(NSString *orderID) {
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    if(complete){
                        complete(jsonDict[@"number"]);
                    }
                } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    if(failure){
                        failure(operation, error);
                    }
                }];
                
                
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [TheAppDelegate writeLog:error.description];
            }];
        }
        
        if(operation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
            NSString *resp = [NSString stringWithFormat:@"Response (orders)"];
            WRITE_LOG(resp);
            WRITE_LOG(jsonDict);
            WRITE_LOG(@"ERROR : ");
            WRITE_LOG(operation.responseString);
        }
        
        if(failure){
            failure(operation, error);
        }
        
    }];
}



@end
