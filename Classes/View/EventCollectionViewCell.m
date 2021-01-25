//
//  EventCollectionViewCell.m
//  Fanatik
//
//  Created by Erick Martin on 11/16/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "EventCollectionViewCell.h"

@implementation EventCollectionViewCell
@synthesize currentEvent, isPremiumLabel;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

-(void)setItem:(Event *)aEvent{
    
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
    CGSize actualSize = [self.isPremiumLabel.text sizeOfTextByBoundingWidth:90.0 andFont:[UIFont systemFontOfSize:12.0]];
    actualSize.height = actualSize.height + 5.0;
    actualSize.width = actualSize.width + 15.0;
    resizedFrame.size = actualSize;
    [isPremiumLabel setFrame:resizedFrame];
    
    [isPremiumLabel setTextColor:[TheInterfaceManager convertColorStrToColor:self.currentEvent.event_badge_color isBackground:NO]];
    
    [isPremiumLabel setBackgroundColor:[TheInterfaceManager convertColorStrToColor:self.currentEvent.event_badge_background isBackground:YES]];
    
    resizedFrame = _eventTitleLabel.frame;
    actualSize = [self.eventTitleLabel.text sizeOfTextByBoundingWidth:150.0 andFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:12.0]];
    if(actualSize.height > 35){
        actualSize.height = 35.0;
    }
    
    resizedFrame.size = actualSize;
    [_eventTitleLabel setFrame:resizedFrame];

}
- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

@end
