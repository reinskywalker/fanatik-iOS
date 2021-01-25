//
//  Hls.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/25/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Live, Resolution, Video;

@interface Hls : NSManagedObject

@property (nonatomic, retain) NSString * hls_url;
@property (nonatomic, retain) Live *hls_live;
@property (nonatomic, retain) Resolution *hls_resolution;
@property (nonatomic, retain) Video *hls_video;

@end
