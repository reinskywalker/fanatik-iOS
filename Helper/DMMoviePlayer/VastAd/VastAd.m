//
//  VastAd.m
//  mediaplayer
//
//  Copyright (c) 2014 Viocorp. All rights reserved.
//

#import "VastAd.h"

@implementation VastAd

@synthesize mediaFileURL, clickThroughURL, trackImpressionURL, trackStartURL, trackFirstQuartileURL, trackMidPointURL, trackThirdQuartileURL, trackCompleteURL, trackFullScreenURL, trackMuteURL, trackPauseURL;

- (id)initWithTBXMLElement:(TBXMLElement *)element {
    self = [super init];
	if (self) {
           
        if (element) {
            TBXMLElement *inlineNode = [TBXML childElementNamed:@"InLine" parentElement:element];
            TBXMLElement *creativesNode = [TBXML childElementNamed:@"Creatives" parentElement:inlineNode];
            TBXMLElement *creativeNode = [TBXML childElementNamed:@"Creative" parentElement:creativesNode];
            TBXMLElement *linearNode = [TBXML childElementNamed:@"Linear" parentElement:creativeNode];
            
            if (linearNode) {
                TBXMLElement *mediaFilesNode = [TBXML childElementNamed:@"MediaFiles" parentElement:linearNode];
                if (mediaFilesNode) {
                    TBXMLElement *mediaFileNode = [TBXML childElementNamed:@"MediaFile" parentElement:mediaFilesNode];
                    if(mediaFileNode){
                        TBXMLElement *URLNode = [TBXML childElementNamed:@"URL" parentElement:mediaFileNode];
                        if(URLNode)
                            self.mediaFileURL = [TBXML textForElement:URLNode];
                    }
                }
                
                
                TBXMLElement *videoClicksNode = [TBXML childElementNamed:@"VideoClicks" parentElement:linearNode];
                if(videoClicksNode){
                    TBXMLElement *clickThroughNode = [TBXML childElementNamed:@"ClickThrough" parentElement:videoClicksNode];
                    if(clickThroughNode){
                        self.clickThroughURL = [TBXML textForElement:clickThroughNode];
                    }
                }
                
                
                TBXMLElement *trackingEventsNode = [TBXML childElementNamed:@"TrackingEvents" parentElement:linearNode];
                if(trackingEventsNode){
                    TBXMLElement *trackingNode = trackingEventsNode->firstChild;
                    while (trackingNode) {
                        NSString *trackingEventType = [TBXML valueOfAttributeNamed:@"event" forElement:trackingNode];
                        
                        if ([trackingEventType isEqualToString:@"start"]) {
                            if(trackingNode)
                                self.trackStartURL = [TBXML textForElement:trackingNode];
                        }
                        
                        if ([trackingEventType isEqualToString:@"firstQuartile"]) {
                            if(trackingNode)
                                self.trackFirstQuartileURL = [TBXML textForElement:trackingNode];
                        }
                        
                        if ([trackingEventType isEqualToString:@"midpoint"]) {
                            if(trackingNode)
                                self.trackMidPointURL = [TBXML textForElement:trackingNode];
                        }
                        
                        if ([trackingEventType isEqualToString:@"thirdQuartile"]) {
                            if(trackingNode)
                                self.trackThirdQuartileURL = [TBXML textForElement:trackingNode];
                        }
                        
                        if ([trackingEventType isEqualToString:@"complete"]) {
                            if(trackingNode)
                                self.trackCompleteURL = [TBXML textForElement:trackingNode];
                        }
                        
                        if ([trackingEventType isEqualToString:@"pause"]) {
                            if(trackingNode)
                                self.trackPauseURL = [TBXML textForElement:trackingNode];
                        }
                        
                        if ([trackingEventType isEqualToString:@"mute"]) {
                            if(trackingNode)
                                self.trackMuteURL = [TBXML textForElement:trackingNode];
                        }
                        
                        if ([trackingEventType isEqualToString:@"fullscreen"]) {
                            if(trackingNode)
                                self.trackFullScreenURL = [TBXML textForElement:trackingNode];
                        }
                        
                        trackingNode = trackingNode->nextSibling;
                    }
                }
                
            }
            
            
            if(inlineNode){
                TBXMLElement *impressionNode = [TBXML childElementNamed:@"Impression" parentElement:inlineNode];
                if(impressionNode){
                    self.trackImpressionURL = [TBXML textForElement:impressionNode];
                }
            }
            
        }
        
	}
	return self;
}

