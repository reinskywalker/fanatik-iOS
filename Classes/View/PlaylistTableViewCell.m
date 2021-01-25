//
//  PlaylistTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/17/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "PlaylistTableViewCell.h"

@implementation PlaylistTableViewCell

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

-(void)fillWithPlaylist:(Playlist *)ply{
    self.playlistNameLabel.text = ply.playlist_name;
}

@end
