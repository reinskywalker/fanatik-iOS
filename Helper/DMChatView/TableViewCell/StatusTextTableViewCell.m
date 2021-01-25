//
//  MeTableViewCell.m
//  DMMoviePlayer
//
//  Created by Erick Martin on 10/22/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "StatusTextTableViewCell.h"
#import "NSString+size.h"
#import "UIImageView+WebCache.h"

#define marginRight 50
#define marginCell 10
#define offsetCell 65

@implementation StatusTextTableViewCell
@synthesize currentMessage;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)fillCellWithMessage:(Message *)aMes{
    currentMessage = aMes;
    _chatLabel.text = aMes.messageContent;
    self.chatDateLabel.text = aMes.dateString;
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end
