//
//  UIView+indicator.h
//  Valo
//
//  Created by Jefry Da Gucci on 9/16/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseIndicatorView.h"

@interface UIView (indicator)

@property (strong, nonatomic) BaseIndicatorView *indicator;
@property (strong, nonatomic) UIActivityIndicatorView *defaultIndicator;

#pragma mark - loader
- (void)initLoader;

- (void)startLoader:(BOOL)isStart
          disableUI:(BOOL)disabelUI;

- (void)centerIndicator;

- (void)startDefaultLoader:(BOOL)isStart
                 disableUI:(BOOL)disabelUI;

@end
