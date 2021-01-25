//
//  CustomLabel.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/5/12.
//  Copyright (c) 2012 PT.  Domikado All rights reserved.
//

#import "CustomBoldLabel.h"
#import "InterfaceManager.h"

@implementation CustomBoldLabel

- (void)commonInit{
    CGFloat fontSize = self.font.pointSize;
    int lineNumber = (int)self.numberOfLines;
    
    [self setFont:[UIFont fontWithName:InterfaceStr(@"default_font_bold") size:fontSize]];
    
    if(lineNumber==1)
        [self setNumberOfLines:1];
    else
        [self setNumberOfLines:0];
    
//    [self setAdjustsFontSizeToFitWidth:lineNumber==1];
    
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
