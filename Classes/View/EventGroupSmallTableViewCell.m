//
//  EventGroupSmallTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/12/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "EventGroupSmallTableViewCell.h"
#import "EventCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation EventGroupSmallTableViewCell
@synthesize currentEventGroup, eventsArray, eventCollectionView, delegate;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)fillWithEventGroup:(EventGroup *)group{
    
    self.currentEventGroup = group;
    
    UINib *cellNib = [UINib nibWithNibName:@"EventCollectionViewCell" bundle:nil];
    [self.eventCollectionView registerNib:cellNib forCellWithReuseIdentifier:[EventCollectionViewCell reuseIdentifier]];
    
    self.eventsArray = [group.event_group_events array];
    [eventCollectionView reloadData];
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
    
    [self.delegate didSelectEvent:eventsArray[indexPath.row]];

}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.currentEventGroup.event_group_events array].count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    EventCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"EventCollectionViewCell" forIndexPath:indexPath];
    
    Event *event = [eventsArray objectAtIndex:indexPath.row];
    [cell setItem:event];
    cell.layer.borderWidth = 1.0f;
    cell.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.2].CGColor;
    return cell;
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(160, 151);
}



@end
