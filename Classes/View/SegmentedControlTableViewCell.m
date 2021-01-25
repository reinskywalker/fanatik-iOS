//
//  SegmentedControlTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/29/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "SegmentedControlTableViewCell.h"

@implementation SegmentedControlTableViewCell
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

- (IBAction)segmentChanged:(id)sender {
    if([delegate respondsToSelector:@selector(segmentedControlTableViewCell:didChangeSegmentedControl:)]){
        [delegate segmentedControlTableViewCell:self didChangeSegmentedControl:sender];
    }
}
@end
