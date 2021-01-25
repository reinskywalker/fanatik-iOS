//
//  WhisperListTableViewCell.m
//  DMMoviePlayer
//
//  Created by Teguh Hidayatullah on 10/29/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "WhisperListTableViewCell.h"

@implementation WhisperListTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

-(void)fillWithUserName:(NSString *)name{
    self.nameLabel.text = name;
}

@end
