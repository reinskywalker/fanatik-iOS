//
//  Clip+CoreDataProperties.h
//  Fanatik
//
//  Created by Erick Martin on 5/2/16.
//  Copyright © 2016 Domikado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Clip.h"

NS_ASSUME_NONNULL_BEGIN

@interface Clip (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *clip_badge_bg_color;
@property (nullable, nonatomic, retain) NSString *clip_badge_text;
@property (nullable, nonatomic, retain) NSString *clip_badge_text_color;
@property (nullable, nonatomic, retain) NSString *clip_content;
@property (nullable, nonatomic, retain) NSNumber *clip_id;
@property (nullable, nonatomic, retain) NSNumber *clip_liked;
@property (nullable, nonatomic, retain) NSNumber *clip_position;
@property (nullable, nonatomic, retain) NSDate *clip_published_at;
@property (nullable, nonatomic, retain) NSString *clip_time_ago;
@property (nullable, nonatomic, retain) NSString *clip_type;
@property (nullable, nonatomic, retain) ClipCategory *clip_clip_category;
@property (nullable, nonatomic, retain) NSSet<ClipGroup *> *clip_clip_group;
@property (nullable, nonatomic, retain) NSSet<Comment *> *clip_comment;
@property (nullable, nonatomic, retain) Contest *clip_contest;
@property (nullable, nonatomic, retain) ContestWinners *clip_contest_winners;
@property (nullable, nonatomic, retain) Event *clip_event;
@property (nullable, nonatomic, retain) Like *clip_like;
@property (nullable, nonatomic, retain) Pagination *clip_pagination;
@property (nullable, nonatomic, retain) NSSet<Playlist *> *clip_playlist;
@property (nullable, nonatomic, retain) NSSet<Clip *> *clip_related_clips;
@property (nullable, nonatomic, retain) Shareable *clip_shareable;
@property (nullable, nonatomic, retain) ClipStats *clip_stats;
@property (nullable, nonatomic, retain) Timeline *clip_timeline;
@property (nullable, nonatomic, retain) User *clip_user;
@property (nullable, nonatomic, retain) Video *clip_video;
@property (nullable, nonatomic, retain) Notification *clip_notification;

@end

@interface Clip (CoreDataGeneratedAccessors)

- (void)addClip_clip_groupObject:(ClipGroup *)value;
- (void)removeClip_clip_groupObject:(ClipGroup *)value;
- (void)addClip_clip_group:(NSSet<ClipGroup *> *)values;
- (void)removeClip_clip_group:(NSSet<ClipGroup *> *)values;

- (void)addClip_commentObject:(Comment *)value;
- (void)removeClip_commentObject:(Comment *)value;
- (void)addClip_comment:(NSSet<Comment *> *)values;
- (void)removeClip_comment:(NSSet<Comment *> *)values;

- (void)addClip_playlistObject:(Playlist *)value;
- (void)removeClip_playlistObject:(Playlist *)value;
- (void)addClip_playlist:(NSSet<Playlist *> *)values;
- (void)removeClip_playlist:(NSSet<Playlist *> *)values;

- (void)addClip_related_clipsObject:(Clip *)value;
- (void)removeClip_related_clipsObject:(Clip *)value;
- (void)addClip_related_clips:(NSSet<Clip *> *)values;
- (void)removeClip_related_clips:(NSSet<Clip *> *)values;

@end

NS_ASSUME_NONNULL_END
