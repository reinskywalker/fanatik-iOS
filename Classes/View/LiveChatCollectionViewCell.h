//
//  LiveChatCollectionViewCell.h
//  Fanatik
//
//  Created by Erick Martin on 11/16/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BroadcasterOfflineModel.h"

@interface LiveChatCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *broadcasterImageView;
@property (strong, nonatomic) IBOutlet UIView *liveIndicatorView;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *broadcasterNameLabel;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *viewersCountLabel;

-(void)setBroadcasterOnline:(BroadcasterOnline *)item;
-(void)setBroadcasterOffline:(BroadcasterOfflineModel *)item;
+(NSString *)reuseIdentifier;
@end
