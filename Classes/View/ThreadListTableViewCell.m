//
//  ThreadListTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/13/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ThreadListTableViewCell.h"

@implementation ThreadListTableViewCell

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

-(void)fillWithThread:(Thread *)obj{
    self.myImageView.image = nil;
    
    if(obj.thread_image_url && ![obj.thread_image_url isEqualToString:@""]){
        [self.myImageView sd_setImageWithURL:[NSURL URLWithString:obj.thread_image_url]];
    }else{
        [self.myImageView sd_setImageWithURL:[NSURL URLWithString:obj.thread_user.user_avatar.avatar_thumbnail]];
    }
    
    self.titleLabel.text = obj.thread_title;
    self.commentCountLabel.text = obj.thread_stats.thread_stats_comments;
    self.likeCountLabel.text = obj.thread_stats.thread_stats_likes;
    self.timeLabel.text = obj.thread_time_ago;
    
    CGRect resizedFrame = self.titleLabel.frame;
    CGSize actualSize = [self.titleLabel.text sizeOfTextByBoundingWidth:TheAppDelegate.deviceWidth-90.0 andFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:12.0]];
    
    if(actualSize.height > 40.0){
        actualSize.height = 40.0;
    }
    resizedFrame.size = actualSize;
    [self.titleLabel setFrame:resizedFrame];
}

-(void)fillWithDummyData{
    [self.myImageView sd_setImageWithURL:[NSURL URLWithString:@"https://s-media-cache-ak0.pinimg.com/originals/e3/36/ba/e336ba8898e622e2872fa727208d2c71.jpg"]];
    self.titleLabel.text = @"Tersingkir dari Liga Champions Chelsea alih profesi jadi Artis?";
    self.commentCountLabel.text = @"24k";
    self.likeCountLabel.text = @"365k";
    self.timeLabel.text = @"Updated 23s ago";

}

@end
