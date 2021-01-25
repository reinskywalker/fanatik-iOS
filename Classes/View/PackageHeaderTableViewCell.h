//
//  PackageHeaderTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PackageHeaderTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet CustomRegularLabel *packageNameLabel;
@property (strong, nonatomic) IBOutlet UIView *packageInfoContainerView;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *priceLabel;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *favoritLabel;


+(NSString *) reuseIdentifier;
-(void)fillWithPackage:(Package *)obj andIsFavorite:(BOOL)isFavorite;
@end
