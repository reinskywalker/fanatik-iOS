//
//  SearchViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/10/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchClipTableViewCell.h"
#import "TimelinePlaylistTableViewCell.h"
#import "UserFollowTableViewCell.h"
#import "VideoDetailViewController.h"
#import "EmptyLabelTableViewCell.h"
#import "PlaylistDetailsViewController.h"

typedef enum {
    SearchModeVideo = 0,
    SearchModeUser,
    SearchModePlaylist
}SearchMode;

@interface SearchViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UserFollowTableViewCellDelegate, TimelinePlaylistTableViewCellDelegate, SearchClipTableViewCellDelegate>

@property(nonatomic, assign) SearchMode currentSearchMode;
@property(nonatomic, copy) NSString *currentKeyword;
@property(nonatomic, retain) NSMutableArray *clipsArray;
@property(nonatomic, retain) NSMutableArray *usersArray;
@property(nonatomic, retain) NSMutableArray *playlistsArray;
@property(nonatomic, assign) int currentClipPage;
@property(nonatomic, assign) int currentUserPage;
@property(nonatomic, assign) int currentPlaylistPage;
@property(nonatomic, assign) BOOL isReloading;
@property(nonatomic, assign) BOOL isTableEmpty;
@property(nonatomic, retain) Clip *currentClip;
@end

@implementation SearchViewController

@synthesize searchTextContainerView, searchTextField, videoButton, userButton, playlistButton;
@synthesize currentSearchMode, isReloading, isTableEmpty, tabView;

-(id)init{
    if(self = [super init]){
        self.currentSearchMode = SearchModeVideo;
        self.clipsArray = [NSMutableArray array];
        self.usersArray = [NSMutableArray array];
        self.playlistsArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureView];
    
}

