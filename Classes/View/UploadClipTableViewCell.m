//
//  SearchClipTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/11/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "UploadClipTableViewCell.h"

@implementation UploadClipTableViewCell

@synthesize delegate, currentUserUploads;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

-(void)fillWithUserUploads:(UserUploads *)uu andUserUploadModel:(UserUploadsModel *)uum{
    self.currentUserUploads = uu;
    self.videoImageView.image = nil;
    [self.videoImageView sd_setImageWithURL:[NSURL URLWithString:currentUserUploads.user_uploads_video_thumbnail]];
    self.videoTitleLabel.text = @"";
    self.videoTitleLabel.text = currentUserUploads.user_uploads_title;
    
    NSString *statusString = @"";

    if(uum.user_uploads_status == UserUploadStatusSuccess || [currentUserUploads.user_uploads_video_uploaded boolValue]){
        statusString = @"";
    }else if(uum.user_uploads_status == UseruploadStatusOnProgress){
        statusString = @"Uploading . . .";
    }else if(uum.user_uploads_status == UserUploadStatusIncomplete){
        statusString = @"Incomplete";
    }

    self.statusUploadLabel.attributedString = [TheInterfaceManager processedHTMLString:statusString andFontSize:12];
    self.statusUploadLabel.alpha = 0.3;
}

- (IBAction)moreButtonTapped:(id)sender {
    [delegate moreButtonDidTapForUserUpload:self.currentUserUploads];
}

@end
