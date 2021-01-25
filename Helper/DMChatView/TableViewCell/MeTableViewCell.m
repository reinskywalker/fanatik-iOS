//
//  MeTableViewCell.m
//  DMMoviePlayer
//
//  Created by Erick Martin on 10/22/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "MeTableViewCell.h"
#import "NSString+size.h"
#import "UIImageView+WebCache.h"

#define marginRight 50
#define marginCell 10
#define offsetCell 65

@implementation MeTableViewCell
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
    
    _userImageView.image = nil;
    [_userImageView sd_setImageWithURL:[NSURL URLWithString:aMes.messageUserAvatarURL]];
    _userNameLabel.text = aMes.messageUserName;
    _chatLabel.text = aMes.messageContent;
    self.chatDateLabel.text = [aMes messageSentDate];
    
    CGSize actualSize = [self.currentMessage.messageContent sizeOfTextByBoundingWidth:TheAppDelegate.deviceWidth - offsetCell andFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:15.0]];

    CGRect modFrame = _chatLabel.frame;
    modFrame.size.height =  actualSize.height;
    modFrame.size.width = actualSize.width;
    _chatLabel.frame = modFrame;
    modFrame = _containerView.frame;
    modFrame.size.height = actualSize.height + marginCell;
    modFrame.size.width = actualSize.width + marginCell;
    modFrame.origin.x = TheAppDelegate.deviceWidth - marginRight - modFrame.size.width;
    _containerView.frame = modFrame;
    modFrame = _userNameLabel.frame;
    modFrame.origin.x = TheAppDelegate.deviceWidth - marginRight -  _userNameLabel.frame.size.width;
    _userNameLabel.frame = modFrame;
    modFrame = _bubbleImage.frame;
    modFrame.origin.x = TheAppDelegate.deviceWidth - marginRight + 4 - _bubbleImage.frame.size.width;
    _bubbleImage.frame = modFrame;
    modFrame = _stickerImgView.frame;
    modFrame.origin.x = TheAppDelegate.deviceWidth - marginRight - _stickerImgView.frame.size.width;
    _stickerImgView.frame = modFrame;
    modFrame = _userImageView.frame;
    modFrame.origin.x =  TheAppDelegate.deviceWidth - marginCell - _userImageView.frame.size.width;
    _userImageView.frame = modFrame;

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
@end
