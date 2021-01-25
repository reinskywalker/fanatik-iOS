//
//  AWSRequestObject.h
//  Fanatik
//
//  Created by Erick Martin on 9/11/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserUploads;

@interface AWSRequestObject : NSManagedObject

@property (nonatomic, retain) NSString * aws_bucket_name;
@property (nonatomic, retain) NSString * aws_filename;
@property (nonatomic, retain) NSString * aws_host;
@property (nonatomic, retain) NSString * aws_path;
@property (nonatomic, retain) UserUploads *aws_user_uploads;

@end
