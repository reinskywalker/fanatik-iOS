//
//  SubscriptionTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/4/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SubscriptionTableViewCellDelegate <NSObject>

-(void)buyPackage:(Package *)obj;

@end

@interface SubscriptionTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet CustomRegularLabel *titleLabel;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *priceLabel;
@property (strong, nonatomic) IBOutlet CustomMediumButton *buyButton;
@property (nonatomic, retain) Package *currentPackage;
@property (nonatomic, weak) id <SubscriptionTableViewCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet DTAttributedLabel *expirationLabel;

- (void)fillCellWithPackage:(Package *)obj;
- (IBAction)buyButtonTapped:(id)sender;
+(NSString *)reuseIdentifier;

@end
