//
//  MoreVideosViewController.m
//  Fanatik
//
//  Created by Erick Martin on 5/22/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "MoreVideosViewController.h"

@interface MoreVideosViewController ()

@property (nonatomic, retain) IBOutlet UITableView *moreTableView;
@property (nonatomic, retain) NSMutableArray *clipsArray;
@property (nonatomic, retain) ClipGroup *currentClipGroup;
@property (nonatomic, retain) Contest *currentContest;

@end

@implementation MoreVideosViewController

@synthesize clipsArray, moreTableView, currentClipGroup, currentContest, currentPage;
@synthesize tableHeaderView, contestNameLabel;

-(id)initWithClipGroup:(ClipGroup *)clipGroup{
    if(self = [super init]){
        self.clipsArray = [NSMutableArray array];
        self.currentClipGroup = clipGroup;
    }
    return self;
}

-(id)initWithContest:(Contest *)contest{
    if(self = [super init]){
        self.clipsArray = [NSMutableArray array];
        self.currentContest = contest;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib

    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self configureView];
}

-(void)configureView{
    
    self.moreTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.navigationController.navigationBar.barTintColor = [TheInterfaceManager headerBGColor];
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:nil imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
    [lButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    if(currentClipGroup){
        self.navigationItem.title = self.currentClipGroup.clip_group_name;
    }else if(currentContest){
        self.navigationItem.title = @"Contest Videos";
        self.contestNameLabel.text = currentContest.contest_name;
        
        CGSize fitSize = [self.contestNameLabel sizeThatFits:self.contestNameLabel.frame.size];
        CGRect tableHeaderViewFrame = self.tableHeaderView.frame;
        
        CGFloat maxHeight = 44.0;
        maxHeight = MAX(maxHeight, maxHeight + fitSize.height);
        tableHeaderViewFrame.size.height = maxHeight;
        tableHeaderView.frame = tableHeaderViewFrame;
        self.moreTableView.tableHeaderView = tableHeaderView;
    }
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:InterfaceStr(@"default_font_bold") size:17]}];

    [self.moreTableView registerNib:[UINib nibWithNibName:[SearchClipTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[SearchClipTableViewCell reuseIdentifier]];
    
    self.moreTableView.delegate = self;
    self.moreTableView.dataSource = self;
    __weak typeof(self) weakSelf = self;

    // refresh new data when pull the table list
    [self.moreTableView addPullToRefreshWithActionHandler:^{
        weakSelf.currentPage = 0;
        [weakSelf.clipsArray removeAllObjects]; // remove all data
        [weakSelf.moreTableView reloadData]; // before load new content, clear the existing table list
        if(weakSelf.currentClipGroup)
            [weakSelf getClipsFromServerWithClipGroup];
        else if(weakSelf.currentContest)
            [weakSelf getClipsFromServerWithContest];
        
        [weakSelf.moreTableView.pullToRefreshView stopAnimating]; // clear the animation
        
        // once refresh, allow the infinite scroll again
        weakSelf.moreTableView.showsInfiniteScrolling = YES;
    }];
    
    [self.moreTableView addInfiniteScrollingWithActionHandler:^{
        if(weakSelf.currentPage && weakSelf.currentPage > 0){
            if(weakSelf.currentClipGroup)
                [weakSelf getClipsFromServerWithClipGroup];
            else if(weakSelf.currentContest)
                [weakSelf getClipsFromServerWithContest];
        }else{
            weakSelf.moreTableView.showsInfiniteScrolling = NO;
            [weakSelf.moreTableView.pullToRefreshView stopAnimating];
            [weakSelf.moreTableView.infiniteScrollingView stopAnimating];
            
        }
    }];
   
    if(self.currentClipGroup)
        [self getClipsFromServerWithClipGroup];
    else if(self.currentContest)
        [self getClipsFromServerWithContest];
    
}

-(void)getClipsFromServerWithContest{
    [self.view startLoader:YES disableUI:YES];
    
    [Clip getContestClipsWithContestID:self.currentContest.contest_id withAccessToken:ACCESS_TOKEN() andPageNum:@(currentPage) success:^(RKObjectRequestOperation *operation, NSArray *resultsArray) {
        NSData *responseData = operation.HTTPRequestOperation.responseData;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
        int currentRow = (int)[self.clipsArray count];
        [self.clipsArray addObjectsFromArray:resultsArray];
        PaginationModel *currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
        self.currentPage = currentPagination.nextPage;
        
        [self.view startLoader:NO disableUI:NO];
        [self reloadTableView:currentRow];
        [self.moreTableView.pullToRefreshView stopAnimating];
        [self.moreTableView.infiniteScrollingView stopAnimating];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        WRITE_LOG(error.localizedDescription);
        [self.moreTableView.pullToRefreshView stopAnimating];
        [self.moreTableView.infiniteScrollingView stopAnimating];
        [self.view startLoader:NO disableUI:NO];
    }];
    
    
}

-(void)getClipsFromServerWithClipGroup{
    [self.view startLoader:YES disableUI:NO];
    
    [ClipGroup getClipsWithClipGroupId:(NSString *)currentClipGroup.clip_group_id andAccessToken:ACCESS_TOKEN() andPageNum:@(currentPage) success:^(RKObjectRequestOperation *operation, ClipGroup *clipGroup) {
        
        NSData *responseData = operation.HTTPRequestOperation.responseData;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
        int currentRow = (int)[self.clipsArray count];
        [self.clipsArray addObjectsFromArray:[clipGroup.clip_group_clips array]];
        PaginationModel *currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
        self.currentPage = currentPagination.nextPage;
        
        [self.view startLoader:NO disableUI:NO];
        [self reloadTableView:currentRow];
        [self.moreTableView.pullToRefreshView stopAnimating];
        [self.moreTableView.infiniteScrollingView stopAnimating];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        WRITE_LOG(error.localizedDescription);
        [self.moreTableView.pullToRefreshView stopAnimating];
        [self.moreTableView.infiniteScrollingView stopAnimating];
        [self.view startLoader:NO disableUI:NO];
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
    
    [self.moreTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
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
    [cell fillWithClip:[clipsArray objectAtIndex:indexPath.row]];
    cell.delegate = self;
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Clip *theClip = [clipsArray objectAtIndex:indexPath.row];
    VideoDetailViewController *vc = [[VideoDetailViewController alloc] initWithClip:theClip];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - CusctomCell Delegate
-(void)moreButtonDidTapForClip:(Clip *)clip{
    self.currentClip = clip;
    [self moreButtonTappedForClip:clip];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
