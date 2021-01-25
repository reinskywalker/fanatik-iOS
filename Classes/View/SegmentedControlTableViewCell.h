//
//  SegmentedControlTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/29/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SegmentedControlTableViewCell;
@protocol SegmentedControlTableViewCellDelegate <NSObject>

@optional
-(void)segmentedControlTableViewCell:(SegmentedControlTableViewCell *)cell didChangeSegmentedControl:(id)sender;

@end

@interface SegmentedControlTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet CustomRegularLabel *myLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mySegmentedControl;
@property (nonatomic, weak) id <SegmentedControlTableViewCellDelegate> delegate;
@property (nonatomic, copy) NSString *myID;


- (IBAction)segmentChanged:(id)sender;
+(NSString *)reuseIdentifier;
@end
