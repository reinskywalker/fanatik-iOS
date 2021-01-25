//
//  ActivityUserTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "ActivityUserTableViewCell.h"


@implementation ActivityUserTableViewCell

@synthesize userBackgroundImage;
@synthesize userAvatarImage;
@synthesize userNameLabel;
@synthesize userImageView, activityLabel, timeLabel;

-(void)fillWithTimeline:(Timeline *)obj{
    userAvatarImage.layer.cornerRadius = CGRectGetHeight(userAvatarImage.frame)/2;
    userAvatarImage.layer.masksToBounds = YES;
    
    [TheInterfaceManager addBorderViewForImageView:userAvatarImage withBorderWidth:2 andBorderColor:nil];
    
        
    
    User *user = obj.timeline_user;
    userAvatarImage.image = nil;
    [userAvatarImage sd_setImageWithURL:[NSURL URLWithString:user.user_avatar.avatar_thumbnail]];
    
    userBackgroundImage.image = nil;
    [userBackgroundImage sd_setImageWithURL:[NSURL URLWithString:user.user_cover_image.cover_image_640]];
    
    userNameLabel.text = user.user_name;
    
    
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
