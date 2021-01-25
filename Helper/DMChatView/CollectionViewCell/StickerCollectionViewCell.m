//
//  StickerCollectionViewCell.m
//  DMMoviePlayer
//
//  Created by Teguh Hidayatullah on 10/28/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "StickerCollectionViewCell.h"
#import "UIImageView+WebCache.h"
@implementation StickerCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)fillCellWithSticker:(Sticker *)sticker{
    
    self.stickerPriceLabel.text = @"Free";
    for(Pricing *pr in sticker.pricingArray){
        if([pr.type isEqualToString:@"VolumePricing"]){
            self.stickerPriceLabel.text = pr.price_str;
        }
    }
    [self.cellImageView sd_setImageWithURL:[NSURL URLWithString:sticker.file]];
}

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

@end
