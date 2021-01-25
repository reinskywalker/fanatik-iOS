//
//  ThreadRestriction.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/17/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Thread;

@interface ThreadRestriction : NSManagedObject

@property (nonatomic, retain) NSNumber * thread_restriction_open;
@property (nonatomic, retain) Thread *t_restriction_thread;

@end
