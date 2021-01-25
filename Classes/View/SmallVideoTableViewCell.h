//
//  SmallVideoTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/12/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmallVideoCollectionView.h"

@protocol SmallVideoTableViewCellDelegate <NSObject>

-(void)didSelectClip:(Clip *)aClip;
-(void)didTapMoreVideoButton:(NSInteger)index;
-(void)didSelectFeaturedUser:(User *)usr;

@end

@interface SmallVideoTableViewCell : UITableViewCell<UICollectionViewDelegate, UICollectionViewDataSource, SmallVideoCollectionViewDelegate>

@property(nonatomic, weak) id <SmallVideoTableViewCellDelegate> delegate;

@property(nonatomic, retain) IBOutlet UICollectionView *clipCollectionView;
@property(nonatomic, retain) ClipGroup *currentClipGroup;
@property(nonatomic, retain) NSArray *clipsArray;
@property(nonatomic, assign) NSInteger currentIndexSection;
@property(nonatomic, retain) User *featuredUser;
@property(nonatomic, assign) NSInteger featuredUserCellIndex;

+(NSString *)reuseIdentifier;

-(void)setCellWithClipGroup:(ClipGroup *)group andIndex:(NSInteger)index;

@end
