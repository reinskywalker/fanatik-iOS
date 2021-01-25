//
//  VideoCommentHeader.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/30/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "VideoCommentHeader.h"

@interface VideoCommentHeader ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightCommentCountLabel;

@end

@implementation VideoCommentHeader

@synthesize delegate, commentTextField;

- (void)awakeFromNib {
    // Initialization code
}


- (void) fillWithLive:(Live *)obj{
    NSURL *avatarURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [User fetchLoginUser].user_avatar.avatar_thumbnail]];
    
    [self.userImageView sd_setImageWithURL:avatarURL];
    
    
    
    
    NSString *htmlString = [NSString stringWithFormat:@"<br><b>%d</b> Komentar",[obj.live_clip_stat.clip_stats_comments intValue]];
    
    
    
    NSAttributedString *as = [[[DTHTMLAttributedStringBuilder alloc]
                               initWithHTML:[htmlString dataUsingEncoding:NSUnicodeStringEncoding]
                               options:@{
                                         DTDefaultFontSize: @(12),
                                         DTDefaultFontFamily: InterfaceStr(@"default_font_regular"),
                                         }
                               documentAttributes:NULL] generatedAttributedString];
    
    
    self.commentCountLabel.attributedString = as;
    self.commentCountLabel.numberOfLines = 1;
    [self layoutIfNeeded];
}

- (void) fillWithClip:(Clip *)obj{
    
    
    NSURL *avatarURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [User fetchLoginUser].user_avatar.avatar_thumbnail]];
    
    [self.userImageView sd_setImageWithURL:avatarURL];
    
    
   
    
    NSString *htmlString = [NSString stringWithFormat:@"<br><b>%d</b> Komentar",[obj.clip_stats.clip_stats_comments intValue]];
    
    
    
    NSAttributedString *as = [[[DTHTMLAttributedStringBuilder alloc]
                               initWithHTML:[htmlString dataUsingEncoding:NSUnicodeStringEncoding]
                               options:@{
                                         DTDefaultFontSize: @(12),
                                         DTDefaultFontFamily: InterfaceStr(@"default_font_regular"),
                                         }
                               documentAttributes:NULL] generatedAttributedString];
    
    
    self.commentCountLabel.attributedString = as;
    self.commentCountLabel.numberOfLines = 1;
    [self layoutIfNeeded];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [delegate addComment:textField.text];
    
    textField.text = @"";
    return YES;
}


-(IBAction)sendButtonTapped:(id)sender{
    [commentTextField resignFirstResponder];
    [delegate addComment:commentTextField.text];
    commentTextField.text = @"";
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.userImageView.layer.cornerRadius = CGRectGetWidth(self.userImageView.frame)/2;
    self.userImageView.layer.masksToBounds = YES;
    
    CGSize size = [self.commentCountLabel sizeThatFits:self.commentCountLabel.frame.size];
    self.constraintHeightCommentCountLabel.constant = size.height;

}

@end
