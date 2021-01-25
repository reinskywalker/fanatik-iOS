//
//  ContestInfoTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    VisibilityModeUpload = 0,
    VisibilityModeContestant = 1
}VisibilityMode;

@protocol ContestInfoTableViewCellDelegate <NSObject>

-(void)showingErrorFromServer:(NSString *)errorStr;
-(void)didSelectVisibilityMode:(VisibilityMode)visMod;

@end

@interface ContestInfoTableViewCell : UITableViewCell <SwipeViewDataSource, SwipeViewDelegate>

@property (strong, nonatomic) IBOutlet CustomBoldLabel *titleLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstraint;
@property (strong, nonatomic) IBOutlet CustomSemiBoldLabel *dateLabel;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *descLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *descHeightConstraint;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *statusLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusWidthConstraint;
@property (nonatomic, retain) IBOutlet SwipeView *headerMenu;

@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, weak) id <ContestInfoTableViewCellDelegate> delegate;
@property (nonatomic, retain) Contest *currentContest;
@property (strong, nonatomic) IBOutlet UIImageView *downArrow;
@property (nonatomic, assign) VisibilityMode currentVisibility;

+(NSString *)reuseIdentifier;
-(CGFloat)cellHeight;
-(void)fillCellWithContest:(Contest *)aContest;

@end
