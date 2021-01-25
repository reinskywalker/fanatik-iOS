//
//  ProfileCustomHeader.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/30/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileCustomHeaderDelegate <NSObject>

-(void)didSelectButtonAtIndex:(int)idx;

@end

@interface ProfileCustomHeader : UITableViewHeaderFooterView


@property (weak,nonatomic) id <ProfileCustomHeaderDelegate> delegate;
@property(nonatomic, assign) ProfileMode selectedIndex;

@property (strong, nonatomic) IBOutlet CustomBoldButton *videoButton;
@property (strong, nonatomic) IBOutlet CustomBoldButton *playlistButton;
@property (strong, nonatomic) IBOutlet CustomBoldButton *activityButton;
@property (strong, nonatomic) IBOutlet CustomBoldButton *videoButton2;
@property (strong, nonatomic) IBOutlet CustomBoldButton *playlistButton2;
@property (strong, nonatomic) IBOutlet CustomBoldButton *activityButton2;
@property (strong, nonatomic) IBOutlet CustomBoldButton *moderasiButton;

@property (strong, nonatomic) IBOutlet UIView *fourTabsView;
@property (strong, nonatomic) IBOutlet UIView *threeTabsView;

- (void)setupCellForModerate:(BOOL)moderate;
- (IBAction)videoButtonTapped:(id)sender;
- (IBAction)playlistButtonTapped:(id)sender;
- (IBAction)activityButtonTapped:(id)sender;
- (IBAction)moderasiButtonTapped:(id)sender;

+(NSString *)reuseIdentifier;

@end