- (BOOL)hasMedia {
    if (self.mediaFileURL && [self.mediaFileURL isKindOfClass:[NSString class]] && ([self.mediaFileURL length] > 0)) {
        return YES;
    }
    return NO;
}

- (BOOL)hasClickThrough {
    if (self.clickThroughURL && [self.clickThroughURL isKindOfClass:[NSString class]] && ([self.clickThroughURL length] > 0)) {
        return YES;
    }
    return NO;
}

- (NSString *)escapedTrackURL:(NSString *)originalURL {
    return [originalURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)trackAdWithProgress:(double)progress {
    if ((progress >= 0.25) && (progress < 0.5) ) {
        if(self.trackFirstQuartileURL){
            NSLog(@"track ad first quartile (%.2f) : %@",progress, self.trackFirstQuartileURL);
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[self escapedTrackURL:self.trackFirstQuartileURL]]];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
   
            }];
        }
    }else if ((progress >= 0.5) && (progress < 0.75)) {
        if(self.trackMidPointURL){
            NSLog(@"track ad midpoint (%.2f) : %@",progress, self.trackMidPointURL);
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[self escapedTrackURL:self.trackMidPointURL]]];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
    
            }];
        }
    }else if ((progress >= 0.75) && (progress < 1.0)) {
        if(self.trackThirdQuartileURL){
            NSLog(@"track ad third quartile (%.2f) : %@",progress, self.trackThirdQuartileURL);
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[self escapedTrackURL:self.trackThirdQuartileURL]]];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
    
                
            }];
        }
    }else if (progress >= 1) {
        if(self.trackCompleteURL){
            NSLog(@"track ad complete (%.2f) : %@",progress, self.trackCompleteURL);
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[self escapedTrackURL:self.trackCompleteURL]]];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
    
                
            }];
        }
    }
}

- (void)trackAdStart{
    if (self.trackStartURL) {
        NSLog(@"track ad start : %@",self.trackStartURL);
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[self escapedTrackURL:self.trackStartURL]]];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
//            NSLog(@"%@" , connectionError.description);
//            NSLog(@"%@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
//            NSLog(@"response :%@", response);
        }];
        self.trackStartURL = nil;
    }
    
    if (self.trackImpressionURL) {
        NSLog(@"track ad impression : %@",self.trackImpressionURL);
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[self escapedTrackURL:self.trackImpressionURL]]];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
//            NSLog(@"%@" , connectionError.description);
//            NSLog(@"%@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
//            NSLog(@"response :%@", response);
        }];
        self.trackImpressionURL = nil;
    }
}

-(void)trackAdFirstQuartile{
    if(self.trackFirstQuartileURL){
        NSLog(@"track ad first quartile : %@", self.trackFirstQuartileURL);
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[self escapedTrackURL:self.trackFirstQuartileURL]]];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
            //            NSLog(@"%@" , connectionError.description);
            //            NSLog(@"%@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
            //            NSLog(@"response :%@", response);
        }];
    }
}

-(void)trackAdMidPoint{
    if(self.trackMidPointURL){
        NSLog(@"track ad midpoint: %@", self.trackMidPointURL);
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[self escapedTrackURL:self.trackMidPointURL]]];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
            
        }];
    }
}

-(void)trackAdThirdQuartile{
    if(self.trackThirdQuartileURL){
        NSLog(@"track ad third quartile : %@", self.trackThirdQuartileURL);
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[self escapedTrackURL:self.trackThirdQuartileURL]]];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
            
            
        }];
    }
}

-(void)trackAdComplete{
    if(self.trackCompleteURL){
        NSLog(@"track ad complete: %@", self.trackCompleteURL);
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[self escapedTrackURL:self.trackCompleteURL]]];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
            
            
        }];
    }
}

-(void)trackAdMute{
    if(self.trackMuteURL){
        NSLog(@"track ad complete: %@", self.trackMuteURL);
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[self escapedTrackURL:self.trackCompleteURL]]];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
            
            
        }];
    }
}

-(void)trackAdPause{
    if(self.trackPauseURL){
        NSLog(@"track ad complete: %@", self.trackPauseURL);
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[self escapedTrackURL:self.trackCompleteURL]]];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
            
            
        }];
    }
}

-(void)trackAdFullScreen{
    if(self.trackFullScreenURL){
        NSLog(@"track ad complete: %@", self.trackFullScreenURL);
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[self escapedTrackURL:self.trackCompleteURL]]];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
            
            
        }];
    }
}

@end
