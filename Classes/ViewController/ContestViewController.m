//
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/12/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ContestViewController.h"
#import "ContestTableViewCell.h"
#import "ContestDetailViewController.h"

@implementation ContestViewController
@synthesize contestArray, currentPage;

-(id)init{
    if(self =[super init]){
        self.contestArray = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentPageCode = MenuPageContest;
    
    [self.view setBackgroundColor:HEXCOLOR(0xf0f4f4ff)];
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.myTableView registerNib:[UINib nibWithNibName:[ContestTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([ContestTableViewCell class])];
    [self.myTableView registerNib:[UINib nibWithNibName:[EmptyLabelTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[EmptyLabelTableViewCell reuseIdentifier]];
    
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    __weak typeof(self) weakSelf = self;
    [self.myTableView addPullToRefreshWithActionHandler:^{
        weakSelf.currentPage = 0; // reset the page
        [weakSelf.contestArray removeAllObjects]; // remove all data
        [weakSelf.myTableView reloadData]; // before load new content, clear the existing table list
        [weakSelf getContestFromServer]; // load new data
        [weakSelf.myTableView.pullToRefreshView stopAnimating]; // clear the animation
    }];
    
    [self.myTableView addInfiniteScrollingWithActionHandler:^{
        if(weakSelf.currentPage && weakSelf.currentPage > 0){
            [weakSelf getContestFromServer];
        }else{
            weakSelf.myTableView.showsInfiniteScrolling = NO;
            [weakSelf.myTableView.pullToRefreshView stopAnimating];
            [weakSelf.myTableView.infiniteScrollingView stopAnimating];
            
        }
    }];

    [self getContestFromServer];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getContestFromServer{
    [self.view startLoader:YES disableUI:YES];
    
    [Contest getAllContestsWithAccessToken:ACCESS_TOKEN() andPageNum:@(currentPage) success:^(RKObjectRequestOperation *operation, NSArray *resultsArray) {
        NSData *responseData = operation.HTTPRequestOperation.responseData;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
        int currentRow = (int)[self.contestArray count];
        [self.contestArray addObjectsFromArray:resultsArray];
        PaginationModel *currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
        self.currentPage = currentPagination.nextPage;
        
        [self.view startLoader:NO disableUI:NO];
        if(currentRow == 0){
            self.isTableEmpty = self.contestArray.count == 0;
            [self.myTableView reloadData];
        }else{
            
            [self reloadTableView:currentRow];
        }
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
    int endingRow = (int)[self.contestArray count];
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (; startingRow < endingRow; startingRow++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:startingRow inSection:0]];
    }
    
        [self.myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isTableEmpty){
        return 57.0;
    }

    return 145.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.isTableEmpty){
        return 1;
    }
    return [self.contestArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isTableEmpty){
        EmptyLabelTableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:[EmptyLabelTableViewCell reuseIdentifier]];
        return emptyCell;
    }
    
    ContestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[ContestTableViewCell reuseIdentifier]];
    Contest *aContest = [self.contestArray objectAtIndex:indexPath.row];
    [cell setItem:aContest];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.isTableEmpty)
        return;
    
    Contest *aContest = [self.contestArray objectAtIndex:indexPath.row];
    ContestDetailViewController *vc = [[ContestDetailViewController alloc] initWithContest:aContest];
    [self.navigationController pushViewController:vc animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    ContestTableViewCell *cell = (ContestTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.selectedStyleView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
}

-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    ContestTableViewCell *cell = (ContestTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.selectedStyleView.backgroundColor = [UIColor clearColor];
    
}

@end
