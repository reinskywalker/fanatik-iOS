//
//  VideoCategoryPickerCell.h
//  Fanatik
//
//  Created by Erick Martin on 5/20/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCategoryPickerCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *categoryNameLabel;

+(NSString *)reuseIdentifier;
-(void)setItem:(ClipCategory *)cat;
-(void)setCategoryNameStr:(NSString *)name;
@end
