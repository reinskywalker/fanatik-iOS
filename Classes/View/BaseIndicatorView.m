//
//  BaseIndicatorView.m
//  Valo
//
//  Created by Jefry Da Gucci on 8/22/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "BaseIndicatorView.h"

@implementation BaseIndicatorView

#pragma mark - instance
- (id)init{
    if(self = [super init]){
        self.userInteractionEnabled = NO;
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.color = [TheInterfaceManager backgroundBlackColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.userInteractionEnabled = NO;
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            self.color = [TheInterfaceManager backgroundBlackColor];
    }
    return self;
}

+ (BaseIndicatorView *)sharedInstance{
    static BaseIndicatorView *sharedInstance;
    @synchronized(self)
    {
        if (!sharedInstance){
            if([sharedInstance isKindOfClass:[UIActivityIndicatorView class]]){
                sharedInstance = [[BaseIndicatorView alloc] init];
                [sharedInstance setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
            }
            else{
                sharedInstance = [[BaseIndicatorView alloc] init];
            }
            sharedInstance.hidden = YES;
            sharedInstance.userInteractionEnabled = NO;
        }
        return sharedInstance;
    }
}

- (void)startLoader:(BOOL)isStart
          disableUI:(BOOL)disabelUI{
    
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:isStart];
    
    if(isStart){
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{\
            dispatch_async(dispatch_get_main_queue(), ^{
                self.hidden = NO;
                if(self.superview!=nil){
                    [self.superview bringSubviewToFront:self];
                }
                [self startAnimating];
            });
        });
    }
    else{
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{\
            dispatch_async(dispatch_get_main_queue(), ^{
                self.hidden = YES;
                [self stopAnimating];
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
    
    self.hidden = !isStart;
}

- (void)centerToSuperView{
    CGRect frameSuperview = self.superview.frame;
    self.center = CGPointMake(frameSuperview.size.width/2, frameSuperview.size.height/2);
}

@end
