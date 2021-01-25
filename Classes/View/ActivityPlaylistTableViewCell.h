//
//  ActivityPlaylistTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmallVideoCollectionView.h"

@protocol ActivityPlaylistTableViewCellDelegate <NSObject>

-(void)didSelectClip:(Clip *)aClip;

@end

@interface ActivityPlaylistTableViewCell : UITableViewCell<UICollectionViewDelegate, UICollectionViewDataSource, SmallVideoCollectionViewDelegate>

@property(nonatomic, weak) id <ActivityPlaylistTableViewCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *playlistNameLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *clipCollectionView;
@property (strong, nonatomic) IBOutlet UILabel *playlistVideoCountLabel;
@property (nonatomic, retain) NSArray *clipsArray;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

+(NSString *)reuseIdentifier;
-(void)setItemWithPlayList:(Playlist *)pl;
@end
