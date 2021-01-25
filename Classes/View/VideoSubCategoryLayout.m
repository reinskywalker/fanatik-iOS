//
//  VideoSubCategoryLayout.m
//  Fanatik
//
//  Created by Erick Martin on 5/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "VideoSubCategoryLayout.h"


@implementation VideoSubCategoryLayout

@synthesize currentClipGroup, titleGroupLabel, clipTitleLabel, delegate, layoutID, layoutHeight;

-(id)initWithClipGroup:(ClipGroup *)cGroup andLayoutId:(int)idx{
    if(self = [super initWithNibName:[NSString stringWithFormat:@"%@%d",NSStringFromClass([self class]),idx]]){
        self.currentClipGroup = cGroup;
        self.layoutID = idx;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self configureView];

}

-(void)viewWillAppear:(BOOL)animated{
    //dont call super
    
}

-(void)configureView{
    titleGroupLabel.text = currentClipGroup.clip_group_name;
    
    NSArray *clipArray = [self.currentClipGroup.clip_group_clips array];
    
    if(clipArray.count > 0){
        Clip *clip = clipArray[0];
        clipTitleLabel.text = clip.clip_content;
        
        for(int i = 1; i<=6 ; i++){
            Clip *clip = [clipArray objectAtIndex:i-1];
            
            UIView *theView = [self.view viewWithTag:i];
            UIButton *clipButton = (UIButton *)[theView viewWithTag:10];
            [clipButton addTarget:self action:@selector(tapVideoAtIndex:) forControlEvents:UIControlEventTouchUpInside];
            
            [[clipButton imageView] setContentMode: UIViewContentModeScaleAspectFill];
            [clipButton sd_setImageWithURL:[NSURL URLWithString:IS_IPAD?clip.clip_video.video_thumbnail.thumbnail_720:clip.clip_video.video_thumbnail.thumbnail_480] forState:UIControlStateNormal];
            
            UILabel *premiumLabel = (UILabel *)[theView viewWithTag:11];
            premiumLabel.hidden = ![clip.clip_video.video_is_premium boolValue];
            premiumLabel.layer.borderWidth = 1.0;
            premiumLabel.layer.borderColor = [UIColor whiteColor].CGColor;
            premiumLabel.layer.cornerRadius = 2.0;
            
            UILabel *durationLabel = (UILabel *)[theView viewWithTag:12];
            durationLabel.text = clip.clip_video.video_duration;

        }
    }
}

-(void)viewDidLayoutSubviews{
    UIView *videoContainerView = [self.view viewWithTag:6];
    float lowestYPoint = videoContainerView.frame.origin.y + videoContainerView.frame.size.height;
    CGRect destRect = self.view.frame;
    destRect.size.height = lowestYPoint + 30;
    self.view.frame = destRect;
}

-(IBAction)tapVideoAtIndex:(id)sender{
    if([delegate respondsToSelector:@selector(didSelectVideo:)]){
        int idx = (int)[sender superview].tag - 1;
        NSArray *clipArray = [self.currentClipGroup.clip_group_clips array];
        Clip *clip = clipArray[idx];
        [delegate didSelectVideo:clip];
    }
}

-(float)getActualHeight{
    [self.view layoutIfNeeded];
    UIView *videoContainerView = [self.view viewWithTag:6];
    float lowestYPoint = videoContainerView.frame.origin.y + videoContainerView.frame.size.height;
    CGRect destRect = self.view.frame;
    destRect.size.height = lowestYPoint + 25;
    self.view.frame = destRect;
    self.layoutHeight = destRect.size.height;
    return self.layoutHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
