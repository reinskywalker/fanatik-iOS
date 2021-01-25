//
//  CoverImage.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/29/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface CoverImage : NSManagedObject

@property (nonatomic, retain) NSString * cover_image_160;
@property (nonatomic, retain) NSString * cover_image_original;
@property (nonatomic, retain) NSString * cover_image_240;
@property (nonatomic, retain) NSString * cover_image_320;
@property (nonatomic, retain) NSString * cover_image_640;
@property (nonatomic, retain) NSString * cover_image_480;
@property (nonatomic, retain) User *cover_image_user;

@end
