//
//  VideoRelatedTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "VideoRelatedTableViewCell.h"

@implementation VideoRelatedTableViewCell
@synthesize delegate, isPremiumLabel;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (IBAction)moreButtonTapped:(id)sender {
    [delegate videoTableViewCell:self moreButtonDidTap:self.currentClip];
}

-(void)fillWithClip:(Clip *)aClip{
    self.currentClip = aClip;
    self.videoTitleLabel.text = aClip.clip_content;
    self.videoThumbnailImage.image = nil;
    [self.videoThumbnailImage sd_setImageWithURL:[NSURL URLWithString:aClip.clip_video.video_thumbnail.thumbnail_720]];
    if(self.isLastRow){
        self.footerView.hidden = NO;
    }else{
        self.footerView.hidden = YES;
    }
    
    NSString *htmlString = [NSString stringWithFormat:@"<b>%@</b> views",aClip.clip_stats.clip_stats_views ];
    
    
    NSAttributedString *as = [[[DTHTMLAttributedStringBuilder alloc]
                               initWithHTML:[htmlString dataUsingEncoding:NSUnicodeStringEncoding]
                               options:@{
                                         DTDefaultFontSize: @(10),
                                         DTDefaultFontFamily: InterfaceStr(@"default_font_regular"),
                                         DTDefaultTextColor: HEXCOLOR(0x666666FF)
                                         }
                               documentAttributes:NULL] generatedAttributedString];
    
    
    self.videoViewAttributedLabel.attributedString = as;
    self.videoViewAttributedLabel.numberOfLines = 1;
    
    isPremiumLabel.hidden = NO;
    if([self.currentClip.clip_badge_text isEqualToString:@""] || !self.currentClip.clip_badge_text){
        isPremiumLabel.hidden = YES;
    }
    isPremiumLabel.text = self.currentClip.clip_badge_text;
    
    CGRect resizedFrame = isPremiumLabel.frame;
    CGSize actualSize = [self.isPremiumLabel.text sizeOfTextByBoundingWidth:90.0 andFont:[UIFont systemFontOfSize:12.0]];
    actualSize.height = actualSize.height + 10.0;
    actualSize.width = actualSize.width + 15.0;
    resizedFrame.size = actualSize;
    [isPremiumLabel setFrame:resizedFrame];
    
    [isPremiumLabel setTextColor:[TheInterfaceManager convertColorStrToColor:self.currentClip.clip_badge_text_color isBackground:NO]];
    
    [isPremiumLabel setBackgroundColor:[TheInterfaceManager convertColorStrToColor:self.currentClip.clip_badge_bg_color isBackground:YES]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
