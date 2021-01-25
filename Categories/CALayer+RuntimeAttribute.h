//
//  CALayer+RuntimeAttribute.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 5/21/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (RuntimeAttribute)

@property(nonatomic, assign) UIColor *borderIBColor;
@property(nonatomic, assign) UIColor *shadowIBColor;

@end
