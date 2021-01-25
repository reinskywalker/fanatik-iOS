//
//  VideoSubCategoryLayout.h
//  Fanatik
//
//  Created by Erick Martin on 5/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "ClipGroup.h"

@protocol VideoSubCategoryLayoutDelegate <NSObject>

-(void)didSelectVideo:(Clip *)clip;

@end

@interface VideoSubCategoryLayout : ParentViewController

@property (nonatomic, retain) ClipGroup *currentClipGroup;
@property (nonatomic, retain) IBOutlet UILabel *titleGroupLabel;
@property (weak, nonatomic) IBOutlet CustomSemiBoldLabel *clipTitleLabel;
@property (nonatomic, weak) id <VideoSubCategoryLayoutDelegate> delegate;
@property (nonatomic, assign) int layoutID;
@property (nonatomic, assign) float layoutHeight;

-(id)initWithClipGroup:(ClipGroup *)cGroup andLayoutId:(int)idx;
-(float)getActualHeight;
-(void)configureView;

@end
