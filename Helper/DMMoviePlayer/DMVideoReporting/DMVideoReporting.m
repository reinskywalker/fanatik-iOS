//
//  DMVideoReporting.m
//  DMMoviePlayer
//
//  Created by Teguh Hidayatullah on 8/28/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "DMVideoReporting.h"
#import <AFNetworking/AFNetworking.h>
#import "UserWrapper.h"
#import <RestKit.h>

@implementation DMVideoReporting
@synthesize reportingURL, reportRequestType;

-(void)trackVideoWithURL:(NSString *)vidURL title:(NSString *)vidTitle videoDuration:(NSTimeInterval)duration playbackTime:(NSTimeInterval)time isStreaming:(BOOL)isLive playbackState:(kDMVideoPlaybackState)state customParams:(NSDictionary *)param withCompletion:(void (^)(NSString *))complete andFailure:(void (^)(AFHTTPRequestOperation *, NSError *))failure{

    

    NSString *epoch = [NSString stringWithFormat:@"%0.0f", [[NSDate date] timeIntervalSince1970]];
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:reportingURL]];
    
    NSString *playbackState;
    switch (state) {
        case kDMVideoPlaybackStateView:
            playbackState = @"view";
            break;
        case kDMVideoPlaybackStatePlaying:
            playbackState = @"playing";
            break;
        case kDMVideoPlaybackStateFinished:
            playbackState = @"finish";
            break;
            
        default:
            break;
    }
    
    NSMutableDictionary *reqParams = @{
                                       @"video_url":vidURL,
                                       @"video_title":vidTitle,
                                       @"is_live":@(isLive),
                                       @"playback_state":playbackState,
                                       @"timestamp":epoch,
                                       @"duration":@(duration),
                                       @"played":@(time)
                                       }.mutableCopy;
    if (param && !([param count] > 0)) {
        [reqParams addEntriesFromDictionary:param];
    }
    
    NSMutableURLRequest *req = [manager requestWithObject:self method:RKRequestMethodPOST path:@"access-tokens" parameters:reqParams];
    
    NSMutableURLRequest *req2 = [manager requestWithObject:self method:RKRequestMethodGET path:@"access-tokens" parameters:reqParams];
    
    
    [TheServerManager setGlobalHeaderForRequest:req];

    if(reportRequestType == kDMReportingRequestTypePost){
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:req];
        [operation start];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"JSON: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     
            NSLog(@"Error: %@", error);
        }];
    }else if (reportRequestType == kDMReportingRequestTypeGet){
        
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:req2];
        [operation start];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
           NSLog(@"JSON: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     
            NSLog(@"Error: %@", error);
        }];
        
    }
}

@end
