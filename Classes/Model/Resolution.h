//
//  Resolution.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/24/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Video;

@interface Resolution : NSManagedObject

@property (nonatomic, retain) NSString * resolution_320;
@property (nonatomic, retain) NSString * resolution_480;
@property (nonatomic, retain) NSString * resolution_640;
@property (nonatomic, retain) NSString * resolution_720;
@property (nonatomic, retain) Video *resolution_video;
@property (nonatomic, retain) NSManagedObject *resolution_smooth;
@property (nonatomic, retain) NSManagedObject *resolution_hls;

@end
