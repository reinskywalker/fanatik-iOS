//
//  VideoCategoryLayout.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 5/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"

@protocol VideoCategoryLayoutDelegate <NSObject>

-(void)didSelectVideo:(Clip *)clip;


@end

@interface VideoCategoryLayout : ParentViewController
@property(nonatomic, retain) ClipGroup *currentClipGroup;
@property (strong, nonatomic) IBOutlet UIImageView *categoryBannerImageView;
@property (nonatomic, weak) id <VideoCategoryLayoutDelegate> delegate;
@property (nonatomic, assign) float layoutHeight;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *bannerHeight;

-(id)initWithClipGroup:(ClipGroup *)cGroup andLayoutId:(int)idx;
-(IBAction)tapVideoAtIndex:(id)sender;
-(float)getActualHeight;
@end
