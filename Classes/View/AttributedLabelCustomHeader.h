//
//  AttributedLabelCustomHeader.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/2/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttributedLabelCustomHeader : UITableViewHeaderFooterView
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *attributedLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet DTAttributedLabel *attributedLabel;

-(void)fillWithFormattedString:(NSString *)str;
+(NSString *)reuseIdentifier;
@end
