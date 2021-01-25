//
//  TVChannelInfoTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/23/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "TVChannelInfoTableViewCell.h"

@implementation TVChannelInfoTableViewCell

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)setCellWithLive:(Live *)obj{
    self.currentLive = obj;
    self.liveTitleLabel.text = obj.live_title;
    self.liveDescriptionLabel.text = obj.live_description;
    _downArrow.hidden = [obj.live_description isEqualToString:@""];
}


-(CGFloat)cellHeight{
    CGFloat cellPadding = 15;
    CGFloat labelWidth = CGRectGetWidth(self.liveDescriptionLabel.frame);
    CGSize labelSize = !self.isExpanded?CGSizeMake(labelWidth, 50):CGSizeMake(labelWidth, 1000);
    CGSize fitSize = [self.liveDescriptionLabel sizeThatFits:self.liveDescriptionLabel.frame.size];
    CGSize correctLabelSize = self.liveDescriptionLabel.frame.size; //[self.currentClip.clip_video.video_description sizeOfTextWithfont:self.videoDescLabel.font frame:tempFrame];
    //    correctLabelSize.height+=10;
    correctLabelSize.height = fitSize.height;
    if(correctLabelSize.height < 50){
        correctLabelSize.height = 50;
    }
    [_downArrow setImage:[UIImage imageNamed:self.isExpanded?@"upArrow":@"downArrow"]];
    self.liveDescriptionLabelHeight.constant = self.isExpanded ? correctLabelSize.height : labelSize.height;
    return ceilf( self.liveDescriptionLabel.frame.origin.y + self.liveDescriptionLabelHeight.constant + cellPadding );
}

- (void)layoutSubviews{
    [self cellHeight];
    [super layoutSubviews];
}

@end
