
//
//  SearchClipTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/11/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserUploads.h"

@class UploadClipTableViewCell;

@protocol UploadClipTableViewCellDelegate <NSObject>

-(void)moreButtonDidTapForUserUpload:(UserUploads *)uu;

@end

@interface UploadClipTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *moreButtonForCell;
@property(nonatomic, weak) id <UploadClipTableViewCellDelegate> delegate;
@property (nonatomic, retain) UserUploads *currentUserUploads;
@property (strong, nonatomic) IBOutlet UIImageView *videoImageView;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *videoTitleLabel;
@property (strong, nonatomic) IBOutlet DTAttributedLabel *statusUploadLabel;

- (IBAction)moreButtonTapped:(id)sender;
-(void)fillWithUserUploads:(UserUploads *)uu andUserUploadModel:(UserUploadsModel *)uum;
+(NSString *)reuseIdentifier;
@end
