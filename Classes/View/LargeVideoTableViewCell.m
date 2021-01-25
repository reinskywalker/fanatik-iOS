//
//  LargeVideoTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/12/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "LargeVideoTableViewCell.h"
#import "Thumbnail+functionality.h"
#import "Video+functionality.h"
#import "ClipStats+functionality.h"

@implementation LargeVideoTableViewCell
@synthesize currentClipGroup, clipsArray, clipCollectionView, delegate;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)setCellWithClipGroup:(ClipGroup *)group{
    UINib *cellNib = [UINib nibWithNibName:@"LargeVideoCollectionView" bundle:nil];
    [self.clipCollectionView registerNib:cellNib forCellWithReuseIdentifier:[LargeVideoCollectionView reuseIdentifier]];
    
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"clip_position" ascending:YES];
    
    self.clipsArray = [[group.clip_group_clips array] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:firstDescriptor, nil]];
    
    [clipCollectionView reloadData];
    
}

#pragma mark - Cell Delegate
-(void)didTapMoreButtonForClip:(Clip *)aClip{
    [delegate didTapMoreButtonForClip:aClip];
}

#pragma mark – UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    Clip *clip = [clipsArray objectAtIndex:indexPath.row];
    [delegate didSelectClip:clip];
     
}

-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    LargeVideoCollectionView *cell = (LargeVideoCollectionView *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = HEXCOLOR(0xEEEEEEFF);
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    LargeVideoCollectionView *cell = (LargeVideoCollectionView *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return clipsArray.count;

}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(290.0, 240.0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LargeVideoCollectionView *cell = [cv dequeueReusableCellWithReuseIdentifier:@"LargeVideoCollectionView" forIndexPath:indexPath];
    cell.delegate = self;
    
    Clip *clip = [clipsArray objectAtIndex:indexPath.row];
    [cell setItem:clip];
    cell.layer.borderWidth = 1.0f;
    cell.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.2].CGColor;
//    cell.layer.masksToBounds = NO;
//    cell.layer.shadowOpacity = 0.75f;
//    cell.layer.shadowRadius = 1.0f;
    return cell;
}

@end
