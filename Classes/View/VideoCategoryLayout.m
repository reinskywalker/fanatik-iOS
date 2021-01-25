//
//  VideoCategoryLayout.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 5/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "VideoCategoryLayout.h"

@interface VideoCategoryLayout ()
@property (strong, nonatomic) IBOutlet CustomBoldLabel *layoutTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewContainer;
@property (nonatomic, assign) int layoutID;
@end

@implementation VideoCategoryLayout
@synthesize delegate, layoutID, bannerHeight,categoryBannerImageView;

-(id)initWithClipGroup:(ClipGroup *)cGroup andLayoutId:(int)idx{
    if(self = [super initWithNibName:[NSString stringWithFormat:@"%@%d",NSStringFromClass([self class]),idx]]){
        self.currentClipGroup = cGroup;
        self.layoutID = idx;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

-(void)viewWillAppear:(BOOL)animated{
    //don't call super
}

-(void)configureView{
    self.layoutTitleLabel.text = self.currentClipGroup.clip_group_name;

    NSArray *clipsArray = [self.currentClipGroup.clip_group_clips array];
    for (int i = 1; i < 7; i++) {
        Clip *theClip = [clipsArray objectAtIndex:i-1];
        UIView *videoContainerView = [self.view viewWithTag:i];
        UIButton *videoThumbnailButton = (UIButton *)[videoContainerView viewWithTag:10];
        [videoThumbnailButton addTarget:self action:@selector(tapVideoAtIndex:) forControlEvents:UIControlEventTouchUpInside];
        [[videoThumbnailButton imageView] setContentMode: UIViewContentModeScaleAspectFill];
        [videoThumbnailButton sd_setImageWithURL:[NSURL URLWithString:IS_IPAD?theClip.clip_video.video_thumbnail.thumbnail_720:theClip.clip_video.video_thumbnail.thumbnail_480] forState:UIControlStateNormal];
        
        UILabel *premiumLabel = (UILabel *)[videoContainerView viewWithTag:11];
        premiumLabel.hidden = ![theClip.clip_video.video_is_premium boolValue];
        premiumLabel.layer.borderColor = [[UIColor whiteColor] CGColor];
        premiumLabel.layer.borderWidth = 1.0;
        premiumLabel.layer.cornerRadius = 2.0;
        
        
        UILabel *durationLabel = (UILabel *)[videoContainerView viewWithTag:12];
        durationLabel.text = theClip.clip_video.video_duration;
        
        UIView *durationView = [videoContainerView viewWithTag:13];
        durationView.layer.cornerRadius = 2.0;
        durationView.layer.masksToBounds = YES;

    }
    
    if(!categoryBannerImageView){
        categoryBannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 66)];
        [categoryBannerImageView setImage:[UIImage imageNamed:@"bannerCategory_iPad"]];
        [categoryBannerImageView setContentMode:UIViewContentModeCenter];
        [self.view addSubview:categoryBannerImageView];
    }

//    [self.view setNeedsLayout];
//    [self.view layoutIfNeeded];
}

-(void)viewDidLayoutSubviews{
//    [self getActualHeight];
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

-(IBAction)tapVideoAtIndex:(id)sender{
    if([delegate respondsToSelector:@selector(didSelectVideo:)]){
        int idx = (int)[sender superview].tag-1;
        NSArray *clipsArray = [self.currentClipGroup.clip_group_clips array];
        [delegate didSelectVideo:clipsArray[idx]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
