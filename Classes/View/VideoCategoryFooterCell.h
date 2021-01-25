//
//  VideoCategoryFooterCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 5/20/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VideoCategoryFooterCellDelegate <NSObject>

-(void)didTapMoreVideosButton:(id)obj;

@end

@interface VideoCategoryFooterCell : UITableViewCell

+(NSString *)reuseIdentifier;
- (IBAction)moreVideosButtonTapped:(id)sender;

@property(nonatomic, weak) id <VideoCategoryFooterCellDelegate> delegate;
@property(nonatomic, retain) ClipGroup *currentClipGroup;
@property(nonatomic, retain) Contest *currentContest;
@end
