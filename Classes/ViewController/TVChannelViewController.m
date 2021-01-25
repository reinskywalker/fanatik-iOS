//
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/12/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "TVChannelViewController.h"
#import "TVChannelTableViewCell.h"
#import "TVChannelDetailViewController.h"

@interface TVChannelViewController ()

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *liveChannelsArray;
@property (nonatomic, assign) int currentPage;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *blankLabel;

@end

@implementation TVChannelViewController
@synthesize liveChannelsArray, currentPage;

-(instancetype)init{
    if(self =[super init]){
        self.liveChannelsArray = [NSMutableArray new];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentPageCode = MenuPageTVChannel;
    
    [self.view setBackgroundColor:HEXCOLOR(0xf0f4f4ff)];
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.myTableView registerNib:[UINib nibWithNibName:[TVChannelTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([TVChannelTableViewCell class])];
    
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    __weak typeof(self) weakSelf = self;
    [self.myTableView addPullToRefreshWithActionHandler:^{
        weakSelf.currentPage = 0; // reset the page
        [weakSelf.liveChannelsArray removeAllObjects]; // remove all data
        [weakSelf.myTableView reloadData]; // before load new content, clear the existing table list
        [weakSelf getLiveFromServer]; // load new data
        [weakSelf.myTableView.pullToRefreshView stopAnimating]; // clear the animation
    }];
    
    [self.myTableView addInfiniteScrollingWithActionHandler:^{
        if(weakSelf.currentPage && weakSelf.currentPage > 0){
            [weakSelf getLiveFromServer];
        }else{
            weakSelf.myTableView.showsInfiniteScrolling = NO;
            [weakSelf.myTableView.pullToRefreshView stopAnimating];
            [weakSelf.myTableView.infiniteScrollingView stopAnimating];
            
        }
    }];

    [self getLiveFromServer];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getLiveFromServer{
    [self.view startLoader:YES disableUI:YES];
    [Live getAllLivewithAccessToken:ACCESS_TOKEN() andPageNumber:@(currentPage) success:^(RKObjectRequestOperation *operation, NSArray *objectArray) {
        NSData *responseData = operation.HTTPRequestOperation.responseData;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
        int currentRow = (int)[self.liveChannelsArray count];
        [self.liveChannelsArray addObjectsFromArray:objectArray];
        self.blankLabel.hidden = self.liveChannelsArray.count>0?YES:NO;
        
        PaginationModel *currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
        self.currentPage = currentPagination.nextPage;
        
        [self.view startLoader:NO disableUI:NO];
        [self reloadTableView:currentRow];
        [self.myTableView.pullToRefreshView stopAnimating];
        [self.myTableView.infiniteScrollingView stopAnimating];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        WRITE_LOG(error.localizedDescription);
        [self.myTableView.pullToRefreshView stopAnimating];
        [self.myTableView.infiniteScrollingView stopAnimating];
        [self.view startLoader:NO disableUI:NO];
    }];
}

- (void)reloadTableView:(int)startingRow;
{
    // the last row after added new items
    int endingRow = (int)[self.liveChannelsArray count];
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (; startingRow < endingRow; startingRow++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:startingRow inSection:0]];
    }
    
        [self.myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(IS_IPAD)
        return 400;
    return 224.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.liveChannelsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // example using a custom UITableViewCell
    TVChannelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TVChannelTableViewCell reuseIdentifier]];
    Live *aLive = [self.liveChannelsArray objectAtIndex:indexPath.row];
    [cell setCellWithLive:aLive];
    return cell;
}

- (void)configureCell:(SideMenuCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    RowMenu *info = [_fetchedResultsController objectAtIndexPath:indexPath];
//    [cell setCellWithRowMenu:info];

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Live *aLive = [self.liveChannelsArray objectAtIndex:indexPath.row];
    if([aLive.live_enable boolValue]){
        TVChannelDetailViewController *vc = [[TVChannelDetailViewController alloc] initWithLive:aLive];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self showAlertWithMessage:@"Konten video sedang tidak aktif atau disable"];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end
