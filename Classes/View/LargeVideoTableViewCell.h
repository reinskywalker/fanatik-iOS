//
//  LargeVideoTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/12/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LargeVideoCollectionView.h"

@protocol LargeVideoTableViewCellDelegate <NSObject>

-(void)didSelectClip:(Clip *)aClip;
-(void)didTapMoreButtonForClip:(Clip *)clip;

@end

@interface LargeVideoTableViewCell : UITableViewCell<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LargeVideoCollectionViewDelegate>

@property(nonatomic, assign) id <LargeVideoTableViewCellDelegate> delegate;
@property(nonatomic, retain) IBOutlet UICollectionView *clipCollectionView;
@property(nonatomic, retain) ClipGroup *currentClipGroup;
@property(nonatomic, retain) NSArray *clipsArray;

+(NSString *)reuseIdentifier;
-(void)setCellWithClipGroup:(ClipGroup *)group;

@end
