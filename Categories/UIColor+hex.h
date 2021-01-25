//
//  UIColor+hex.h
//  SaudiOjra Passenger
//
//  Created by Jefry Da Gucci on 6/18/14.
//  Copyright (c) 2014 SaudiOjra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (hex)

+ (UIColor *)colorWithHex:(NSString *)hex;
#define COLOR_HEX(hex) ([UIColor colorWithHex:hex])

@end
