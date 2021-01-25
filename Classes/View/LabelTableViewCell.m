//
//  LabelTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/29/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "LabelTableViewCell.h"

@implementation LabelTableViewCell
@synthesize delegate;

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

- (IBAction)buttonTapped:(id)sender {
    if([delegate respondsToSelector:@selector(labelTableViewCell:buttonDidTap:)]){
        [delegate labelTableViewCell:self buttonDidTap:sender];
    }
}
@end