-(void)configureView{
    [self.myTableView registerNib:[UINib nibWithNibName:[SearchClipTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[SearchClipTableViewCell reuseIdentifier]];
    
    [self.myTableView registerNib:[UINib nibWithNibName:[TimelinePlaylistTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[TimelinePlaylistTableViewCell reuseIdentifier]];
    
    [self.myTableView registerNib:[UINib nibWithNibName:[UserFollowTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[UserFollowTableViewCell reuseIdentifier]];
    
    [self.myTableView registerNib:[UINib nibWithNibName:[EmptyLabelTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[EmptyLabelTableViewCell reuseIdentifier]];
    
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchTextContainerView.layer.cornerRadius = CGRectGetHeight(self.searchTextContainerView.frame)/2;
    self.searchTextContainerView.layer.masksToBounds = YES;
    self.videoButton.alpha = 0.5;
    self.userButton.alpha = 0.5;
    self.playlistButton.alpha = 0.5;
    switch (currentSearchMode) {
        case SearchModeVideo:
            self.videoButton.alpha = 1.0;
            break;
        case SearchModeUser:{
            self.userButton.alpha = 1.0;
        }
            break;
        case SearchModePlaylist:{
            self.playlistButton.alpha= 1.0;
        }
            break;
            
        default:
            break;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.myTableView addPullToRefreshWithActionHandler:^{
        if(weakSelf.currentKeyword && ![weakSelf.currentKeyword isEqualToString:@""]){
            weakSelf.currentClipPage = 0;
            weakSelf.currentPlaylistPage = 0;
            weakSelf.currentUserPage = 0;

            [weakSelf.myTableView reloadData]; // before load new content, clear the existing table list
        
            [weakSelf searchWithKeyword:weakSelf.currentKeyword isClearDataFirst:YES]; // load new data
            [weakSelf.myTableView.pullToRefreshView stopAnimating]; // clear the animation
            
            // once refresh, allow the infinite scroll again
            weakSelf.myTableView.showsInfiniteScrolling = YES;
        }else{
            [weakSelf.myTableView.pullToRefreshView stopAnimating]; // clear the animation
        }
    }];
    
    // load more content when scroll to the bottom most
    [self.myTableView addInfiniteScrollingWithActionHandler:^{
        
        int myPage = 0;
        
        if (weakSelf.currentSearchMode == SearchModeVideo) {
            myPage = weakSelf.currentClipPage;
        }else if(weakSelf.currentSearchMode == SearchModeUser){
            myPage = weakSelf.currentUserPage;
        }else{
            myPage = weakSelf.currentPlaylistPage;
        }
        
        if(myPage && myPage > 0){
            [weakSelf searchWithKeyword:weakSelf.currentKeyword isClearDataFirst:NO];

        }else{
            weakSelf.myTableView.showsInfiniteScrolling = NO;
            [weakSelf.myTableView.pullToRefreshView stopAnimating];
            [weakSelf.myTableView.infiniteScrollingView stopAnimating];
            
        }
    }];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [searchTextField becomeFirstResponder];
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

- (IBAction)tabButtonTapped:(CustomBoldButton *)sender {
    self.videoButton.alpha = 0.5;
    self.userButton.alpha = 0.5;
    self.playlistButton.alpha = 0.5;
    if ([sender isEqual:self.videoButton]) {
        NSLog(@"video");
        self.currentSearchMode = SearchModeVideo;
        self.videoButton.alpha = 1;
    }else if([sender isEqual:self.userButton]){
        NSLog(@"user");
        self.currentSearchMode = SearchModeUser;
        self.userButton.alpha = 1;
    }else{
        NSLog(@"playlist");
        self.currentSearchMode = SearchModePlaylist;
        self.playlistButton.alpha = 1;
    }
    
    [self searchWithKeyword:self.currentKeyword isClearDataFirst:YES];
    
}

#pragma mark - Server Request
-(void)searchWithKeyword:(NSString *)keyword isClearDataFirst:(BOOL)isClear{
    if(isReloading || !self.currentKeyword || [self.currentKeyword isEqualToString:@""])
        return;
    [self.view startLoader: YES disableUI:NO];
    self.myTableView.userInteractionEnabled = NO;
    self.tabView.userInteractionEnabled = NO;
    
    switch (currentSearchMode) {
        case SearchModeVideo:{
            [Clip searchClipWithQuery:self.currentKeyword andPageNumber:@(self.currentClipPage) withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *clipsArray) {
                
                if(isClear){
                    self.myTableView.showsInfiniteScrolling = YES;
                    [self.clipsArray removeAllObjects];
                }
                
                NSData *responseData = operation.HTTPRequestOperation.responseData;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
                int currentRow = (int)[self.clipsArray count];
                [self.clipsArray addObjectsFromArray:clipsArray];
                PaginationModel *currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
                self.currentClipPage = currentPagination.nextPage;
                
                
                if(currentRow == 0){
                    self.isTableEmpty = self.clipsArray.count == 0;
                    [self.myTableView reloadData];
                }else{
                    [self reloadTableView:currentRow];
//                    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                }
                [self.myTableView startLoader:NO disableUI:NO];
                [self.myTableView.pullToRefreshView stopAnimating];
                [self.myTableView.infiniteScrollingView stopAnimating];
                self.isReloading = NO;
                [self.view startLoader:NO disableUI:NO];
                
                self.myTableView.userInteractionEnabled = YES;
                self.tabView.userInteractionEnabled = YES;
                
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                }
                
                self.myTableView.userInteractionEnabled = YES;
                self.tabView.userInteractionEnabled = YES;
                
            }];
        }
            break;
        case SearchModeUser:{
            [User searchUserWithQuery:self.currentKeyword withAccesToken:ACCESS_TOKEN() andPageNumber:@(self.currentUserPage) success:^(RKObjectRequestOperation *operation, NSArray *objectArray) {
                
                if(isClear){
                    self.myTableView.showsInfiniteScrolling = YES;
                    [self.usersArray removeAllObjects];
                }
                
                NSData *responseData = operation.HTTPRequestOperation.responseData;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
                int currentRow = (int)[self.usersArray count];
                [self.usersArray addObjectsFromArray:objectArray];
                PaginationModel *currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
                self.currentUserPage = currentPagination.nextPage;
                
                
                if(currentRow == 0){
                    self.isTableEmpty = self.usersArray.count == 0;
                    [self.myTableView reloadData];
                }else{
                    [self reloadTableView:currentRow];
//                    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation: UITableViewRowAnimationFade];
                }
                [self.myTableView startLoader:NO disableUI:NO];
                [self.myTableView.pullToRefreshView stopAnimating];
                [self.myTableView.infiniteScrollingView stopAnimating];
                self.isReloading = NO;
                [self.view startLoader:NO disableUI:NO];
                
                self.myTableView.userInteractionEnabled = YES;
                self.tabView.userInteractionEnabled = YES;
                
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [self.view startLoader: NO disableUI:NO];
                NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                }
                
                self.myTableView.userInteractionEnabled = YES;
                self.tabView.userInteractionEnabled = YES;

            }];
        }
            break;
        case SearchModePlaylist:{
            [Playlist searchPlaylistWithQuery:self.currentKeyword andPageNumber:@(self.currentPlaylistPage) withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *objectArray) {
                
                if(isClear){
                    self.myTableView.showsInfiniteScrolling = YES;
                    [self.playlistsArray removeAllObjects];
                }
                    
                NSData *responseData = operation.HTTPRequestOperation.responseData;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
                int currentRow = (int)[self.playlistsArray count];
                [self.playlistsArray addObjectsFromArray:objectArray];
                PaginationModel *currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
                self.currentPlaylistPage = currentPagination.nextPage;
                
                
                if(currentRow == 0){
                    self.isTableEmpty = self.playlistsArray.count == 0;
                    [self.myTableView reloadData];
                }else{
                    [self reloadTableView:currentRow];
//                    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                }
                [self.myTableView startLoader:NO disableUI:NO];
                [self.myTableView.pullToRefreshView stopAnimating];
                [self.myTableView.infiniteScrollingView stopAnimating];
                self.isReloading = NO;
                [self.view startLoader:NO disableUI:NO];
                
                self.myTableView.userInteractionEnabled = YES;
                self.tabView.userInteractionEnabled = YES;
                
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                NSLog(@"Error find playlists");
                [self.view startLoader: NO disableUI:NO];
                if(self.playlistsArray.count == 0){
                    self.myTableView.hidden = YES;
                    self.emptyLabel.text = @"Pencarian Error.";
                    self.emptyLabel.hidden = NO;
                }
                
                NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                }
                
                self.myTableView.userInteractionEnabled = YES;
                self.tabView.userInteractionEnabled = YES;

            }];

        }
            break;
            
        default:
            break;
    }
}

- (void)reloadTableView:(int)startingRow;
{
    // the last row after added new items
    int endingRow = 0;
    if(self.currentSearchMode == SearchModeVideo)
        endingRow = (int)[self.clipsArray count];
    else if(self.currentSearchMode == SearchModeUser)
        endingRow = (int)[self.usersArray count];
    else if(self.currentSearchMode == SearchModePlaylist)
        endingRow = (int)[self.playlistsArray count];
    
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (; startingRow < endingRow; startingRow++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:startingRow inSection:0]];
    }
    
    [self.myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
}


#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    self.currentKeyword = textField.text;
    if([textField.text length] > 2){
        [self searchWithKeyword:textField.text isClearDataFirst:YES];
        [textField resignFirstResponder];
    }else{
        [self showAlertWithMessage:@"Please enter at least 3 characters to search"];
    }
    
    return YES;
}

#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(isTableEmpty)
        return 57.0;
    CGFloat height = currentSearchMode == SearchModeVideo ? 85.0 : currentSearchMode == SearchModePlaylist ?  190.0 :  44.0;
    return height;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(isTableEmpty)
        return 1;
    switch (currentSearchMode) {
        case SearchModeVideo:
            return self.clipsArray.count;
            break;
        case SearchModeUser:
            return self.usersArray.count;
            break;
            
        default:
            return self.playlistsArray.count;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isTableEmpty){
        EmptyLabelTableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:[EmptyLabelTableViewCell reuseIdentifier]];
        
        emptyCell.emptyLabel.text = @"Pencarian tidak ditemukan";
        return emptyCell;
    }
    if(currentSearchMode == SearchModeVideo){
        SearchClipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SearchClipTableViewCell reuseIdentifier]];
        cell.delegate = self;
        [cell fillWithClip:[self.clipsArray objectAtIndex:indexPath.row]];
        return cell;
    }else if(currentSearchMode == SearchModeUser){
        UserFollowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UserFollowTableViewCell reuseIdentifier]];
        [cell fillCellWithUser:[self.usersArray objectAtIndex:indexPath.row]];
        [cell setCanFollow:YES];
        cell.delegate = self;
        return cell;
    }else{
        TimelinePlaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TimelinePlaylistTableViewCell reuseIdentifier]];
        [cell setItemWithPlayList:[self.playlistsArray objectAtIndex:indexPath.row]];
        cell.delegate = self;
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(isTableEmpty)
        return;
    if(currentSearchMode == SearchModeVideo){
        Clip *theClip = [self.clipsArray objectAtIndex:indexPath.row];
        VideoDetailViewController *vc = [[VideoDetailViewController alloc] initWithClip:theClip];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (currentSearchMode == SearchModeUser){
        User *theUser = [self.usersArray objectAtIndex:indexPath.row];
        ProfileViewController *vc = [[ProfileViewController alloc] initWithUser:theUser];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(currentSearchMode == SearchModePlaylist){
        Playlist *aPlaylist = [self.playlistsArray objectAtIndexedSubscript:indexPath.row];
        [self.navigationController pushViewController:[[PlaylistDetailsViewController alloc] initWithPlaylist:aPlaylist] animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isTableEmpty){
        self.myTableView.backgroundColor = [UIColor clearColor];
    }else{
        self.myTableView.backgroundColor = [UIColor whiteColor];
    }

    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
}


#pragma mark - CustomCell Delegate
-(void)moreButtonDidTapForClip:(Clip *)clip{
    self.currentClip = clip;
    [self moreButtonTappedForClip:clip];
}

-(void)successToFollowOrUnfollowWithUser:(User *)obj{

}

-(void)failedToFollowOrUnfollowWithErrorString:(NSString *)errorString{
    [self showLocalValidationError:errorString];
}

-(void)didSelectClip:(Clip *)aClip{
    VideoDetailViewController *vc = [[VideoDetailViewController alloc] initWithClip:aClip];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
