//
//  Notification.m
//  Fanatik
//
//  Created by Erick Martin on 5/2/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "Notification.h"
#import "Clip.h"
#import "Comment.h"
#import "Like.h"
#import "User.h"
#import "Mention.h"

typedef enum {
    NotifRequestTypeGetAll,
    NotifRequestTypeRead
}NotifRequestType;

@implementation Notification

// Insert code here to add functionality to your managed object subclass

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"notification_id", @"id",
                                       @"notification_action", @"action",
                                       @"notification_object_type", @"object_type",
                                       @"notification_object_id", @"object_id",
                                       @"notification_message", @"message",
                                       @"notification_read_at", @"read_at",
                                       @"notification_created_at", @"created_at",
                                       nil];
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *clipMapping = [Clip myMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"clip" toKeyPath:@"notification_clip" withMapping:clipMapping]];
    
    RKEntityMapping *userMapping = [User userMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"notification_user" withMapping:userMapping]];
    
    RKEntityMapping *likeMapping = [Like myMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"like" toKeyPath:@"notification_like" withMapping:likeMapping]];

    RKEntityMapping *commentMapping = [Comment myMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"comment" toKeyPath:@"notification_comment" withMapping:commentMapping]];
    
    RKEntityMapping *mentionMapping = [Mention myMapping];
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"mention" toKeyPath:@"notification_mention" withMapping:mentionMapping]];

    
    return mappingEntity;
}

+(void)getNotificationWithPageNumber:(NSNumber *)pageNum
                     withAccessToken:(NSString *)accessToken
                             success:(void(^)(RKObjectRequestOperation *operation, NSArray *resultArray))success
                             failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    [self reqNotifWithRequestType:NotifRequestTypeGetAll withNotifID:nil withPageNum:pageNum withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, result.array);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

+(void)readNotificationWithNotifID:(NSNumber *)notifID
                   withAccessToken:(NSString *)accessToken
                           success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                           failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    [self reqNotifWithRequestType:NotifRequestTypeRead withNotifID:notifID withPageNum:nil withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success){
            success(operation, result);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

#pragma mark - mother of all request
+ (void)reqNotifWithRequestType:(NotifRequestType)reqType
                    withNotifID:(NSNumber *)notifID
                      withPageNum:(NSNumber *)pageNum
                  withAccessToken:(NSString *)accessToken
                          success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                          failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    
    NSString *keyPath = nil;
    
    RKEntityMapping *mappingEntity = [self myMapping];
    
    RKRequestMethod requestMethod = RKRequestMethodGET;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, @"access_token",
                                   nil];
    
    NSString *pathPattern = @"notifications";
    
    switch (reqType) {
        case NotifRequestTypeGetAll:{
            keyPath = @"user_notifications";
            requestMethod = RKRequestMethodGET;
        }
            break;
        case NotifRequestTypeRead:{
            keyPath = @"user_notification";
            requestMethod = RKRequestMethodPOST;
            pathPattern = [NSString stringWithFormat:@"notifications/%@/read", notifID];
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
            [TheServerManager requestAccessTokenWithCompletion:^(NSString *accessToken) {
                [self reqNotifWithRequestType:reqType withNotifID:notifID withPageNum:pageNum withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                    if(success)
                        success(operation, result);
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    if(failure)
                        failure(operation, error);
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

-(NotifType)notifType{

    if([[self.notification_action lowercaseString] isEqualToString:@"like"]){
        if (self.notification_like.like_clip) {
            return NotifTypeLikeClip;
        }
    }else if([[self.notification_action lowercaseString] isEqualToString:@"comment"]){
        if (self.notification_comment.comment_clip){
            return NotifTypeCommentClip;
        }else if(self.notification_comment.comment_event){
            return NotifTypeCommentEvent;
        }
    }else if([[self.notification_action lowercaseString] isEqualToString:@"upload"]){
        if (self.notification_clip) {
            return NotifTypeNewClipUploaded;
        }
    }else if([[self.notification_action lowercaseString] isEqualToString:@"follow"]){
        if (self.notification_user){
            return NotifTypeFollowUser;
        }
    }else if([[self.notification_action lowercaseString] isEqualToString:@"mention"]){
        if (self.notification_mention.mention_comment.comment_clip){
            return NotifTypeMentionClip;
        }else if(self.notification_mention.mention_comment.comment_live){
            return NotifTypeMentionTVChannel;
        }
    }
    return NotifTypeNone;
}


-(NSString*)dateString{
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate* now = [NSDate date];
    NSString *newTime;
    NSTimeInterval secondsBetween = [now timeIntervalSinceDate:self.notification_created_at];
    
    int numberOfDays = secondsBetween / 86400;
    if (numberOfDays == 1) {
        newTime = @"Yesterday";
    }else if (numberOfDays >= 1) {
        newTime = [NSString stringWithFormat:@"%d %@ ago", numberOfDays, numberOfDays>1?@"days":@"day"];
    }else if(numberOfDays< 1){
        int numberOfHours = secondsBetween / 3600;
        if (numberOfHours >= 1) {
            newTime = [NSString stringWithFormat:@"%d %@ ago",numberOfHours, numberOfHours>1?@"hours":@"hour"];
        }else{
            int numberOfMinutes = secondsBetween / 60;
            if (numberOfMinutes > 1) {
                newTime = [NSString stringWithFormat:@"%d minutes ago",numberOfMinutes];
            }else{
                newTime = [NSString stringWithFormat:@"Just now"];
            }
        }
    }
    return  newTime;
    
}

@end
