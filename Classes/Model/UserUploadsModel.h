//
//  UserUploadsModel.h
//  Fanatik
//
//  Created by Erick Martin on 7/28/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    UserUploadStatusSuccess = 0,
    UserUploadStatusIncomplete = 1,
    UseruploadStatusOnProgress =2
} UserUploadStatus;

@interface UserUploadsModel : NSObject

@property(nonatomic, copy) NSString *user_uploads_id;
@property(nonatomic, copy) NSString *user_uploads_title;
@property(nonatomic, copy) NSString *user_uploads_video_url_local;
@property(nonatomic, assign) UserUploadStatus user_uploads_status;
@property(nonatomic, copy) NSString *clip_category_string;
@property(nonatomic, assign) float user_upload_percentage;

-(id)initWithFMResultSet:(FMResultSet *)result;

@end
