//
//  ThreadContent.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 4/13/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ThreadContent;

@interface ThreadContent : NSManagedObject

@property (nonatomic, retain) NSString * thread_content_html;
@property (nonatomic, retain) NSString * thread_content_plain;
@property (nonatomic, retain) ThreadContent *content_thread;

@end
