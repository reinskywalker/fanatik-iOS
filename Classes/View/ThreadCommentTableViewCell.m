//
//  ThreadCommentTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ThreadCommentTableViewCell.h"

@implementation ThreadCommentTableViewCell
@synthesize delegate, currentComment;

- (IBAction)moreButtonTapped:(id)sender {
    [delegate threadCommentTableViewCell:self moreButtonDidTapForComment:currentComment];
}

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)fillCellWithComment:(ThreadComment *)aComment{
    self.currentComment = aComment;
    _userImageView.layer.cornerRadius = _userImageView.frame.size.width/2;
    _userImageView.layer.masksToBounds = YES;
    
    _userImageView.image = nil;
    [_userImageView sd_setImageWithURL:[NSURL URLWithString:aComment.thread_comment_user.user_avatar.avatar_thumbnail]];
    _userNameLabel.text = aComment.thread_comment_user.user_name;
    self.commentLabel.text = aComment.thread_comment_content;
    
    self.commentDateLabel.text = aComment.thread_comment_time_ago;
}


-(CGFloat)cellHeight{
    CGFloat cellPadding = 20;
    CGSize correctLabelSize = [self.commentLabel.text sizeOfTextWithfont:self.commentLabel.font frame:self.commentLabel.frame];

    self.commentLabelHeightConstraint.constant = correctLabelSize.height;

    return self.commentLabel.frame.origin.y + self.commentLabelHeightConstraint.constant + cellPadding;
}

- (void)layoutSubviews{
    [self cellHeight];
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end
