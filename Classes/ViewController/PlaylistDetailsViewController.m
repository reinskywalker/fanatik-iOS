//
//  PlaylistDetailsViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/10/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "PlaylistDetailsViewController.h"
#import "SearchClipTableViewCell.h"

#import "VideoDetailViewController.h"
typedef enum {
    SearchModeVideo = 0,
    SearchModeUser,
    SearchModePlaylist
}SearchMode;

@interface PlaylistDetailsViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, SearchClipTableViewCellDelegate, IBActionSheetDelegate, UIAlertViewDelegate>


@property(nonatomic, retain) NSMutableArray *clipsArray;
@property(nonatomic, assign) int currentPage;
@property(nonatomic, assign) BOOL isReloading;

@property(nonatomic, retain) Playlist *currentPlaylist;
@property(nonatomic, retain) NSString *currentPlaylistID;
@end

@implementation PlaylistDetailsViewController

@synthesize isReloading, currentPlaylist, currentPage, customIBAS;

-(id)initWithPlaylist:(Playlist *)play{
    if(self = [super init]){
        self.currentPlaylist = play;
        self.clipsArray = [NSMutableArray new];
        self.currentPage = 0;
    }
    return self;
}

-(id)initWithPlaylistID:(NSString *)playID{
    if(self = [super init]){
        self.currentPlaylistID = playID;
        self.clipsArray = [NSMutableArray new];
        self.currentPage = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    [self.myTableView triggerPullToRefresh];
    self.playlistTitleLabel.text = currentPlaylist.playlist_name;

}

-(void)configureView{
    [self.myTableView registerNib:[UINib nibWithNibName:[SearchClipTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[SearchClipTableViewCell reuseIdentifier]];
        self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    __weak typeof(self) weakSelf = self;
    [self.myTableView addPullToRefreshWithActionHandler:^{
        
        weakSelf.currentPage = 0;
        [weakSelf.clipsArray removeAllObjects];
        [weakSelf.myTableView reloadData]; // before load new content, clear the existing table list
        [weakSelf getDataFromServer]; // load new data
        [weakSelf.myTableView.pullToRefreshView stopAnimating]; // clear the animation
        
        // once refresh, allow the infinite scroll again
        weakSelf.myTableView.showsInfiniteScrolling = YES;
        
    }];
    
    // load more content when scroll to the bottom most
    [self.myTableView addInfiniteScrollingWithActionHandler:^{
        
        if(weakSelf.currentPage && weakSelf.currentPage > 0){
            [weakSelf getDataFromServer];
        }else{
            weakSelf.myTableView.showsInfiniteScrolling = NO;
            [weakSelf.myTableView.pullToRefreshView stopAnimating];
            [weakSelf.myTableView.infiniteScrollingView stopAnimating];
            
        }
    }];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIView animateWithDuration:0.3 animations:^{
        [self.navigationController.navigationBar setAlpha:0.0];
    }];

//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        [self.navigationController.navigationBar setAlpha:1.0];
    }];
}

#pragma mark - IBActions

#pragma mark - Server Request
-(void)getDataFromServer{
    if(isReloading)
        return;
    self.isReloading = YES;
    [self.view startLoader: YES disableUI:NO];
    
    NSLog(@"user id = %@, currentPlayList = %@, currentPage = %zd", CURRENT_USER_ID(),currentPlaylist.playlist_id, currentPage);
    [Playlist getPlaylistDetailWithUserId:self.currentPlaylistID && ![self.currentPlaylistID isEqualToString:@""] ?self.currentPlaylistID : currentPlaylist.playlist_user_id andPlaylistId:currentPlaylist.playlist_id andPageNumber:@(currentPage) withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Playlist *playlist) {
        NSData *responseData = operation.HTTPRequestOperation.responseData;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
        int currentRow = (int)[self.clipsArray count];
        [self.clipsArray addObjectsFromArray:[playlist.playlist_clips allObjects]];
        PaginationModel *currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
        self.currentPage = currentPagination.nextPage;
        
        
        if(currentRow == 0){
            [self.myTableView reloadData];
        }else{
            [self reloadTableView:currentRow];
        }
        [self.myTableView startLoader:NO disableUI:NO];
        [self.myTableView.pullToRefreshView stopAnimating];
        [self.myTableView.infiniteScrollingView stopAnimating];
        self.isReloading = NO;
        self.playlistVideoCountLabel.text = [NSString stringWithFormat:@"%lu Video",(unsigned long)self.clipsArray.count];
        [self.view startLoader:NO disableUI:NO];

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error find playlists");
        [self.view startLoader: NO disableUI:NO];
        
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
        }
    }];
    
    
}

- (void)reloadTableView:(int)startingRow;
{
    // the last row after added new items
    int endingRow = (int)[self.clipsArray count];
    
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (; startingRow < endingRow; startingRow++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:startingRow inSection:0]];
    }
    
    [self.myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
}


