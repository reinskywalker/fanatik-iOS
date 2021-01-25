//
//  Shareable.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/23/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Clip, Live, Event;

@interface Shareable : NSManagedObject

@property (nonatomic, retain) NSString * shareable_content;
@property (nonatomic, retain) NSString * shareable_url;
@property (nonatomic, retain) Clip *shareable_clip;
@property (nonatomic, retain) Live *shareable_live;
@property (nonatomic, retain) Event *shareable_event;

@end
