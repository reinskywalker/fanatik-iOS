//
//  UploadVideoDetailViewController.h
//  Fanatik
//
//  Created by Erick Martin on 6/30/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UserUploads.h"

@interface UploadVideoDetailViewController : ParentViewController

@property (nonatomic, strong) MPMoviePlayerController* moviePlayer;
@property (nonatomic, retain) UserUploads *userUploadOnDetail;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *descLabel;
@property (strong, nonatomic) IBOutlet UIImageView *videoThumbnailImageView;
@property (nonatomic, retain) IBOutlet UIView *videoContainerView;
@property (nonatomic, retain) IBOutlet UIView *videoDetailContainerView;
@property (strong, nonatomic) IBOutlet UIButton *btnPlay;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *videoPlayerTopConstraint;

- (IBAction)btnPlayTapped:(id)sender;

-(id)initWithUserUploads:(UserUploads *)uu;

@end
