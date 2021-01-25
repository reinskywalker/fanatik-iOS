//
//  PlaylistViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/16/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
@class PlaylistViewController;
@protocol PlaylistViewControllerDelegate <NSObject>

-(void)playlistViewController:(PlaylistViewController *)vc closeButtonDidTap:(id)sender;
-(void)playlistViewController:(PlaylistViewController *)vc newPlaylistButtonDidTap:(id)sender;

@end

@interface PlaylistViewController : ParentViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet CustomMediumButton *createPlaylistButton;

@property (strong, nonatomic) IBOutlet CustomMediumButton *doneButton;
@property (strong, nonatomic) IBOutlet UITextField *playlistNameTF;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *emptyLabel;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, weak) id <PlaylistViewControllerDelegate> delegate;
- (IBAction)doneButtonTapped:(id)sender;
- (IBAction)createButtonTapped:(id)sender;
- (id)initWithClip:(Clip *)clip;

@end
