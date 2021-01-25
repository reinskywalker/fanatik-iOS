//
//  TimelineVideoTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "TimelineVideoTableViewCell.h"


@implementation TimelineVideoTableViewCell

@synthesize userActivityDesc;
@synthesize userImageView;
@synthesize activityTimeLabel;
@synthesize videoImageView;

@synthesize videoDurationView;
@synthesize videoDurationLabel;

@synthesize videoTitle;
@synthesize likeButton;
@synthesize likeCountLabel;

@synthesize commentButton;
@synthesize commentCountLabel, delegate;

-(void)fillWithTimeline:(Timeline *)obj{
    self.currentTimeline = obj;
    
    videoImageView.image = nil;
    [self.videoImageView sd_setImageWithURL:[NSURL URLWithString:obj.timeline_clip.clip_video.video_thumbnail.thumbnail_720]];
    self.videoTitle.text = obj.timeline_clip.clip_content;

    self.likeCountLabel.text = [NSString stringWithFormat:@"%@",obj.timeline_clip.clip_stats.clip_stats_likes];
    self.commentCountLabel.text = [NSString stringWithFormat:@"%@",obj.timeline_clip.clip_stats.clip_stats_comments];
    

    

    self.videoDurationLabel.text = obj.timeline_clip.clip_video.video_duration;
}

- (IBAction)detailButtonTapped:(id)sender {
    [delegate timelineVideoTableViewCell:self moreButtonDidTapForClip:self.currentTimeline.timeline_clip];
}

- (IBAction)likeButtonTapped:(id)sender {
}

- (IBAction)commentButtonTapped:(id)sender {
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
