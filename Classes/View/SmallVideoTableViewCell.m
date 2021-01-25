//
//  SmallVideoTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/12/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "SmallVideoTableViewCell.h"
#import "Thumbnail+functionality.h"
#import "Video+functionality.h"
#import "ClipStats+functionality.h"
#import "SmallMoreVideoCollectionView.h"
#import "FeaturedUserCollectionView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SmallVideoTableViewCell
@synthesize currentClipGroup, clipsArray, clipCollectionView, delegate, currentIndexSection, featuredUser, featuredUserCellIndex;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
}

-(void)setCellWithClipGroup:(ClipGroup *)group andIndex:(NSInteger)index{
    self.currentIndexSection = index;
    
    self.currentClipGroup = group;
    
    UINib *cellNib = [UINib nibWithNibName:@"SmallVideoCollectionView" bundle:nil];
    [self.clipCollectionView registerNib:cellNib forCellWithReuseIdentifier:[SmallVideoCollectionView reuseIdentifier]];
    
    UINib *cellNib2 = [UINib nibWithNibName:@"SmallMoreVideoCollectionView" bundle:nil];
    [self.clipCollectionView registerNib:cellNib2 forCellWithReuseIdentifier:[SmallMoreVideoCollectionView reuseIdentifier]];
    

    UINib *cellNib3 = [UINib nibWithNibName:@"FeaturedUserCollectionView" bundle:nil];
    [self.clipCollectionView registerNib:cellNib3 forCellWithReuseIdentifier:[FeaturedUserCollectionView reuseIdentifier]];
    

    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"clip_position" ascending:YES];
    
    self.clipsArray = [[group.clip_group_clips array] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:firstDescriptor, nil]];
    
    if (group.clip_group_user) {
        self.featuredUserCellIndex = index;
        self.featuredUser = group.clip_group_user;
    }
    [clipCollectionView reloadData];
}

#pragma mark – UICollectionViewDelegateFlowLayout
-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = HEXCOLOR(0xEEEEEEFF);
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSInteger lastCollectionView = clipsArray.count;
    NSInteger arrayIndex = indexPath.row;
    if(currentIndexSection == featuredUserCellIndex){
        lastCollectionView = lastCollectionView + 1;
        arrayIndex= indexPath.row - 1;
        if(indexPath.row == 0){
            [delegate didSelectFeaturedUser:self.featuredUser];
            return;
        }
    }
    if (indexPath.row == lastCollectionView) {
        [delegate didTapMoreVideoButton:self.currentIndexSection];
        
    }else{
        Clip *clip = [clipsArray objectAtIndex:arrayIndex];
        [delegate didSelectClip:clip];
    }
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(currentIndexSection == featuredUserCellIndex){
        return clipsArray.count+2;
    }
    return clipsArray.count+1;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger lastCollectionView = clipsArray.count;
    NSInteger arrayIndex = indexPath.row;
    if(currentIndexSection == featuredUserCellIndex){
        lastCollectionView = lastCollectionView + 1;
        arrayIndex = arrayIndex - 1;
        if(indexPath.row == 0){
            FeaturedUserCollectionView *cell = [cv dequeueReusableCellWithReuseIdentifier:@"FeaturedUserCollectionView" forIndexPath:indexPath];
            [cell setItem:self.featuredUser];
            cell.layer.borderWidth = 1.0f;
            cell.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.2].CGColor;
//            cell.layer.masksToBounds = NO;
//            cell.layer.shadowOpacity = 0.75f;
//            cell.layer.shadowRadius = 1.0f;
            return cell;
        }
    }
    
    if (indexPath.row == lastCollectionView) {
        SmallMoreVideoCollectionView *cell = [cv dequeueReusableCellWithReuseIdentifier:@"SmallMoreVideoCollectionView" forIndexPath:indexPath];
        cell.layer.borderWidth = 1.0f;
        cell.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.2].CGColor;
//        cell.layer.masksToBounds = NO;
//        cell.layer.shadowOpacity = 0.75f;
//        cell.layer.shadowRadius = 1.0f;
        return cell;
    }else{
        
        SmallVideoCollectionView *cell = [cv dequeueReusableCellWithReuseIdentifier:@"SmallVideoCollectionView" forIndexPath:indexPath];
        cell.delegate = self;
        
        Clip *clip = [clipsArray objectAtIndex:arrayIndex];
        [cell setItem:clip];
        cell.layer.borderWidth = 1.0f;
        cell.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.2].CGColor;
//        cell.layer.masksToBounds = NO;
//        cell.layer.shadowOpacity = 0.75f;
//        cell.layer.shadowRadius = 1.0f;
        return cell;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(160, 150);
}



@end
