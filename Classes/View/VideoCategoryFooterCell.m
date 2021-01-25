//
//  VideoCategoryFooterCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 5/20/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "VideoCategoryFooterCell.h"

@implementation VideoCategoryFooterCell
@synthesize delegate, currentClipGroup, currentContest;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (IBAction)moreVideosButtonTapped:(id)sender {
    
    if(currentClipGroup)
        [delegate didTapMoreVideosButton:currentClipGroup];
    else if(currentContest)
        [delegate didTapMoreVideosButton:currentContest];
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
