//
//  SubscriptionTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/4/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "SubscriptionTableViewCell.h"

@implementation SubscriptionTableViewCell
@synthesize delegate;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

-(void)fillCellWithPackage:(Package *)obj{
    self.currentPackage = obj;
    
    self.titleLabel.text = obj.package_name;

    
    
    

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"id_ID"];
    [numberFormatter setLocale:locale];
    
    NSString *currency = [numberFormatter stringFromNumber:obj.package_price];
    self.priceLabel.text = [NSString stringWithFormat:@"%@,-",currency];
    
    self.buyButton.layer.cornerRadius = 2.0;
    self.buyButton.layer.masksToBounds = YES;
    self.buyButton.layer.borderColor = [HEXCOLOR(0xa3a3a3ff) CGColor];
    self.buyButton.layer.borderWidth = 1.0;
    
    
    NSAttributedString *as = [[[DTHTMLAttributedStringBuilder alloc]
                               initWithHTML:[obj.package_expired_at dataUsingEncoding:NSUnicodeStringEncoding]
                               options:@{
                                         DTDefaultFontSize: @(11),
                                         DTDefaultTextColor: HEXCOLOR(0x999999FF),
                                         DTDefaultFontFamily: InterfaceStr(@"default_font_regular"),
                                         }
                               documentAttributes:NULL] generatedAttributedString];
    self.expirationLabel.attributedString = as;
}

- (IBAction)buyButtonTapped:(id)sender {
    if([delegate respondsToSelector:@selector(buyPackage:)]){
        [delegate buyPackage:self.currentPackage];
    }
}
@end
