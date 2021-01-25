//
//  PlaylistTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/17/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet CustomRegularLabel *playlistNameLabel;

+(NSString *)reuseIdentifier;
-(void)fillWithPlaylist:(Playlist *)ply;
@end
