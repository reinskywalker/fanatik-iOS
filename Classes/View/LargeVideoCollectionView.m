//
//  LargeVideoTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/12/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "LargeVideoCollectionView.h"
#import "Thumbnail+functionality.h"
#import "Video+functionality.h"
#import "ClipStats+functionality.h"

@implementation LargeVideoCollectionView
@synthesize delegate, videoThumbnailImage, isPremiumLabel, durationView, durationLabel;
@synthesize bottomView, videoTitleLabel, likeCountLabel, commentCountLabel;
@synthesize userNameLabel, userAvatarImageView, currentClip;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)setItem:(Clip *)clip{
    
    self.currentClip = clip;
    
    userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.size.height /2;
    userAvatarImageView.layer.masksToBounds = YES;
    
    [TheInterfaceManager addBorderViewForImageView:userAvatarImageView withBorderWidth:2.0 andBorderColor:HEXCOLOR(0xcecece33)];

    durationView.layer.cornerRadius = 4.0;
    durationView.layer.masksToBounds = YES;
    
    videoThumbnailImage.image = nil;
    [videoThumbnailImage sd_setImageWithURL:[NSURL URLWithString:currentClip.clip_video.video_thumbnail.thumbnail_720]];
    
    userAvatarImageView.image = nil;
    [userAvatarImageView sd_setImageWithURL:[NSURL URLWithString:currentClip.clip_user.user_avatar.avatar_thumbnail]];
    
    userNameLabel.text = currentClip.clip_user.user_name;
    
    isPremiumLabel.hidden = NO;
    if([currentClip.clip_badge_text isEqualToString:@""] || !currentClip.clip_badge_text){
        isPremiumLabel.hidden = YES;
    }
    isPremiumLabel.text = currentClip.clip_badge_text;
    
    CGRect resizedFrame = isPremiumLabel.frame;
    CGSize actualSize = [self.isPremiumLabel.text sizeOfTextByBoundingWidth:267.0 andFont:[UIFont systemFontOfSize:12.0]];
    actualSize.height = actualSize.height + 10.0;
    actualSize.width = actualSize.width + 15.0;
    resizedFrame.size = actualSize;
    [isPremiumLabel setFrame:resizedFrame];

    [isPremiumLabel setTextColor:[TheInterfaceManager convertColorStrToColor:self.currentClip.clip_badge_text_color isBackground:NO]];
    
    [isPremiumLabel setBackgroundColor:[TheInterfaceManager convertColorStrToColor:self.currentClip.clip_badge_bg_color isBackground:YES]];
    
    durationLabel.text = currentClip.clip_video.video_duration;
    
    videoTitleLabel.text = currentClip.clip_content;
    
    likeCountLabel.text = [NSString stringWithFormat:@"%@", currentClip.clip_stats.clip_stats_likes];
    
    commentCountLabel.text = [NSString stringWithFormat:@"%@", currentClip.clip_stats.clip_stats_comments];
    
    resizedFrame = videoTitleLabel.frame;
    actualSize = [self.videoTitleLabel.text sizeOfTextByBoundingWidth:267.0 andFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:14.0]];
    
    if(actualSize.height > 40.0){
        actualSize.height = 40.0;
    }
    resizedFrame.size = actualSize;
    [videoTitleLabel setFrame:resizedFrame];
    
//    resizedFrame = _loveCommentView.frame;
//    resizedFrame.origin.y = videoTitleLabel.frame.origin.y + videoTitleLabel.frame.size.height - 8.0;
//    [_loveCommentView setFrame:resizedFrame];
}

#pragma mark - IBAction
-(void)moreButtonTapped:(id)sender{
    [delegate didTapMoreButtonForClip:currentClip];
}
@end
