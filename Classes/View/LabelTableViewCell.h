//
//  LabelTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/29/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

@class LabelTableViewCell;
@protocol LabelTableViewCellDelegate <NSObject>
@optional
-(void)labelTableViewCell:(LabelTableViewCell *)cell buttonDidTap:(id)sender;

@end

#import <UIKit/UIKit.h>

@interface LabelTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet CustomRegularLabel *myLabel;
@property (nonatomic, weak) id <LabelTableViewCellDelegate> delegate;
@property (nonatomic, copy) NSString *myID;
- (IBAction)buttonTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *arrowImageView;

+(NSString *)reuseIdentifier;
@end
