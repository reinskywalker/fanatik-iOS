//
//  AttributedLabelCustomHeader.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/2/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "AttributedLabelCustomHeader.h"

@implementation AttributedLabelCustomHeader
+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

-(void)fillWithFormattedString:(NSString *)str{
    self.attributedLabel.attributedString = [TheInterfaceManager processedHTMLString:str andFontSize:12];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGSize size = [self.attributedLabel sizeThatFits:self.attributedLabel.frame.size];
    self.attributedLabelHeightConstraint.constant = size.height;

}

@end
