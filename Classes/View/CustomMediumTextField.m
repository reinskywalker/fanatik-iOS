//
//  CustomLabel.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/5/12.
//  Copyright (c) Fanatik. All rights reserved.
//

#import "CustomMediumTextField.h"
#import "InterfaceManager.h"

@implementation CustomMediumTextField

- (void)commonInit{
    CGFloat fontSize = self.font.pointSize;
    
    [self setFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:fontSize]];
    
    if ([self respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = HEXCOLOR(0x999999FF);
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder?self.placeholder : @"" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
}

-(void)setPlaceholder:(NSString *)placeholder{
    if ([self respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = HEXCOLOR(0x999999FF);
        if(placeholder && ![placeholder isEqualToString:@""])
            self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }

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



@end
