//
//  DMVideoReporting.h
//  DMMoviePlayer
//
//  Created by Teguh Hidayatullah on 8/28/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef enum {
    kDMVideoPlaybackStateView = 0,
    kDMVideoPlaybackStatePlaying,
    kDMVideoPlaybackStateFinished
}kDMVideoPlaybackState;

typedef enum {
    kDMReportingRequestTypePost = 0,
    kDMReportingRequestTypeGet,
}kDMReportingRequestType;


@interface DMVideoReporting : NSObject

@property(nonatomic, copy) NSString *reportingURL;
@property(nonatomic, assign) kDMReportingRequestType reportRequestType;

-(void)trackVideoWithURL:(NSString *)vidURL title:(NSString *)vidTitle videoDuration:(NSTimeInterval)duration playbackTime:(NSTimeInterval)time isStreaming:(BOOL)isLive playbackState:(kDMVideoPlaybackState)state customParams:(NSDictionary *)param withCompletion:(void(^) (NSString *message))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
