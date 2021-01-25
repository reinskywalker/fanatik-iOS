//
//  HomeViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/31/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "ParentViewController.h"

@interface HomeViewController : ParentViewController<UITextFieldDelegate>


@property(nonatomic,retain) IBOutlet CustomMediumButton *actionButton;
@property(nonatomic,retain) IBOutlet UIImageView *imgView;
@property(nonatomic, assign) BOOL isPresented;

- (IBAction)actionButtonTapped:(id)sender;
- (IBAction)leftButtonTapped:(id)sender;
- (IBAction)rightButtonTapped:(id)sender;
- (IBAction)skipButtonTapped:(id)sender;

- (IBAction)fbLoginTapped:(id)sender;

- (IBAction)textButtonTapped:(id)sender;
-(instancetype)initByPresenting;

@end
