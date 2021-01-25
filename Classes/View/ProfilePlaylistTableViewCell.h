//
//  ProfilePlaylistTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmallVideoCollectionView.h"

@protocol ProfilePlaylistTableViewCellDelegate <NSObject>

-(void)didSelectClip:(Clip *)aClip;

@end

@interface ProfilePlaylistTableViewCell : UITableViewCell<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, weak) id <ProfilePlaylistTableViewCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *playlistNameLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *clipCollectionView;
@property (strong, nonatomic) IBOutlet UILabel *playlistVideoCountLabel;
@property (nonatomic, retain) NSArray *clipsArray;

+(NSString *)reuseIdentifier;
-(void)setItemWithPlayList:(Playlist *)pl;
@end
