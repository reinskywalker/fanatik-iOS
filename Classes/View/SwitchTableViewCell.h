//
//  SwitchTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/29/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SwitchTableViewCell;
@protocol SwitchTableViewCellDelegate <NSObject>
-(void)switchTableViewCell:(SwitchTableViewCell *)cell switchValueDidChange:(UISwitch *)sender;
@optional

@end

@interface SwitchTableViewCell : UITableViewCell<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UISwitch *theSwitch;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *titleLabel;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *descLabel;
@property (nonatomic, weak) id <SwitchTableViewCellDelegate> delegate;
@property (nonatomic, copy) NSString *myID;

- (IBAction)switchChanged:(UISwitch *)sender;
+(NSString *)reuseIdentifier;
@end
