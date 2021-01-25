//
//  ActivityPlaylistTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "ActivityPlaylistTableViewCell.h"
#import "Thumbnail+functionality.h"
#import "Video+functionality.h"
#import "ClipStats+functionality.h"

@implementation ActivityPlaylistTableViewCell

@synthesize playlistNameLabel, playlistVideoCountLabel, clipsArray, clipCollectionView, delegate;
@synthesize userImageView, activityLabel, timeLabel;

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


- (void) fillWithTimeline:(Timeline*)obj{
    
    self.contentView.backgroundColor = [UIColor orangeColor];
    self.backgroundView.backgroundColor = [UIColor greenColor];
    
    NSLog(@"url = %@",obj.timeline_actor.actor_avatar.avatar_thumbnail);
    NSURL *avatarURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", obj.timeline_actor.actor_avatar.avatar_thumbnail]];
    self.userImageView.image = nil;
    [self.userImageView sd_setImageWithURL:avatarURL];
    
    self.timeLabel.text = [obj valueForKey:@"timeline_time_ago"];
    
    NSString *htmlString = [NSString stringWithFormat:@"%@",[obj valueForKey:@"timeline_description"]];
    
    self.activityLabel.attributedText  = [OHASBasicHTMLParser attributedStringByProcessingMarkupInAttributedString:[TheInterfaceManager processedOHHTMLString:htmlString andFontSize:12.0]];
    self.activityLabel.numberOfLines = 2;
    
    
    [self layoutIfNeeded];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.userImageView.layer.cornerRadius = CGRectGetWidth(self.userImageView.frame)/2;
    self.userImageView.layer.masksToBounds = YES;
    
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
