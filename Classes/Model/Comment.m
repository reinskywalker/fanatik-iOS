//
//  Comment.m
//  Fanatik
//
//  Created by Erick Martin on 5/2/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "Comment.h"
#import "Clip.h"
#import "Event.h"
#import "Live.h"
#import "Notification.h"
#import "User.h"
#import "Mention.h"
#import "NSDate+NVTimeAgo.h"

typedef enum{
    CommentRequestTypeGet = 0,
    CommentRequestTypePost = 1,
    CommentRequestTypePostToLive = 2,
    CommentRequestTypeDeleteLiveComment = 3,
    CommentRequestTypeDeleteClipComment = 4,
    CommentRequestTypePostStickerComment = 5,
    CommentRequestTypePostToLiveStickerComment = 6,
    CommentRequestTypePostToEvent = 7,
    CommentRequestTypePostToEventStickerComment = 8,
    CommentRequestTypeDeleteEventComment = 9
}CommentRequestType;

@implementation Comment

// Insert code here to add functionality to your managed object subclass
+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    mappingEntity.identificationAttributes = [NSArray arrayWithObjects:
                                              @"comment_id",
                                              nil];
    
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"comment_id", @"id",
                                       @"comment_content", @"content",
                                       @"comment_created_at", @"created_at",
                                       @"comment_time_ago", @"time_ago",
                                       @"comment_type", @"type",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    RKEntityMapping *userMapping = [User userMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"comment_user" withMapping:userMapping]];
    
    RKEntityMapping *clipMapping = [Clip baseMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"clip" toKeyPath:@"comment_clip" withMapping:clipMapping]];
    
    RKEntityMapping *liveMapping = [Live baseMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"live" toKeyPath:@"comment_live" withMapping:liveMapping]];

    RKEntityMapping *eventMapping = [Event baseMapping];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"event" toKeyPath:@"comment_event" withMapping:eventMapping]];
    
    return mappingEntity;
}

+(Comment *)initWithJSONString:(NSString *)JSONString{
    NSString* MIMEType = @"application/json";
    NSError* error;
    
    NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:MIMEType error:&error];
    if (parsedData == nil && error) {
        //deal with error
    }
    
    //Avatar Manual Mapping
    NSEntityDescription *avatarEntity = [NSEntityDescription entityForName:@"Avatar" inManagedObjectContext:[TheDatabaseManager managedObjectStore].mainQueueManagedObjectContext];
    
    RKObjectMapping *avatarMapping = [Avatar avatarMapping];
    
    
    Avatar *avatarObj = [[Avatar alloc] initWithEntity:avatarEntity insertIntoManagedObjectContext:[TheDatabaseManager managedObjectStore].mainQueueManagedObjectContext];
    RKMappingOperation* avaMapper = [[RKMappingOperation alloc] initWithSourceObject:parsedData[@"comment"][@"user"][@"avatar"] destinationObject:avatarObj mapping:avatarMapping];
    [avaMapper performMapping:&error];
    
    //User Manual Mapping
    NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:[TheDatabaseManager managedObjectStore].mainQueueManagedObjectContext];
    
    RKObjectMapping *userMapping = [RKObjectMapping requestMapping];
    [userMapping addAttributeMappingsFromDictionary:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     @"user_id", @"id",
                                                     @"user_email", @"email",
                                                     @"user_name", @"name",
                                                     @"user_type", @"type",
                                                     nil]];
    NSNumber *anum = parsedData[@"comment"][@"user"][@"id"];
    NSMutableDictionary *parsedDataUser = [NSMutableDictionary dictionaryWithDictionary:parsedData[@"comment"][@"user"]];
    parsedDataUser[@"id"] = [anum stringValue];
    
    
    //    NSLog(@"class: %@ | isString: %@",[parsedDataUser[@"id"] class], [parsedDataUser[@"id"] isKindOfClass:[NSString class] ]? @"YES" : @"NO");
    //    NSLog(@"us: %@",parsedDataUser[@"id"]);
    User *userObj = [[User alloc] initWithEntity:userEntity insertIntoManagedObjectContext:[TheDatabaseManager managedObjectStore].mainQueueManagedObjectContext];
    RKMappingOperation* userMapper = [[RKMappingOperation alloc] initWithSourceObject:parsedDataUser destinationObject:userObj mapping:userMapping];
    [userMapper performMapping:&error];
    
    userObj.user_avatar = avatarObj;
    
    
    //=============
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:[TheDatabaseManager managedObjectStore].mainQueueManagedObjectContext];
    
    RKObjectMapping *commentMapping = [RKObjectMapping requestMapping];
    [commentMapping addAttributeMappingsFromDictionary:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                        @"comment_id", @"id",
                                                        @"comment_content", @"content",
                                                        @"comment_time_ago", @"time_ago",
                                                        @"comment_type", @"type",
                                                        nil]];
    
    Comment *commentObj = [[Comment alloc] initWithEntity:entity insertIntoManagedObjectContext:[TheDatabaseManager managedObjectStore].mainQueueManagedObjectContext];
    RKMappingOperation* mapper = [[RKMappingOperation alloc] initWithSourceObject:parsedData[@"comment"] destinationObject:commentObj mapping:commentMapping];
    [mapper performMapping:&error];
    commentObj.comment_user = userObj;
    return commentObj;
    
}

