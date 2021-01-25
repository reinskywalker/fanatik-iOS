//
//  OtherTableViewCell.m
//  DMMoviePlayer
//
//  Created by Erick Martin on 10/22/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "OtherTableViewCell.h"
#import "NSString+size.h"
#import "UIImageView+WebCache.h"

#define marginRight 50
#define marginCell 10
#define offsetCell 65

@implementation OtherTableViewCell

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)fillCellWithMessage:(Message *)aMes{
    self.currentMessage = aMes;
    _userImageView.image = nil;
    [_userImageView sd_setImageWithURL:[NSURL URLWithString:aMes.messageUserAvatarURL]];
    _userNameLabel.text = aMes.messageUserName;
    _chatLabel.text = aMes.messageContent;
    self.chatDateLabel.text = aMes.messageSentDate;
    
    CGSize actualSize = [self.currentMessage.messageContent sizeOfTextByBoundingWidth:TheAppDelegate.deviceWidth - offsetCell andFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:15.0]];
    
    CGRect modFrame = _chatLabel.frame;
    modFrame.size.height =  actualSize.height;
    modFrame.size.width = actualSize.width;
    _chatLabel.frame = modFrame;
    modFrame = _containerView.frame;
    modFrame.size.height = actualSize.height + marginCell;
    modFrame.size.width = actualSize.width + marginCell;
    _containerView.frame = modFrame;
    modFrame = _chatDateLabel.frame;
    modFrame.origin.x = TheAppDelegate.deviceWidth - marginCell - _chatDateLabel.frame.size.width;
    _chatDateLabel.frame = modFrame;
    
    self.containerView.hidden = [aMes.messageType isEqualToString:MessageTypeSticker];
    self.bubbleImage.hidden = [aMes.messageType isEqualToString:MessageTypeSticker];
    self.stickerImgView.hidden = ![aMes.messageType isEqualToString:MessageTypeSticker];
    if([aMes.messageType isEqualToString:MessageTypeSticker]){
        [self.stickerImgView sd_setImageWithURL:[NSURL URLWithString:aMes.messageSticker.file]];
    }
}

-(CGFloat)cellHeight{
    CGSize actualSize = [self.currentMessage.messageContent sizeOfTextByBoundingWidth:TheAppDelegate.deviceWidth - offsetCell andFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:15.0]];
    
    return actualSize.height + 45;
}

- (void)layoutSubviews{
    [self cellHeight];
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - IBAction
-(void)userButtonTapped:(id)sender{
    if ([self.delegate respondsToSelector:@selector(OtherTableViewCell:didTapUserButton:)]) {
//        [self.delegate OtherTableViewCell:self didTapUserButton:self.theChat];
    }
}
@end
