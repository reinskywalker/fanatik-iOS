//
//  BaseIndicatorView.h
//  Valo
//
//  Created by Jefry Da Gucci on 8/22/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "DSXActivityIndicator.h"

@interface BaseIndicatorView : UIActivityIndicatorView

#pragma mark - instance
+ (BaseIndicatorView *)sharedInstance;

- (void)startLoader:(BOOL)isStart
          disableUI:(BOOL)disabelUI;

- (void)centerToSuperView;

@end
