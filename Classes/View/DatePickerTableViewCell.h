//
//  DatePickerTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/29/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DatePickerTableViewCell;



@interface DatePickerTableViewCell : UITableViewCell
@property (nonatomic, copy) NSString *myID;
@property (nonatomic, assign) BOOL isExpanded;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *datePickerHeighConstraint;
@property (strong, nonatomic) IBOutlet UIView *datePickerContainer;
+(CGFloat)pickerHeightExpanded;


+(NSString *)reuseIdentifier;
@end
