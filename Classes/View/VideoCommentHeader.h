//
//  VideoCommentHeader.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/30/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VideoCommentHeader;
@protocol VideoCommentHeaderDelegate <NSObject>
-(void)addComment:(NSString *)content;
@end

@interface VideoCommentHeader : UITableViewHeaderFooterView <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet DTAttributedLabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;

@property (weak,nonatomic) id <VideoCommentHeaderDelegate> delegate;

- (void) fillWithLive:(Live *)obj;
- (void) fillWithClip:(Clip*)obj;

-(IBAction)sendButtonTapped:(id)sender;
@end
