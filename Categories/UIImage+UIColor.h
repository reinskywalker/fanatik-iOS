//
//  UIImage+UIColor.h
//  SaudiOjra Passenger
//
//  Created by Jefry Da Gucci on 9/9/14.
//  Copyright (c) 2014 SaudiOjra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIColor)

#define IMAGE_COLOR(imageColor) ([UIImage imageWithColor:(imageColor)])
+ (UIImage *)imageWithColor:(UIColor *)color;

- (UIImage *)tintImageWithColor:(UIColor*)color;

- (UIImage *)tintImageBlack;

- (UIImage *)tintImageWhite;

@end
