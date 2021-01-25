//
//  EmptyLabelTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/26/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomRegularLabel.h"

@interface EmptyLabelTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet CustomRegularLabel *emptyLabel;

+(NSString *)reuseIdentifier;
@end
