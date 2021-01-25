//
//  LiveChatCollectionViewCell.m
//  Fanatik
//
//  Created by Erick Martin on 11/16/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "LiveChatCollectionViewCell.h"

@implementation LiveChatCollectionViewCell

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

-(void)setBroadcasterOnline:(BroadcasterOnline *)item{
    [self.broadcasterImageView sd_setImageWithURL:[NSURL URLWithString:item.broadon_banner_url]];
    self.liveIndicatorView.hidden = NO;
    self.broadcasterNameLabel.text = item.broadon_title;
}

-(void)setBroadcasterOffline:(BroadcasterOfflineModel *)item{
    [self.broadcasterImageView sd_setImageWithURL:[NSURL URLWithString:item.broadcasterThumbnail]];
    self.liveIndicatorView.hidden = YES;
    self.broadcasterNameLabel.text = item.broadcasterName;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

@end
