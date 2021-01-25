//
//  CALayer+RuntimeAttribute.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 5/21/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "CALayer+RuntimeAttribute.h"

@implementation CALayer (RuntimeAttribute)

-(void)setBorderIBColor:(UIColor *)borderIBColor{
    self.borderColor = borderIBColor.CGColor;
}

-(UIColor *)borderIBColor{
    return [UIColor colorWithCGColor:self.borderColor];
}

-(void)setShadowIBColor:(UIColor *)shadowIBColor{
    self.shadowColor = shadowIBColor.CGColor;
}

-(UIColor *)shadowIBColor{
    return [UIColor colorWithCGColor:self.shadowColor];
}

@end
