//
//  LargeVideoTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/12/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "SmallVideoCollectionView.h"
#import "Thumbnail+functionality.h"
#import "Video+functionality.h"
#import "ClipStats+functionality.h"

@implementation SmallVideoCollectionView

@synthesize delegate, videoThumbnailImage, durationView, durationLabel;
@synthesize bottomView, videoTitleLabel, currentClip, userNameLabel,userAvatarImageView;
@synthesize isPremiumLabel;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)setItem:(Clip *)clip{
    self.currentClip = clip;
    
    [videoThumbnailImage sd_setImageWithURL:[NSURL URLWithString:currentClip.clip_video.video_thumbnail.thumbnail_small]];
    
    durationLabel.text = currentClip.clip_video.video_duration;
    
    videoTitleLabel.text = currentClip.clip_content;
    
    userNameLabel.text = currentClip.clip_user.user_name;

    isPremiumLabel.hidden = NO;
    if([currentClip.clip_badge_text isEqualToString:@""] || !currentClip.clip_badge_text){
        isPremiumLabel.hidden = YES;
    }
    isPremiumLabel.text = currentClip.clip_badge_text;
    
    CGRect resizedFrame = isPremiumLabel.frame;
    CGSize actualSize = [self.isPremiumLabel.text sizeOfTextByBoundingWidth:150.0 andFont:[UIFont systemFontOfSize:10.0]];
    actualSize.height = actualSize.height + 10.0;
    actualSize.width = actualSize.width + 5.0;
    resizedFrame.size = actualSize;
    [isPremiumLabel setFrame:resizedFrame];
    
    [isPremiumLabel setTextColor:[TheInterfaceManager convertColorStrToColor:self.currentClip.clip_badge_text_color isBackground:NO]];
    
    [isPremiumLabel setBackgroundColor:[TheInterfaceManager convertColorStrToColor:self.currentClip.clip_badge_bg_color isBackground:YES]];
    
    resizedFrame = videoTitleLabel.frame;
    actualSize = [self.videoTitleLabel.text sizeOfTextByBoundingWidth:150.0 andFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:12.0]];
    if(actualSize.height > 35){
        actualSize.height = 35.0;
    }
    resizedFrame.size = actualSize;
    [videoTitleLabel setFrame:resizedFrame];
}

@end
