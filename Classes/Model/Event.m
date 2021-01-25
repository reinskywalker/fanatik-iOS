//
//  Event.m
//  Fanatik
//
//  Created by Erick Martin on 3/16/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "Event.h"
#import "User.h"
#import "Pagination.h"

typedef enum{
    EventRequestTypeGetDetail = 0
}EventRequestType;

@implementation Event

// Insert code here to add functionality to your managed object subclass

+(RKEntityMapping *)baseMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    mappingEntity.identificationAttributes = [NSArray arrayWithObject:@"event_id"];
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"event_id", @"id",
                                       @"event_name", @"name",
                                       @"event_description", @"description",
                                       @"event_start_date", @"start_date",
                                       @"event_end_date", @"end_date",
                                       @"event_streaming_url", @"streaming_url",
                                       @"event_badge_text", @"badge_text",
                                       @"event_badge_color", @"badge_color",
                                       @"event_badge_background", @"badge_background",
                                       @"event_position", @"position",
                                       @"event_live", @"live",
                                       @"event_watching_count", @"watching_count",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *userMapping = [User userMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"event_user" withMapping:userMapping]];
    
    RKEntityMapping *statsMapping = [EventStats myMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stats" toKeyPath:@"event_stats" withMapping:statsMapping]];
    
    RKEntityMapping *paginationMapping = [Pagination myMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"pagination" toKeyPath:@"event_pagination" withMapping:paginationMapping]];
    
    RKEntityMapping *posterThumbMapping = [Thumbnail thumbnailMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"poster_thumbnail" toKeyPath:@"event_poster_thumbnail" withMapping:posterThumbMapping]];
    
    RKEntityMapping *announcementMapping = [EventAnnouncement myMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"live_event_announcements" toKeyPath:@"event_announcement" withMapping:announcementMapping]];
    
    return mappingEntity;
    
}

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [Event baseMapping];
    RKEntityMapping *commentMapping = [Comment myMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"comments" toKeyPath:@"event_comment" withMapping:commentMapping]];
    
    RKEntityMapping *clipMapping = [Clip myMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"clips" toKeyPath:@"event_clip" withMapping:clipMapping]];
    
    return mappingEntity;
    
}

#pragma mark - GET
+(void)getEventDetailWithId:(NSNumber *)evId withPageNumber:(NSNumber *)pageNum
             andAccessToken:(NSString *)accessToken
                    success:(void(^)(RKObjectRequestOperation *operation, Event *eventObject))success
                    failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqEventWithEventId:evId andRequestType:EventRequestTypeGetDetail withAccessToken:accessToken andPageNum:pageNum success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, result.firstObject);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation, error);
        }
    }];
}


#pragma mark - mother of all request
+ (void)reqEventWithEventId:(NSNumber *)evId
                     andRequestType:(EventRequestType)reqType
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
        case EventRequestTypeGetDetail:{
            pathPattern = [NSString stringWithFormat:@"live-events/%@", evId];
            keyPath = @"";
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
                
                [self reqEventWithEventId:evId andRequestType:reqType withAccessToken:accessToken andPageNum:pageNum success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
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

-(NSString *)eventDateWithTimezone{

    NSDate *sourceDate = self.event_start_date;
    NSTimeZone* destinationTimeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    float timeZoneOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate] / 3600;
    NSDate *eventTime = [self.event_start_date dateByAddingTimeInterval:(timeZoneOffset- 7.0) * 3600];
    
    NSDateFormatter *df = nil;
    if([eventTime isToday]){
        df = [TheAppDelegate defaultTimeFormatter];
        return [NSString stringWithFormat:@"Today at %@", [df stringFromDate:eventTime]];
    }

    df = [TheAppDelegate defaultDateTimeFormatter];
    return [df stringFromDate:eventTime];
}

@end