#pragma mark - POST
+(void)postCommentWithClipId:(NSNumber *)clipID andCommentContent:(NSString *)content
               andTaggedUser:(NSArray *)userArray
             withAccessToken:(NSString *)accessToken
                     success:(void(^)(RKObjectRequestOperation *operation, Comment *object))success
                     failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqCommentWithClipId:clipID andCommentId:nil andCommentContent:content andTaggedUser:userArray pageNumber:0 andRequestType:CommentRequestTypePost withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, result.firstObject);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}

+(void)postCommentWithClipId:(NSNumber *)clipID andStickerId:(NSString *)stickerId
             withAccessToken:(NSString *)accessToken
                     success:(void(^)(RKObjectRequestOperation *operation, Comment *object))success
                     failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqCommentWithClipId:clipID andCommentId:nil andCommentContent:stickerId andTaggedUser:nil pageNumber:0 andRequestType:CommentRequestTypePostStickerComment withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, result.firstObject);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}

+(void)postCommentWithLiveId:(NSNumber *)clipID andCommentContent:(NSString *)comment
               andTaggedUser:(NSArray *)userArray
             withAccessToken:(NSString *)accessToken
                     success:(void(^)(RKObjectRequestOperation *operation, Comment *object))success
                     failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqCommentWithClipId:clipID andCommentId:nil andCommentContent:comment andTaggedUser:userArray pageNumber:0 andRequestType:CommentRequestTypePostToLive withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, result.firstObject);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}

+(void)postCommentWithLiveId:(NSNumber *)liveID andStickerId:(NSString *)stickerId
             withAccessToken:(NSString *)accessToken
                     success:(void(^)(RKObjectRequestOperation *operation, Comment *object))success
                     failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqCommentWithClipId:liveID andCommentId:nil andCommentContent:stickerId andTaggedUser:nil pageNumber:0 andRequestType:CommentRequestTypePostToLiveStickerComment withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, result.firstObject);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}

+(void)postCommentWithEventId:(NSNumber *)evntId andCommentContent:(NSString *)comment
              withAccessToken:(NSString *)accessToken
                      success:(void(^)(RKObjectRequestOperation *operation, Comment *object))success
                      failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqCommentWithClipId:evntId andCommentId:nil andCommentContent:comment andTaggedUser:nil pageNumber:0 andRequestType:CommentRequestTypePostToEvent withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, result.firstObject);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}

+(void)postCommentWithEventId:(NSNumber *)evntId andStickerId:(NSString *)stickerId
              withAccessToken:(NSString *)accessToken
                      success:(void(^)(RKObjectRequestOperation *operation, Comment *object))success
                      failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqCommentWithClipId:evntId andCommentId:nil andCommentContent:stickerId andTaggedUser:nil pageNumber:0 andRequestType:CommentRequestTypePostToEventStickerComment withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, result.firstObject);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}

#pragma mark - DELETE

