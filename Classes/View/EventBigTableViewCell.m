//
//  EventBigTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "EventBigTableViewCell.h"

@implementation EventBigTableViewCell
@synthesize isPremiumLabel, currentEvent, gradient;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)fillWithEvent:(Event *)aEvent{
    self.currentEvent = aEvent;
    self.eventTitleLabel.text = currentEvent.event_name;
    self.eventThumbnailImage.image = nil;
    [self.eventThumbnailImage sd_setImageWithURL:[NSURL URLWithString:currentEvent.event_poster_thumbnail.thumbnail_480]];
    self.eventTimeLabel.text = aEvent.eventDateWithTimezone;
    
    isPremiumLabel.hidden = NO;
    if([self.currentEvent.event_badge_text isEqualToString:@""] || !self.currentEvent.event_badge_text){
        isPremiumLabel.hidden = YES;
    }
    isPremiumLabel.text = self.currentEvent.event_badge_text;
    
    CGRect resizedFrame = isPremiumLabel.frame;
    CGSize actualSize = [self.isPremiumLabel.text sizeOfTextByBoundingWidth:200.0 andFont:[UIFont systemFontOfSize:10.0]];
    actualSize.height = actualSize.height + 5.0;
    actualSize.width = actualSize.width + 15.0;
    resizedFrame.size = actualSize;
    [isPremiumLabel setFrame:resizedFrame];
    
    [isPremiumLabel setTextColor:[TheInterfaceManager convertColorStrToColor:self.currentEvent.event_badge_color isBackground:NO]];
    
    [isPremiumLabel setBackgroundColor:[TheInterfaceManager convertColorStrToColor:self.currentEvent.event_badge_background isBackground:YES]];
    
    if(!gradient){
        gradient = [CAGradientLayer layer];
        CGRect gradientFrame = _gradientView.bounds;
        gradientFrame.size.width = TheAppDelegate.deviceWidth - 20.0;
        gradient.frame = gradientFrame;
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, nil];
        gradient.startPoint = CGPointMake(1.0f, 0.7f);
        gradient.endPoint = CGPointMake(1.0f, 0.0f);
        [_gradientView.layer insertSublayer:gradient atIndex:0];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
