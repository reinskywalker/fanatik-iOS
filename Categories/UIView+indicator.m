//
//  UIView+indicator.m
//  Valo
//
//  Created by Jefry Da Gucci on 9/16/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

NSString *const indicatorKey = @"indicatorKey";
NSString *const defaultIndicatorKey = @"defaultIndicatorKey";

#import "UIView+indicator.h"

@implementation UIView (indicator)
@dynamic indicator;
@dynamic defaultIndicator;


#pragma mark - loader
- (void)initLoader{
    if(self.indicator != nil){
        return;
    }
    CGRect frameView = self.frame;
    self.indicator = [[BaseIndicatorView alloc] initWithFrame:frameView];
    [self addSubview:self.indicator];
    
    if(SYSTEM_VERSION_LESS_THAN(@"8.0")){
        self.indicator.translatesAutoresizingMaskIntoConstraints = YES;
    }else{
        self.indicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self.indicator sdc_pinSize:CGSizeMake(60, 60)];
        [self.indicator sdc_verticallyCenterInSuperview];
        [self.indicator sdc_horizontallyCenterInSuperview];
    }
    
    
    self.defaultIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:self.defaultIndicator];
    
    [self centerDefaultIndicator];
}

- (void)startLoader:(BOOL)isStart
          disableUI:(BOOL)disabelUI{
    if (self.indicator == nil) {
        [self initLoader];
    }
    [self centerIndicator];
    [self.indicator startLoader:isStart disableUI:disabelUI];
}

- (void)centerIndicator{
    [self.indicator centerToSuperView];
}

- (void)centerDefaultIndicator{
    CGRect frameSuperview = self.defaultIndicator.superview.frame;
    self.defaultIndicator.center = CGPointMake(frameSuperview.size.width/2, frameSuperview.size.height/2);
}

- (void)setIndicator:(BaseIndicatorView *)indicator{
    objc_setAssociatedObject(self, (__bridge const void*)(indicatorKey), indicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BaseIndicatorView *)indicator{
    BaseIndicatorView *indicatorView = objc_getAssociatedObject(self, (__bridge const void*)indicatorKey);
    return indicatorView;
}

- (UIActivityIndicatorView *)defaultIndicator{
    UIActivityIndicatorView *defaultIndicator = objc_getAssociatedObject(self, (__bridge const void*)defaultIndicatorKey);
    return defaultIndicator;
}

- (void)setDefaultIndicator:(UIActivityIndicatorView *)defaultIndicator{
    objc_setAssociatedObject(self, (__bridge const void*)(defaultIndicatorKey), defaultIndicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - indicator
- (void)startDefaultLoader:(BOOL)isStart
                 disableUI:(BOOL)disabelUI{
    
    if(isStart){
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{\
            dispatch_async(dispatch_get_main_queue(), ^{
                self.hidden = NO;
                if(self.superview!=nil){
                    [self.superview bringSubviewToFront:self];
                }
                [self.defaultIndicator startAnimating];
            });
        });
    }
    else{
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{\
            dispatch_async(dispatch_get_main_queue(), ^{
                self.hidden = YES;
                [self.defaultIndicator stopAnimating];
            });
        });
    }
    
    if(disabelUI &&
       ![[UIApplication sharedApplication] isIgnoringInteractionEvents]){
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }
    else{
        if(!disabelUI &&
           [[UIApplication sharedApplication] isIgnoringInteractionEvents]){
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
    }
    
    self.defaultIndicator.hidden = !isStart;
}

@end
