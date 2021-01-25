//
//  UserUploadsModel.m
//  Fanatik
//
//  Created by Erick Martin on 7/28/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "UserUploadsModel.h"

@implementation UserUploadsModel

@synthesize user_uploads_id, user_uploads_title, user_uploads_video_url_local;
@synthesize user_uploads_status, clip_category_string, user_upload_percentage;

-(id)initWithFMResultSet:(FMResultSet *)result{
    if(self = [super init]){
        self.user_uploads_id = [result stringForColumn:@"user_uploads_id"];
        self.user_uploads_title = [result stringForColumn:@"user_uploads_title"];
        self.user_uploads_video_url_local = [result stringForColumn:@"user_uploads_video_url_local"];
        self.user_uploads_status = [result intForColumn:@"user_uploads_status"];
        self.clip_category_string = [result stringForColumn:@"clip_category_string"];
        self.user_upload_percentage = [result doubleForColumn:@"user_upload_percentage"];
    }
    return self;
}

@end
