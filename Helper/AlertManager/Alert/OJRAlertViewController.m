//
//  OJRAlertViewController.m
//  SaudiOjra Passenger
//
//  Created by Jefry Da Gucci on 9/30/14.
//  Copyright (c) 2014 SaudiOjra. All rights reserved.
//

#import "OJRAlertViewController.h"

@interface OJRAlertViewController ()

@end

@implementation OJRAlertViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.container.backgroundColor  =
        self.labelDetail.backgroundColor=
        self.labelTitle.backgroundColor =
        self.view.backgroundColor       = [UIColor clearColor];
        self.labelTitle.font    = FONT_BOLD(16);
        self.labelDetail.font   = FONT_REGULAR(14);
        self.container.layer.cornerRadius   = 3.0;
        self.view.userInteractionEnabled    = NO;
    }
    return self;
}

+ (OJRAlertViewController *)sharedInstance{
    static OJRAlertViewController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OJRAlertViewController alloc]initWithNibName:NSStringFromClass([OJRAlertViewController class]) bundle:nil];
    });
    return sharedInstance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showTextWithTitle:(NSString *)title detail:(NSString *)detail titleTextColor:(UIColor *)titleTexColor detailTexColor:(UIColor *)detailTextColor backgroundColor:(UIColor *)backgroundColor{
    
    self.labelTitle.text    = title;
    self.labelDetail.text   = detail;
    self.labelTitle.textColor   = titleTexColor;
    self.labelDetail.textColor  = detailTextColor;
    self.container.backgroundColor  = backgroundColor;
}

@end
