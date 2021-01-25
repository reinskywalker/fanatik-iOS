//
//  ThreadCommentTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ThreadCommentTableViewCell;
@protocol ThreadCommentTableViewCellDelegate <NSObject>

-(void)threadCommentTableViewCell:(ThreadCommentTableViewCell *)cell moreButtonDidTapForComment:(ThreadComment *)cmn;

@end

@interface ThreadCommentTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *userNameLabel;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *commentLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet UILabel *commentDateLabel;
@property (nonatomic, weak) id <ThreadCommentTableViewCellDelegate> delegate;
@property (nonatomic, retain) ThreadComment *currentComment;

- (IBAction)moreButtonTapped:(id)sender;



+(NSString *)reuseIdentifier;
-(CGFloat)cellHeight;
-(void)fillCellWithComment:(ThreadComment *)aComment;


@end
