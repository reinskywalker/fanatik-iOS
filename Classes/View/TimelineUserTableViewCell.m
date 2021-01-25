//
//  TimelineUserTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "TimelineUserTableViewCell.h"


@implementation TimelineUserTableViewCell

@synthesize userBackgroundImage;
@synthesize userAvatarImage;
@synthesize userNameLabel;

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
