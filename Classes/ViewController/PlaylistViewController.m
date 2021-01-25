//
//  PlaylistViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/16/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "PlaylistViewController.h"
#import "PlaylistTableViewCell.h"

@interface PlaylistViewController ()
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *createViewContainerHeight;
@property (strong, nonatomic) IBOutlet UISwitch *isPublicSwitch;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, retain) NSMutableArray *playlistsArray;
@property (nonatomic, retain) Playlist *currentPlaylist;

@property (nonatomic, retain) NSIndexPath* checkedIndexPath;
@property (nonatomic, assign) BOOL isCreateNew;
@property (strong, nonatomic) IBOutlet UILabel *isPublicLabel;

@end

@implementation PlaylistViewController
@synthesize delegate, playlistNameTF, currentPage, playlistsArray, doneButton, createViewContainerHeight, isCreateNew, isPublicSwitch, createPlaylistButton, isPublicLabel, currentClip, currentPlaylist;

-(id)initWithClip:(Clip *)clip{
    if(self = [super init]){
        self.playlistsArray = [NSMutableArray new];
        self.currentClip = clip;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    [self getPlaylistsFromServer];
    
}

-(void)configureView{
    [self reloadData];
    CGFloat fontSize = playlistNameTF.font.pointSize;
    
    [playlistNameTF setFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:fontSize]];
    
    if ([self respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = HEXCOLOR(0xccccccff);
        playlistNameTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:playlistNameTF.placeholder?playlistNameTF.placeholder : @"" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    [self.myTableView registerNib:[UINib nibWithNibName:[PlaylistTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[PlaylistTableViewCell reuseIdentifier]];
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) weakSelf = self;
    [self.myTableView addPullToRefreshWithActionHandler:^{
       
        weakSelf.currentPage = 0;
        [weakSelf.playlistsArray removeAllObjects];
        [weakSelf.myTableView reloadData]; // before load new content, clear the existing table list
        [weakSelf getPlaylistsFromServer]; // load new data
        [weakSelf.myTableView.pullToRefreshView stopAnimating]; // clear the animation
        
        // once refresh, allow the infinite scroll again
        weakSelf.myTableView.showsInfiniteScrolling = YES;
        
    }];
    
    // load more content when scroll to the bottom most
    [self.myTableView addInfiniteScrollingWithActionHandler:^{
        if(weakSelf.currentPage && weakSelf.currentPage > 0){
            [weakSelf getPlaylistsFromServer];
        }else{
            weakSelf.myTableView.showsInfiniteScrolling = NO;
            [weakSelf.myTableView.pullToRefreshView stopAnimating];
            [weakSelf.myTableView.infiniteScrollingView stopAnimating];
            
        }
    }];
    


}

-(void)refreshTableView{
    self.playlistNameTF.text = @"";
    self.currentPage = 0;
    [self.playlistsArray removeAllObjects];
    [self.myTableView reloadData]; // before load new content, clear the existing table list
    [self getPlaylistsFromServer]; // load new data
    [self.myTableView.pullToRefreshView stopAnimating]; // clear the animation
    self.myTableView.showsInfiniteScrolling = YES;
}

-(void)reloadData{
    if(playlistsArray.count > 0){
        self.myTableView.hidden = NO;
        self.emptyLabel.hidden = YES;
    }else{
        self.myTableView.hidden = YES;
        self.emptyLabel.hidden = NO;
    }
    
    
}

-(void)changeCreateState{
    if(isCreateNew){
        [self.doneButton setTitle:@"Selesai" forState:UIControlStateNormal];
        createPlaylistButton.hidden = NO;
        playlistNameTF.hidden = YES;
        isPublicLabel.hidden = YES;
        isPublicSwitch.hidden = YES;
        createViewContainerHeight.constant = 50.0;
        isCreateNew = NO;
        [playlistNameTF resignFirstResponder];
    }else{
        [self.doneButton setTitle:@"Submit" forState:UIControlStateNormal];
        createPlaylistButton.hidden = YES;
        playlistNameTF.hidden = NO;
        isPublicSwitch.hidden = NO;
        isPublicLabel.hidden = NO;
        createViewContainerHeight.constant = 100.0;
        isCreateNew = YES;
        [playlistNameTF becomeFirstResponder];
    }
}

#pragma mark - Server Request
-(void)getPlaylistsFromServer{
    [self.view startLoader:YES disableUI:NO];
    [Playlist getAllPlaylistWithUserId:CURRENT_USER_ID() andPageNumber:@(currentPage) withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *objectArray) {
        [self.myTableView startLoader:NO disableUI:NO];
        NSData *responseData = operation.HTTPRequestOperation.responseData;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
        int currentRow = (int)[self.playlistsArray count];
        [self.playlistsArray addObjectsFromArray:objectArray];
        [self reloadData];
        PaginationModel *currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
        self.currentPage = currentPagination.nextPage;
        
        
        if(currentRow == 0){
            [self.myTableView reloadData];
        }else{
            [self reloadTableView:currentRow];
        }
        [self.myTableView.pullToRefreshView stopAnimating];
        [self.myTableView.infiniteScrollingView stopAnimating];
        [self.view startLoader:NO disableUI:NO];
        if(self.playlistsArray.count == 0){
            self.myTableView.hidden = YES;
            self.emptyLabel.hidden = NO;
        }else{
            self.myTableView.hidden = NO;
            self.emptyLabel.hidden = YES;
        }

        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error find playlist");
        [self.myTableView startLoader:NO disableUI:NO];
        [self.view startLoader: NO disableUI:NO];
        if(self.playlistsArray.count == 0){
            self.myTableView.hidden = YES;
            self.emptyLabel.hidden = NO;
        }
        
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
        }

    }];
}

-(void)savePlaylistToServer{
    
    
    [self.view startLoader:YES disableUI:NO];
    NSDictionary *pDict = @{@"name" : playlistNameTF.text, @"private" : @(!isPublicSwitch.isOn)};
    [Playlist createPlaylistWithDict:pDict andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Playlist *playlist) {
        [self refreshTableView];
        [self.view startLoader:NO disableUI:NO];
        self.currentPlaylist = playlist;
        [self addClipToPlaylist];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
            [self.view startLoader:NO disableUI:NO];
        }
    }];
    
}

