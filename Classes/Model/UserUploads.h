//
//  UserUploads.h
//  Fanatik
//
//  Created by Erick Martin on 9/11/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AWSRequestObject;

@interface UserUploads : NSManagedObject

@property (nonatomic, retain) NSNumber * clip_category_id;
@property (nonatomic, retain) NSNumber * user_uploads_approved;
@property (nonatomic, retain) NSString * user_uploads_description;
@property (nonatomic, retain) NSString * user_uploads_id;
@property (nonatomic, retain) NSDate * user_uploads_moderated_at;
@property (nonatomic, retain) NSString * user_uploads_rejected_reason;
@property (nonatomic, retain) NSString * user_uploads_title;
@property (nonatomic, retain) NSString * user_uploads_user_id;
@property (nonatomic, retain) NSString * user_uploads_video_thumbnail;
@property (nonatomic, retain) NSNumber * user_uploads_video_uploaded;
@property (nonatomic, retain) NSString * user_uploads_video_url;
@property (nonatomic, retain) AWSRequestObject *user_uploads_aws;

@end
