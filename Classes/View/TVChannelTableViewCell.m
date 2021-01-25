//
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/23/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "TVChannelTableViewCell.h"

@implementation TVChannelTableViewCell
@synthesize isPremiumLabel, currentLive;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)setCellWithLive:(Live *)obj{
    self.currentLive = obj;
    
    isPremiumLabel.hidden = NO;
    if([currentLive.live_badge_text isEqualToString:@""] || !currentLive.live_badge_text){
        isPremiumLabel.hidden = YES;
    }
    isPremiumLabel.text = currentLive.live_badge_text;
    
    CGRect resizedFrame = isPremiumLabel.frame;
    CGSize actualSize = [self.isPremiumLabel.text sizeOfTextByBoundingWidth:TheAppDelegate.deviceWidth-40.0 andFont:[UIFont systemFontOfSize:12.0]];
    actualSize.height = actualSize.height + 10.0;
    actualSize.width = actualSize.width + 15.0;
    resizedFrame.size = actualSize;
    [isPremiumLabel setFrame:resizedFrame];
    
    [isPremiumLabel setTextColor:[TheInterfaceManager convertColorStrToColor:self.currentLive.live_badge_text_color isBackground:NO]];
    
    [isPremiumLabel setBackgroundColor:[TheInterfaceManager convertColorStrToColor:self.currentLive.live_badge_bg_color isBackground:YES]];
    
    self.liveImageView.image = nil;
    [self.liveImageView sd_setImageWithURL:[NSURL URLWithString:obj.live_thumbnail.thumbnail_480]];
    self.channelNameLabel.text = obj.live_title;
    self.likeCountLabel.text = [obj.live_clip_stat.clip_stats_likes stringValue];
    self.commentCountLabel.text = [obj.live_clip_stat.clip_stats_comments stringValue];
}

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}
@end
