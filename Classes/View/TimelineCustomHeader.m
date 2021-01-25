//
//  TimelineCustomHeader.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/30/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "TimelineCustomHeader.h"


@interface TimelineCustomHeader ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightActivityLabel;

@end

@implementation TimelineCustomHeader




- (void) fillWithTimeline:(Timeline*)obj{
    
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
    
    CGSize size = [self.activityLabel sizeThatFits:self.activityLabel.frame.size];
    self.constraintHeightActivityLabel.constant = size.height;
    
    self.userImageView.layer.cornerRadius = CGRectGetWidth(self.userImageView.frame)/2;
    self.userImageView.layer.masksToBounds = YES;

}

@end
