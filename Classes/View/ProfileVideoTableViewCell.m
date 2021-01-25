//
//  ProfileVideoTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "ProfileVideoTableViewCell.h"

@interface ProfileVideoTableViewCell()
@property(nonatomic, retain) Clip *currentClip;
@end

@implementation ProfileVideoTableViewCell

@synthesize userNameLabel;
@synthesize userImageView;
@synthesize activityTimeLabel;
@synthesize videoImageView;

@synthesize videoDurationView;
@synthesize videoDurationLabel;

@synthesize videoTitle;
@synthesize likeButton;
@synthesize likeCountLabel;

@synthesize commentButton;
@synthesize commentCountLabel, delegate, currentClip;

-(void)fillWithClip:(Clip *)obj{
    self.currentClip = obj;
    videoImageView.image = nil;
    [self.videoImageView sd_setImageWithURL:[NSURL URLWithString:obj.clip_video.video_thumbnail.thumbnail_720]];
    self.videoTitle.text = obj.clip_content;

    self.likeCountLabel.text = [NSString stringWithFormat:@"%@",obj.clip_stats.clip_stats_likes];
    self.commentCountLabel.text = [NSString stringWithFormat:@"%@",obj.clip_stats.clip_stats_comments];
    self.videoDurationLabel.text = obj.clip_video.video_duration;
    
    userImageView.image = nil;
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:obj.clip_user.user_avatar.avatar_thumbnail]];
    self.userNameLabel.text = obj.clip_user.user_name;
    
    CGRect resizedFrame = videoTitle.frame;
    CGSize actualSize = [self.videoTitle.text sizeOfTextByBoundingWidth:TheAppDelegate.deviceWidth-24.0 andFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:14.0]];
    
    if(actualSize.height > 40.0){
        actualSize.height = 40.0;
    }
    resizedFrame.size = actualSize;
    [videoTitle setFrame:resizedFrame];
    
    resizedFrame = _bottomView.frame;
    resizedFrame.origin.y = videoTitle.frame.origin.y + videoTitle.frame.size.height;
    [_bottomView setFrame:resizedFrame];
}

- (IBAction)deleteButtonTapped:(id)sender {
    if([delegate respondsToSelector:@selector(deleteClipWithId:)]){
        [delegate deleteClipWithId:self.currentClip.clip_id];
    }
}

- (IBAction)detailButtonTapped:(id)sender {
    if([delegate respondsToSelector:@selector(profileVideoTableViewCell:detailButtonTappedForClip:)]){
        [delegate profileVideoTableViewCell:self detailButtonTappedForClip:self.currentClip];
        
    }
}

- (IBAction)likeButtonTapped:(id)sender {
}

- (IBAction)commentButtonTapped:(id)sender {
    
}

-(CGFloat)cellHeight{
    
    CGSize actualSize = [currentClip.clip_content sizeOfTextByBoundingWidth:TheAppDelegate.deviceWidth-24.0 andFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:14.0]];
    
    if(actualSize.height > 35.0){
        return 255.0;
    }
    return 235.0;
}

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)layoutSubviews{
    [self cellHeight];
    [super layoutSubviews];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    userImageView.layer.cornerRadius = CGRectGetHeight(userImageView.frame)/2.0;
    userImageView.layer.masksToBounds = YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}



@end
