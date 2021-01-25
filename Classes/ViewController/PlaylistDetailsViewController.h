//
//  PlaylistDetailsViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/10/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"

@interface PlaylistDetailsViewController : ParentViewController

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UILabel *playlistTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *playlistVideoCountLabel;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UIButton *moreButtonTapped;

-(id)initWithPlaylist:(Playlist *)play;
-(IBAction)moreButtonTappedForPlaylist:(id)sender;
-(id)initWithPlaylistID:(NSString *)playID;
@end
