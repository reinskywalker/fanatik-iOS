//
//  VastAd.h
//  mediaplayer
//
//  Copyright (c) 2014 Viocorp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

@interface VastAd : NSObject

@property (nonatomic, copy) NSString *mediaFileURL;
@property (nonatomic, copy) NSString *clickThroughURL;
@property (nonatomic, copy) NSString *trackImpressionURL;
@property (nonatomic, copy) NSString *trackStartURL;
@property (nonatomic, copy) NSString *trackFirstQuartileURL;
@property (nonatomic, copy) NSString *trackMidPointURL;
@property (nonatomic, copy) NSString *trackThirdQuartileURL;
@property (nonatomic, copy) NSString *trackCompleteURL;
@property (nonatomic, copy) NSString *trackPauseURL;
@property (nonatomic, copy) NSString *trackMuteURL;
@property (nonatomic, copy) NSString *trackFullScreenURL;

- (id)initWithTBXMLElement:(TBXMLElement *)element;

- (BOOL)hasMedia;
- (BOOL)hasClickThrough;
- (void)trackAdWithProgress:(double)progress;
- (void)trackAdStart;
- (void)trackAdFirstQuartile;
- (void)trackAdMidPoint;
- (void)trackAdThirdQuartile;
- (void)trackAdComplete;
- (void)trackAdPause;
- (void)trackAdMute;
- (void)trackAdFullScreen;
@end