+(void)deleteCommentWithClipId:(NSNumber *)clipID andCommentId:(NSNumber *)commentID
               withAccessToken:(NSString *)accessToken
                       success:(void(^)(RKObjectRequestOperation *operation, Comment *object))success
                       failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqCommentWithClipId:clipID andCommentId:commentID andCommentContent:nil andTaggedUser:nil pageNumber:0 andRequestType:CommentRequestTypeDeleteClipComment withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, result.firstObject);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}

+(void)deleteCommentWithLiveId:(NSNumber *)clipID andCommentId:(NSNumber *)commentID
               withAccessToken:(NSString *)accessToken
                       success:(void(^)(RKObjectRequestOperation *operation, Comment *object))success
                       failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqCommentWithClipId:clipID andCommentId:commentID andCommentContent:nil andTaggedUser:nil pageNumber:0 andRequestType:CommentRequestTypeDeleteLiveComment withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, result.firstObject);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}

+(void)deleteCommentWithEventId:(NSNumber *)evntId andCommentId:(NSNumber *)commentID
                withAccessToken:(NSString *)accessToken
                        success:(void(^)(RKObjectRequestOperation *operation, Comment *object))success
                        failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self reqCommentWithClipId:evntId andCommentId:commentID andCommentContent:nil andTaggedUser:nil pageNumber:0 andRequestType:CommentRequestTypeDeleteEventComment withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if(success)
            success(operation, result.firstObject);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)
            failure(operation, error);
    }];
}

