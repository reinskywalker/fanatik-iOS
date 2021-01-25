//
//  CustomLabel.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/5/12.
//  Copyright (c) 2012 PT.  Domikado All rights reserved.
//
#import "CustomSemiBoldButton.h"
#import "InterfaceManager.h"

@implementation CustomSemiBoldButton

- (void)commonInit{
    CGFloat fontSize = self.titleLabel.font.pointSize;
    
    [self.titleLabel setFont:[UIFont fontWithName:InterfaceStr(@"default_font_semi_bold") size:fontSize]];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
