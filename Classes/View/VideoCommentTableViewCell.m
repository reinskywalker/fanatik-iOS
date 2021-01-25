//
//  VideoCommentTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "VideoCommentTableViewCell.h"

#define STICKER_COMMENT @"STICKERCOMMENT"

@implementation VideoCommentTableViewCell

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)fillCellWithComment:(Comment *)aComment{
    self.currentComment = aComment;

    [_userImageView sd_setImageWithURL:[NSURL URLWithString:aComment.comment_user.user_avatar.avatar_thumbnail] placeholderImage:[UIImage imageNamed:@"iconPeople"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        _userImageView.layer.cornerRadius = _userImageView.frame.size.width/2;
        _userImageView.layer.masksToBounds = YES;
    }];

    _userNameLabel.text = aComment.comment_user.user_name;
    self.commentLabel.text = aComment.comment_content;
    
    self.commentDateLabel.text = [aComment dateString];// aComment.comment_time_ago;

    _commentLabel.hidden = [[aComment.comment_type uppercaseString] isEqualToString:STICKER_COMMENT];
    _stickerImageView.hidden = ![[aComment.comment_type uppercaseString] isEqualToString:STICKER_COMMENT];
    [_stickerImageView sd_setImageWithURL:[NSURL URLWithString:aComment.comment_content]];
}

-(CGFloat)cellHeight{
    CGFloat cellPadding = 13;
    CGSize correctLabelSize = [self.commentLabel.text sizeOfTextWithfont:self.commentLabel.font frame:self.commentLabel.frame];

    self.commentLabelHeightConstraint.constant = correctLabelSize.height;
    if([[self.currentComment.comment_type uppercaseString] isEqualToString:STICKER_COMMENT]){
        return 125.0;
    }
    
    float customHeight = self.commentLabel.frame.origin.y + self.commentLabelHeightConstraint.constant + cellPadding;
    if(customHeight > 55.0)
        return customHeight;
    return 55.0;
}

- (void)layoutSubviews{
    [self cellHeight];
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end