#pragma mark - mother of all request
+ (void)reqCommentWithClipId:(NSNumber *)clipID
                andCommentId:(NSNumber *)commentID
           andCommentContent:(NSString *)comment
               andTaggedUser:(NSArray *)taggedUser
                  pageNumber:(NSNumber *)pageNum
              andRequestType:(CommentRequestType)reqType
             withAccessToken:(NSString *)accessToken
                     success:(void(^)(RKObjectRequestOperation *operation, RKMappingResult *result))success
                     failure:(void(^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    NSString *keyPath = @"";
    
    RKEntityMapping *mappingEntity = [self myMapping];
    
    RKRequestMethod requestMethod;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, @"access_token",
                                   nil];
    
    NSString *pathPattern = @"";
    
    switch (reqType) {
        case CommentRequestTypeGet:{
            requestMethod = RKRequestMethodGET;
            pathPattern = [NSString stringWithFormat:@"clips/%@/comments",clipID];
            keyPath = @"comments";
        }
            break;
        case CommentRequestTypePost:{
            requestMethod = RKRequestMethodPOST;
            pathPattern = [NSString stringWithFormat:@"clips/%@/comments",clipID];
            
            NSMutableDictionary *commentDict = [NSMutableDictionary new];
            commentDict[@"content"] = comment;
            commentDict[@"user_ids"] = taggedUser;
            params[@"comment"] = commentDict;
            keyPath = @"comment";
            
        }
            break;
        case CommentRequestTypePostStickerComment:{
            requestMethod = RKRequestMethodPOST;
            pathPattern = [NSString stringWithFormat:@"clips/%@/sticker-comments", clipID];
            
            NSMutableDictionary *commentDict = [NSMutableDictionary new];
            commentDict[@"content"] = comment;
            params[@"comment"] = commentDict;
            keyPath = @"comment";
        }
            break;
        case CommentRequestTypePostToLive:{
            requestMethod = RKRequestMethodPOST;
            pathPattern = [NSString stringWithFormat:@"live/%@/comments",clipID];
            
            NSMutableDictionary *commentDict = [NSMutableDictionary new];
            commentDict[@"content"] = comment;
            commentDict[@"user_ids"] = taggedUser;
            params[@"comment"] = commentDict;
            keyPath = @"comment";
            
        }
            break;
        case CommentRequestTypePostToLiveStickerComment:{
            requestMethod = RKRequestMethodPOST;
            pathPattern = [NSString stringWithFormat:@"live/%@/sticker-comments",clipID];
            
            NSMutableDictionary *commentDict = [NSMutableDictionary new];
            commentDict[@"content"] = comment;
            params[@"comment"] = commentDict;
            keyPath = @"comment";
        }
            break;
            
        case CommentRequestTypePostToEvent:{
            requestMethod = RKRequestMethodPOST;
            pathPattern = [NSString stringWithFormat:@"live-events/%@/comments", clipID];
            
            NSMutableDictionary *commentDict = [NSMutableDictionary new];
            commentDict[@"content"] = comment;
            params[@"comment"] = commentDict;
            keyPath = @"comment";
            
        }
            break;
        case CommentRequestTypePostToEventStickerComment:{
            requestMethod = RKRequestMethodPOST;
            pathPattern = [NSString stringWithFormat:@"live-events/%@/sticker-comments", clipID];
            
            NSMutableDictionary *commentDict = [NSMutableDictionary new];
            commentDict[@"content"] = comment;
            params[@"comment"] = commentDict;
            keyPath = @"comment";
        }
            break;
        case CommentRequestTypeDeleteLiveComment:{
            requestMethod = RKRequestMethodDELETE;
            pathPattern = [NSString stringWithFormat:@"comments/%@", commentID];
        }
            break;
            
        case CommentRequestTypeDeleteClipComment:{
            requestMethod = RKRequestMethodDELETE;
            pathPattern = [NSString stringWithFormat:@"comments/%@", commentID];
        }
            break;
        case CommentRequestTypeDeleteEventComment:{
            requestMethod = RKRequestMethodDELETE;
            pathPattern = [NSString stringWithFormat:@"comments/%@", commentID];
            keyPath = @"comment";
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
                
                [self reqCommentWithClipId:clipID andCommentId:commentID andCommentContent:comment andTaggedUser:taggedUser pageNumber:pageNum andRequestType:reqType withAccessToken:accessToken success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                    
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

-(NSString*)dateString{
    
    //    return [self.comment_created_at formattedAsTimeAgo];
    
    /*
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    */
    
    NSDate* currentDate = [NSDate date];
    NSTimeZone* currentTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* nowTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:currentDate];
    NSInteger nowGMTOffset = [nowTimeZone secondsFromGMTForDate:currentDate];
    
    NSTimeInterval interval = nowGMTOffset - currentGMTOffset;
    NSDate* now = [[NSDate alloc] initWithTimeInterval:interval sinceDate:currentDate];
//    NSString *dateString = [df stringFromDate:now];

    NSString *newTime;
    NSTimeInterval secondsBetween = [now timeIntervalSinceDate:self.comment_created_at];
    
    int numberOfDays = secondsBetween / 86400;
    if (numberOfDays == 1) {
        newTime = @"yesterday";
    }else if (numberOfDays >= 1) {
        newTime = [NSString stringWithFormat:@"%d days", numberOfDays];
    }else if(numberOfDays< 1){
        int numberOfHours = secondsBetween / 3600;
        if (numberOfHours >= 1) {
            newTime = [NSString stringWithFormat:@"%d hours",numberOfHours];
        }else{
            int numberOfMinutes = secondsBetween / 60;
            if (numberOfMinutes > 1) {
                newTime = [NSString stringWithFormat:@"%d minutes",numberOfMinutes];
            }else{
                newTime = [NSString stringWithFormat:@"less than a minute"];
            }
        }
    }
    return  newTime;
    
}

-(NSString*)dateString2{
    
    //    return [self.comment_created_at formattedAsTimeAgo];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate* now = [NSDate date];
    NSString *newTime;
    NSTimeInterval secondsBetween = [now timeIntervalSinceDate:self.comment_created_at];
    
    int numberOfDays = secondsBetween / 86400;
    if (numberOfDays == 1) {
        newTime = @"kemarin";
    }else if (numberOfDays >= 1) {
        newTime = [NSString stringWithFormat:@"%d %@ yang lalu", numberOfDays, @"hari"];
    }else if(numberOfDays< 1){
        int numberOfHours = secondsBetween / 3600;
        if (numberOfHours >= 1) {
            newTime = [NSString stringWithFormat:@"%d %@ yang lalu",numberOfHours, @"jam"];
        }else{
            int numberOfMinutes = secondsBetween / 60;
            if (numberOfMinutes > 1) {
                newTime = [NSString stringWithFormat:@"%d menit yang lalu",numberOfMinutes];
            }else{
                newTime = [NSString stringWithFormat:@"baru saja"];
            }
        }
    }
    return  newTime;
    
}

@end
