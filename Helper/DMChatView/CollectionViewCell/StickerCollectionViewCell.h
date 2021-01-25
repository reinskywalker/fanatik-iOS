//
//  StickerCollectionViewCell.h
//  DMMoviePlayer
//
//  Created by Teguh Hidayatullah on 10/28/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sticker.h"

@interface StickerCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UILabel *stickerPriceLabel;

-(void)fillCellWithSticker:(Sticker *)sticker;
+(NSString *)reuseIdentifier;

@end
