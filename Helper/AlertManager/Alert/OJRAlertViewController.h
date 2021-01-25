//
//  OJRAlertViewController.h
//  SaudiOjra Passenger
//
//  Created by Jefry Da Gucci on 9/30/14.
//  Copyright (c) 2014 SaudiOjra. All rights reserved.
//

#import "ParentViewController.h"

@interface OJRAlertViewController : ParentViewController
@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelDetail;

+ (OJRAlertViewController *)sharedInstance;

- (void)showTextWithTitle:(NSString *)title detail:(NSString *)detail titleTextColor:(UIColor *)titleTexColor detailTexColor:(UIColor *)detailTextColor backgroundColor:(UIColor *)backgroundColor;

@end