-(void)addClipToPlaylist{
    [Playlist addClipsWithIdArray:@[currentClip.clip_id] toPlaylistWithId:currentPlaylist.playlist_id andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        
        if([delegate respondsToSelector:@selector(playlistViewController:closeButtonDidTap:)]){
            [delegate playlistViewController:self closeButtonDidTap:nil];
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
        }
    
    }];
}

-(BOOL)validatePlaylist{
    if(playlistNameTF.text && ![playlistNameTF.text isEqualToString:@""]){
        return YES;
    }
    return NO;
}

- (void)reloadTableView:(int)startingRow;
{
    // the last row after added new items
    int endingRow = (int)[self.playlistsArray count];
    
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (; startingRow < endingRow; startingRow++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:startingRow inSection:0]];
    }
    
    [self.myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
}


#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.playlistsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PlaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[PlaylistTableViewCell reuseIdentifier]];
    [cell fillWithPlaylist:[self.playlistsArray objectAtIndex:indexPath.row]];
    if([self.checkedIndexPath isEqual:indexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }


    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.currentPlaylist = playlistsArray[indexPath.row];
    if(self.checkedIndexPath)
    {
        UITableViewCell* uncheckCell = [tableView
                                        cellForRowAtIndexPath:self.checkedIndexPath];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
    }
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.checkedIndexPath = indexPath;
    if(isCreateNew){
        
        [self changeCreateState];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBActions

- (IBAction)doneButtonTapped:(id)sender {
    if(!isCreateNew){
        if(self.currentPlaylist)
            [self addClipToPlaylist];
        else
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
        
        
    }else{
        //Save playlist
        if([self validatePlaylist]){
            [self savePlaylistToServer];
            [self changeCreateState];
        }
        else{
            [self showAlertWithMessage:@"Nama playlist harus diisi"];
        }

    }
}

- (IBAction)createButtonTapped:(id)sender {
    
    if(!isCreateNew){
        [self changeCreateState];
        
    }
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end
