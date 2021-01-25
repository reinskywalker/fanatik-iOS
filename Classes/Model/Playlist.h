//
//  Playlist.h
//  Fanatik
//
//  Created by Erick Martin on 6/8/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Clip, Timeline;

@interface Playlist : NSManagedObject

@property (nonatomic, retain) NSDate * playlist_created_at;
@property (nonatomic, retain) NSString * playlist_id;
@property (nonatomic, retain) NSString * playlist_name;
@property (nonatomic, retain) NSNumber * playlist_private;
@property (nonatomic, retain) NSString * playlist_time_ago;
@property (nonatomic, retain) NSString * playlist_user_id;
@property (nonatomic, retain) NSSet *playlist_clips;
@property (nonatomic, retain) Timeline *playlist_timeline;
@end

@interface Playlist (CoreDataGeneratedAccessors)

- (void)addPlaylist_clipsObject:(Clip *)value;
- (void)removePlaylist_clipsObject:(Clip *)value;
- (void)addPlaylist_clips:(NSSet *)values;
- (void)removePlaylist_clips:(NSSet *)values;

@end
