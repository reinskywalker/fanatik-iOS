//
//  CheckoutViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"

@interface CheckoutViewController : ParentViewController
- (IBAction)nextButtonTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic, assign) BOOL shouldPresent;
@property (nonatomic, assign) BOOL didPresent;
@property (strong, nonatomic) IBOutlet CustomMediumButton *leftButton;
-(id)initWithPackage:(Package *)package;
@end
