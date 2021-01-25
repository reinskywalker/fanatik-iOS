//
//  VideoCommentTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "VideoCommentHeaderCell.h"

@implementation VideoCommentHeaderCell

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)fillWithLive:(Live *)obj{
    
    NSString *htmlString = [NSString stringWithFormat:@"Comment%@ (%d)", [obj.live_clip_stat.clip_stats_comments intValue]>1?@"s":@"", [obj.live_clip_stat.clip_stats_comments intValue]];
    
    NSAttributedString *as = [[[DTHTMLAttributedStringBuilder alloc]
                               initWithHTML:[htmlString dataUsingEncoding:NSUnicodeStringEncoding]
                               options:@{
                                         DTDefaultFontSize: @(12),
                                         DTDefaultFontFamily: InterfaceStr(@"default_font_regular"),
                                         }
                               documentAttributes:NULL] generatedAttributedString];
    
    
    self.commentCountLabel.attributedString = as;
    self.commentCountLabel.numberOfLines = 1;
}

- (void) fillWithClip:(Clip *)obj{
    
    NSString *htmlString = [NSString stringWithFormat:@"Comment%@ (%d)", [obj.clip_stats.clip_stats_comments intValue]>1?@"s":@"", [obj.clip_stats.clip_stats_comments intValue]];
    NSAttributedString *as = [[[DTHTMLAttributedStringBuilder alloc]
                               initWithHTML:[htmlString dataUsingEncoding:NSUnicodeStringEncoding]
                               options:@{
                                         DTDefaultFontSize: @(12),
                                         DTDefaultFontFamily: InterfaceStr(@"default_font_regular"),
                                         }
                               documentAttributes:NULL] generatedAttributedString];
    
    
    self.commentCountLabel.attributedString = as;
    self.commentCountLabel.numberOfLines = 1;
}

@end
