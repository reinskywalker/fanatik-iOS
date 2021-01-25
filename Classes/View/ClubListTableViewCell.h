//
//  ClubListTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/11/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ClubListTableViewCell;
@protocol ClubListTableViewCellDelegate <NSObject>
-(void)clubListTableViewCell:(ClubListTableViewCell *)cell joinClub:(Club *)obj;
-(void)clubListTableViewCell:(ClubListTableViewCell *)cell leaveClub:(Club *)obj;

@end

@interface ClubListTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *clubImageView;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *clubNameLabel;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *clubStatsLabel;
@property (strong, nonatomic) IBOutlet UIButton *joinButton;
@property (nonatomic, retain) Club *currentClub;
@property (nonatomic, assign) BOOL isJoinButton;

@property (nonatomic, weak) id <ClubListTableViewCellDelegate> delegate;

+(NSString *)reuseIdentifier;
- (IBAction)joinClubTapped:(id)sender;
-(void)fillWithClub:(Club *)theObj;

@end
