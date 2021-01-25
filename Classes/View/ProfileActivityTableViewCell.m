//
//  ProfileActivityTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/29/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ProfileActivityTableViewCell.h"
#import <OHAttributedLabel/OHASBasicHTMLParser.h>

@interface ProfileActivityTableViewCell()

@property (strong, nonatomic) IBOutlet UILabel *activityAttributedLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *activityLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *timeAgoLabel;

@end

@implementation ProfileActivityTableViewCell

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)fillWithActivity:(Activity *)obj{
    self.timeAgoLabel.text = obj.activity_time_ago;
    
    self.activityAttributedLabel.attributedText  = [OHASBasicHTMLParser attributedStringByProcessingMarkupInAttributedString:[TheInterfaceManager processedOHHTMLString:obj.activity_description andFontSize:12.0]];
    self.activityAttributedLabel.numberOfLines = 2;
    [self layoutSubviews];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGSize size = [self.activityAttributedLabel sizeThatFits:self.activityAttributedLabel.frame.size];
    self.activityLabelHeightConstraint.constant = size.height;
}

- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

@end
