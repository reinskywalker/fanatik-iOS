//
//  SwitchTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/29/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "SwitchTableViewCell.h"

@implementation SwitchTableViewCell

@synthesize delegate;

- (IBAction)switchChanged:(UISwitch *)sender {
    [delegate switchTableViewCell:self switchValueDidChange:sender];
}

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
