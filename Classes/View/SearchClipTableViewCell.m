//
//  SearchClipTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/11/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "SearchClipTableViewCell.h"
#import "ContestWinners.h"

@implementation SearchClipTableViewCell

@synthesize delegate, premiumLabel, usernameLabel;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

-(void)fillWithClip:(Clip *)aClip{
    self.currentClip = aClip;
    self.videoImageView.image = nil;
    [self.videoImageView sd_setImageWithURL:[NSURL URLWithString:aClip.clip_video.video_thumbnail.thumbnail_small]];
    self.videoTitleLabel.text = aClip.clip_content;
    
    CGRect resizedFrame = self.videoTitleLabel.frame;
    CGSize actualSize = [self.videoTitleLabel.text sizeOfTextByBoundingWidth:TheAppDelegate.deviceWidth - 138.0 andFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:12.0]];
    
    if(actualSize.height > 35.0){
        actualSize.height = 35.0;
    }
    resizedFrame.size = actualSize;
    [self.videoTitleLabel setFrame:resizedFrame];
    
    usernameLabel.text = self.currentClip.clip_user.user_name;
    resizedFrame = usernameLabel.frame;
    resizedFrame.origin.y = self.videoTitleLabel.frame.origin.y + self.videoTitleLabel.frame.size.height;
    [usernameLabel setFrame:resizedFrame];
    
    NSString *htmlString = [NSString stringWithFormat:@"<b>%@</b> views",aClip.clip_stats.clip_stats_views];
    
    
    NSAttributedString *as = [[[DTHTMLAttributedStringBuilder alloc]
                               initWithHTML:[htmlString dataUsingEncoding:NSUnicodeStringEncoding]
                               options:@{
                                         DTDefaultFontSize: @(11),
                                         DTDefaultFontFamily: InterfaceStr(@"default_font_regular"),
                                         DTDefaultTextColor: HEXCOLOR(0x666666FF)
                                         }
                               documentAttributes:NULL] generatedAttributedString];
    
    
    self.viewCountLabel.attributedString = as;
    self.viewCountLabel.numberOfLines = 1;
    
    resizedFrame = self.viewCountLabel.frame;
    resizedFrame.origin.y = self.usernameLabel.frame.origin.y + self.usernameLabel.frame.size.height;
    [self.viewCountLabel setFrame:resizedFrame];
    
    premiumLabel.hidden = NO;
    if([self.currentClip.clip_badge_text isEqualToString:@""] || !self.currentClip.clip_badge_text){
        premiumLabel.hidden = YES;
    }
    premiumLabel.text = self.currentClip.clip_badge_text;
    premiumLabel.backgroundColor = HEXCOLOR(0xFFCC00D9);
    
    resizedFrame = premiumLabel.frame;
    actualSize = [self.premiumLabel.text sizeOfTextByBoundingWidth:90.0 andFont:[UIFont systemFontOfSize:10.0]];
    actualSize.height = actualSize.height + 5.0;
    actualSize.width = actualSize.width + 10.0;
    resizedFrame.size = actualSize;
    [premiumLabel setFrame:resizedFrame];
    
    [premiumLabel setTextColor:[TheInterfaceManager convertColorStrToColor:self.currentClip.clip_badge_text_color isBackground:NO]];
    
    [premiumLabel setBackgroundColor:[TheInterfaceManager convertColorStrToColor:self.currentClip.clip_badge_bg_color isBackground:YES]];
    
    NSString *winStr = @"";
    switch ([aClip.clip_contest_winners.contest_winners_position integerValue]) {
        case 1:
            winStr = @"first_winner";
            break;
        case 2:
            winStr = @"second_winner";
            break;
        case 3:
            winStr = @"third_winner";
            break;
        default:
            winStr = @"";
            break;
    }
    _badgeWinner.hidden = YES;
    if(winStr && [winStr length] > 0){
        _badgeWinner.hidden = NO;
        [_badgeWinner setImage:[UIImage imageNamed:winStr]];
    }
}

- (IBAction)moreButtonTapped:(id)sender {
    [delegate moreButtonDidTapForClip:self.currentClip];
}

@end
