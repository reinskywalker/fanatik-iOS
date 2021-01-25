//
//  ProfilePlaylistTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "ProfilePlaylistTableViewCell.h"
#import "Thumbnail+functionality.h"
#import "Video+functionality.h"
#import "ClipStats+functionality.h"

@implementation ProfilePlaylistTableViewCell

@synthesize playlistNameLabel, playlistVideoCountLabel, clipsArray, clipCollectionView, delegate;

-(void)setItemWithPlayList:(Playlist *)pl{

    playlistNameLabel.text = pl.playlist_name;
    
    UINib *cellNib = [UINib nibWithNibName:@"SmallVideoCollectionView" bundle:nil];
    [self.clipCollectionView registerNib:cellNib forCellWithReuseIdentifier:[SmallVideoCollectionView reuseIdentifier]];
    
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"clip_position" ascending:YES];
    
    self.clipsArray = [[pl.playlist_clips allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:firstDescriptor, nil]];
    
    playlistVideoCountLabel.text = [NSString stringWithFormat:@"%lu video", (unsigned long)self.clipsArray.count];
    
    [clipCollectionView reloadData];

}


+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}



#pragma mark – UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    Clip *clip = [clipsArray objectAtIndex:indexPath.row];
    [delegate didSelectClip:clip];
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return clipsArray.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SmallVideoCollectionView *cell = [cv dequeueReusableCellWithReuseIdentifier:@"SmallVideoCollectionView" forIndexPath:indexPath];
    cell.delegate = self;
    
    Clip *clip = [clipsArray objectAtIndex:indexPath.row];
    [cell setItem:clip];
    return cell;
}

@end
