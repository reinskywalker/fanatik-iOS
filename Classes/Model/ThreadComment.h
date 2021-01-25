//
//  ThreadComment.h
//  Fanatik
//
//  Created by Jefry Da Gucci on 4/1/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface ThreadComment : NSManagedObject

@property (nonatomic, retain) NSString * thread_comment_id;
@property (nonatomic, retain) NSNumber * thread_comment_position;
@property (nonatomic, retain) NSString * thread_comment_commentable_type;
@property (nonatomic, retain) NSString * thread_comment_commentable_id;
@property (nonatomic, retain) NSString * thread_comment_content;
@property (nonatomic, retain) NSDate * thread_comment_created_at;
@property (nonatomic, retain) NSString * thread_comment_time_ago;
@property (nonatomic, retain) User *thread_comment_user;

@end