#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 85.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.clipsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchClipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SearchClipTableViewCell reuseIdentifier]];
    cell.delegate = self;
    [cell fillWithClip:[self.clipsArray objectAtIndex:indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Clip *theClip = [self.clipsArray objectAtIndex:indexPath.row];
    VideoDetailViewController *vc = [[VideoDetailViewController alloc] initWithClip:theClip];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - CustomCell Delegate
-(void)moreButtonDidTapForClip:(Clip *)clip{
    self.currentClip = clip;
    [self moreButtonTappedForClip:clip];
}

-(void)didSelectClip:(Clip *)aClip{
    VideoDetailViewController *vc = [[VideoDetailViewController alloc] initWithClip:aClip];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - moreButtonTapped
-(void)moreButtonTappedForClip:(Clip *)clip{
    NSString *title;
    
    if(!self.customIBAS.visible){
        self.customIBAS = [[IBActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Close" destructiveButtonTitle:nil otherButtonTitles:@"Share", @"Add to Playlist", nil];
        self.customIBAS.blurBackground = NO;
        [self.customIBAS setFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:14.0]];
        
        [self.customIBAS setButtonBackgroundColor:HEXCOLOR(0xFFFFFFFF)];
        [self.customIBAS setButtonTextColor:HEXCOLOR(0x3399FFFF)];
        [self.customIBAS setButtonTextColor:[UIColor redColor] forButtonAtIndex:2];
        
        self.customIBAS.buttonResponse = IBActionSheetButtonResponseFadesOnPress;
        self.customIBAS.tag = kActionSheetPlaylist;
        [self.customIBAS showInView:self.view];
        
    }else{
        NSLog(@"ha:%ld",(long)self.customIBAS.cancelButtonIndex);
        [self.customIBAS dismissWithClickedButtonIndex:self.customIBAS.numberOfButtons-1 animated:YES];
        
    }
}

-(IBAction)moreButtonTappedForPlaylist:(id)sender{
    NSString *title;
    
    if(!self.customIBAS.visible){
        self.customIBAS = [[IBActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Tutup" destructiveButtonTitle:nil otherButtonTitles: @"Hapus Playlist", nil];
        self.customIBAS.blurBackground = NO;
        [self.customIBAS setFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:14.0]];
        
        [self.customIBAS setButtonBackgroundColor:HEXCOLOR(0xFFFFFFFF)];
        [self.customIBAS setButtonTextColor:HEXCOLOR(0x3399FFFF)];
        [self.customIBAS setButtonTextColor:[UIColor redColor] forButtonAtIndex:1];
        
        self.customIBAS.buttonResponse = IBActionSheetButtonResponseFadesOnPress;
        self.customIBAS.tag = 101;
        [self.customIBAS showInView:self.view];
    }else{
        NSLog(@"ha:%ld",(long)self.customIBAS.cancelButtonIndex);
        [self.customIBAS dismissWithClickedButtonIndex:self.customIBAS.numberOfButtons-1 animated:YES];
        
    }
}

#pragma mark - IBActionSheet/UIActionSheet Delegate Method

// the delegate method to receive notifications is exactly the same as the one for UIActionSheet
- (void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag == kActionSheetPlaylist){
        switch (buttonIndex) {
            case 0:{
                NSLog(@"url: %@ | content: %@", self.currentClip.clip_shareable.shareable_url, self.currentClip.clip_shareable.shareable_content);
                NSString* someText = self.currentClip.clip_shareable.shareable_content;
                NSURL* linkText = [[NSURL alloc] initWithString: self.currentClip.clip_shareable.shareable_url];
                NSArray* dataToShare = [NSArray arrayWithObjects: someText,linkText, nil];
                UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
                activityViewController.excludedActivityTypes = @[ UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypePrint ];
                [self presentViewController:activityViewController animated:YES completion:^{}];
                
            }
                break;
            case 1:{
                
                [UIAlertView showWithTitle:self.appName
                                   message:@"Anda yakin?"
                         cancelButtonTitle:@"Tidak"
                         otherButtonTitles:@[@"Ya"]
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      
                    if (buttonIndex != [alertView cancelButtonIndex]) {
                        [Playlist removeClipWithId:self.currentClip.clip_id fromPlaylistWithId:currentPlaylist.playlist_id withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Playlist *playlist) {
                            [self.myTableView triggerPullToRefresh];
                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                                [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                            }
                        }];
                    }
                }];
            }
                break;
            default:
                break;
        }
    }else if(actionSheet.tag == 101){
        switch (buttonIndex) {
            case 0:{

            [UIAlertView showWithTitle:self.appName
                               message:@"Anda yakin?"
                     cancelButtonTitle:@"Tidak"
                     otherButtonTitles:@[@"Ya"]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex != [alertView cancelButtonIndex]) {
                                      
                                      [Playlist deletePlaylistWithId:currentPlaylist.playlist_id withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *objectArray) {
                                          [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshProfilePage object:nil];
                                          [self backButtonTapped:nil];
                                      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                          
                                          NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                                          if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                                              NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                                              [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                                          }
                                      }];
                                      
                                  }
                              }];
            }
                break;
            
            default:
                break;
        }
    }
}

@end
