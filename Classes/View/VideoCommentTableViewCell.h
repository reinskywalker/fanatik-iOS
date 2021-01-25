//
//  VideoCommentTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCommentTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *userNameLabel;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *commentLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet UILabel *commentDateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *stickerImageView;
@property (strong, nonatomic) Comment *currentComment;

+(NSString *)reuseIdentifier;
-(CGFloat)cellHeight;
-(void)fillCellWithComment:(Comment *)aComment;


@end
