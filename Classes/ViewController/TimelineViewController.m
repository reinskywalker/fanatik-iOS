//
//  TimelineViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "TimelineViewController.h"
#import "TimelineUserTableViewCell.h"
#import "TimelinePlaylistTableViewCell.h"
#import "TimelineCustomHeader.h"
#import "ProfileViewController.h"
#import "ProfileVideoTableViewCell.h"

@interface TimelineViewController ()<UITableViewDataSource, UITableViewDelegate, TimelinePlaylistTableViewCellDelegate, ProfileVideoTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, copy) NSString *currentTitle;
@property (nonatomic, assign) int currentPage;

@end

@implementation TimelineViewController

@synthesize timelinesArray, currentPagination;
@synthesize timelineSectionHeaderView;
@synthesize sectionUserAvatar;
@synthesize sectionTimelineLabel;
@synthesize sectionTimeAgoView, currentPage, isTableEmpty;

-(id)init{
    if(self =[super init]){
        self.timelinesArray = [NSMutableArray new];
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [TheAppDelegate slidingViewController].title = @"Timeline";
    self.currentPageCode = MenuPageTimeline;
    
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.myTableView registerNib:[UINib nibWithNibName:[ProfileVideoTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[ProfileVideoTableViewCell reuseIdentifier]];
    [self.myTableView registerNib:[UINib nibWithNibName:[TimelineUserTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[TimelineUserTableViewCell reuseIdentifier]];
    [self.myTableView registerNib:[UINib nibWithNibName:[TimelinePlaylistTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[TimelinePlaylistTableViewCell reuseIdentifier]];
   
    [self.myTableView registerNib:[UINib nibWithNibName:NSStringFromClass([TimelineCustomHeader class]) bundle:nil] forHeaderFooterViewReuseIdentifier:NSStringFromClass([TimelineCustomHeader class])];
    [self.myTableView registerNib:[UINib nibWithNibName:[EmptyLabelTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[EmptyLabelTableViewCell reuseIdentifier]];
    
    __weak typeof(self) weakSelf = self;
    [self.myTableView addPullToRefreshWithActionHandler:^{
        weakSelf.currentPage = 0; // reset the page
        [weakSelf.timelinesArray removeAllObjects]; // remove all data
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
    
    [self getDataFromServer];
}

-(void)getDataFromServer{
    [self.view startLoader:YES disableUI:NO];
    [Timeline getTimelineWithAccessToken:ACCESS_TOKEN() andPageNumber:@(currentPage) success:^(RKObjectRequestOperation *operation, NSArray *resultsArray) {
        NSData *responseData = operation.HTTPRequestOperation.responseData;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
        int currentRow = (int)[self.timelinesArray count];
        [self.timelinesArray addObjectsFromArray:resultsArray];
        self.currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
        self.currentPage = currentPagination.nextPage;
        
        [self.view startLoader:NO disableUI:NO];
        if(currentRow == 0){
            self.isTableEmpty = self.timelinesArray.count == 0;
            [self.myTableView reloadData];
        }else{
            [self reloadTableView:currentRow];
        }

        
        [self.myTableView.pullToRefreshView stopAnimating];
        [self.myTableView.infiniteScrollingView stopAnimating];

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        WRITE_LOG(error.localizedDescription);
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
        }

        [self.myTableView.pullToRefreshView stopAnimating];
        [self.myTableView.infiniteScrollingView stopAnimating];
        [self.view startLoader:NO disableUI:NO];
    }];
}

- (void)reloadTableView:(int)startingRow;
{
    // the last row after added new items
    int endingRow = (int)[self.timelinesArray count];
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSMutableIndexSet *sections = [NSMutableIndexSet new];
    for (; startingRow < endingRow; startingRow++) {
        [sections addIndex:startingRow];
        [indexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:startingRow]];
    }
    
//    [self.myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.myTableView insertSections:sections withRowAnimation:UITableViewRowAnimationFade];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(isTableEmpty){
        return 1;
    }
    return self.timelinesArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(isTableEmpty){
        return 57.0;
    }
    Timeline *currentTimeline = [timelinesArray objectAtIndex:indexPath.section];
    if([[currentTimeline valueForKey:@"timeline_type"] isEqualToString:@"Post"]){
        if(IS_IPAD){
            return [[UIScreen mainScreen] bounds].size.width / 2;
        }
        Timeline *currentTimeline = [timelinesArray objectAtIndex:indexPath.section];
        Clip *cl = currentTimeline.timeline_clip;
        ProfileVideoTableViewCell *aCell = (ProfileVideoTableViewCell *) [tableView dequeueReusableCellWithIdentifier:[ProfileVideoTableViewCell reuseIdentifier]];
        [aCell fillWithClip:cl];
        return [aCell cellHeight];
        
    }else if([[currentTimeline valueForKey:@"timeline_type"] isEqualToString:@"Playlist"]){
        return 200.0;
    }else{
        if(IS_IPAD){
            return [[UIScreen mainScreen] bounds].size.width / 3;
        }
        return 190.0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(isTableEmpty){
        return 0;
    }
    return 40.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isTableEmpty){
        EmptyLabelTableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:[EmptyLabelTableViewCell reuseIdentifier]];
        
        emptyCell.emptyLabel.text = @"Timeline tidak ditemukan";
        return emptyCell;
    }
    
    Timeline *currentTimeline = [timelinesArray objectAtIndex:indexPath.section];
    UITableViewCell *videoCell;
    if([[currentTimeline valueForKey:@"timeline_type"] isEqualToString:@"Post"]){

        Clip *cl = currentTimeline.timeline_clip;
        videoCell = (ProfileVideoTableViewCell *) [tableView dequeueReusableCellWithIdentifier:[ProfileVideoTableViewCell reuseIdentifier]];
        [(ProfileVideoTableViewCell *)videoCell setDelegate:self];
        [(ProfileVideoTableViewCell *)videoCell fillWithClip:cl];
        return videoCell;
        /*
        videoCell = (TimelineVideoTableViewCell *) [tableView dequeueReusableCellWithIdentifier:[TimelineVideoTableViewCell reuseIdentifier]];
        [(TimelineVideoTableViewCell *)videoCell setDelegate:self];
        [(TimelineVideoTableViewCell *)videoCell fillWithTimeline:currentTimeline];
        return videoCell;
         */
    }else if([[currentTimeline valueForKey:@"timeline_type"] isEqualToString:@"User"]){
        
        videoCell = (TimelineUserTableViewCell *) [tableView dequeueReusableCellWithIdentifier:[TimelineUserTableViewCell reuseIdentifier]];
        [(TimelineUserTableViewCell *)videoCell fillWithTimeline:currentTimeline];
        return videoCell;
    }else if([[currentTimeline valueForKey:@"timeline_type"] isEqualToString:@"Playlist"]){
        
        videoCell = (TimelinePlaylistTableViewCell *) [tableView dequeueReusableCellWithIdentifier:[TimelinePlaylistTableViewCell reuseIdentifier]];
        
        [(TimelinePlaylistTableViewCell *)videoCell setDelegate:self];
        [(TimelinePlaylistTableViewCell *)videoCell setItemWithPlayList:currentTimeline.timeline_playlist];
        return videoCell;
    }
    return videoCell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(isTableEmpty)
        return nil;
    TimelineCustomHeader * headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TimelineCustomHeader"];
    
    Timeline *obj = [timelinesArray objectAtIndex:section];
    [headerView fillWithTimeline:obj];
    return headerView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isTableEmpty) {
        return;
    }
    Timeline *currentTimeline = [timelinesArray objectAtIndex:indexPath.section];
    if([currentTimeline.timeline_type isEqualToString:@"Post"]){
        VideoDetailViewController *videoVC = [[VideoDetailViewController alloc]initWithClip:currentTimeline.timeline_clip];
        self.currentTitle = currentTimeline.timeline_clip.clip_content;
        [self.navigationController pushViewController:videoVC animated:YES];
        
    }else if([currentTimeline.timeline_type isEqualToString:@"User"]){
        ProfileViewController *vc = [[ProfileViewController alloc] initWithUser:currentTimeline.timeline_user];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isTableEmpty){
        self.myTableView.backgroundColor = [UIColor clearColor];
        self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else{
        self.myTableView.backgroundColor = [UIColor whiteColor];
        self.myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }

    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - ProfileTableViewCellDelegate
-(void)profileVideoTableViewCell:(ProfileVideoTableViewCell *)cell detailButtonTappedForClip:(Clip *)aClip{
    self.currentClip = aClip;
    [self moreButtonTappedForClip:self.currentClip];
}

#pragma mark - TimelineTableViewCellDelegate
-(void)didSelectClip:(Clip *)aClip{
    [self.navigationController pushViewController:[[VideoDetailViewController alloc] initWithClip:aClip] animated:YES];
}

@end
