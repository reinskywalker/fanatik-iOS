//
//  ActivityVideoTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "ActivityVideoTableViewCell.h"

@implementation ActivityVideoTableViewCell

@synthesize userActivityDesc;
@synthesize activityTimeLabel;
@synthesize videoImageView;

@synthesize videoDurationView;
@synthesize videoDurationLabel;

@synthesize videoTitle;
@synthesize likeButton;
@synthesize likeCountLabel;

@synthesize commentButton;
@synthesize commentCountLabel, delegate;
@synthesize userImageView, activityLabel, timeLabel;

-(void)fillWithTimeline:(Timeline *)obj{
    self.currentTimeline = obj;
    
    videoImageView.image = nil;
    [self.videoImageView sd_setImageWithURL:[NSURL URLWithString:obj.timeline_clip.clip_video.video_thumbnail.thumbnail_720]];
    self.videoTitle.text = obj.timeline_clip.clip_content;

    self.likeCountLabel.text = [NSString stringWithFormat:@"%@",obj.timeline_clip.clip_stats.clip_stats_likes];
    self.commentCountLabel.text = [NSString stringWithFormat:@"%@",obj.timeline_clip.clip_stats.clip_stats_comments];
    

    

    self.videoDurationLabel.text = obj.timeline_clip.clip_video.video_duration;

    //--
    
    self.contentView.backgroundColor = [UIColor orangeColor];
    self.backgroundView.backgroundColor = [UIColor greenColor];
    
    NSLog(@"url = %@",obj.timeline_actor.actor_avatar.avatar_thumbnail);
    NSURL *avatarURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", obj.timeline_actor.actor_avatar.avatar_thumbnail]];
    self.userImageView.image = nil;
    [self.userImageView sd_setImageWithURL:avatarURL];
    
    self.timeLabel.text = [obj valueForKey:@"timeline_time_ago"];
    
    NSString *htmlString = [NSString stringWithFormat:@"%@",[obj valueForKey:@"timeline_description"]];
    
    self.activityLabel.attributedText  = [OHASBasicHTMLParser attributedStringByProcessingMarkupInAttributedString:[TheInterfaceManager processedOHHTMLString:htmlString andFontSize:12.0]];
    self.activityLabel.numberOfLines = 2;
    
    
    [self layoutIfNeeded];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.userImageView.layer.cornerRadius = CGRectGetWidth(self.userImageView.frame)/2;
    self.userImageView.layer.masksToBounds = YES;
}


- (IBAction)detailButtonTapped:(id)sender {
    [delegate timelineVideoTableViewCell:self moreButtonDidTapForClip:self.currentTimeline.timeline_clip];
}

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}



- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
