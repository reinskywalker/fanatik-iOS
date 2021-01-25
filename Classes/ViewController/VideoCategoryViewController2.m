//
//  VideoCategoryViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/13/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "VideoCategoryViewController.h"
#import "SearchClipTableViewCell.h"

@interface VideoCategoryViewController ()<UITableViewDataSource, UITableViewDelegate, SearchClipTableViewCellDelegate>

@property(nonatomic, retain) NSMutableArray *categoriesArray;
@property(nonatomic, retain) NSMutableArray *clipsArray;
@property(nonatomic, retain) NSMutableArray *categoryNamesArray;
@property(nonatomic, retain) ClipCategory *currentCategory;
@property(nonatomic, copy) NSString *currentID;
@property(nonatomic, assign) int visibleItems;
@property(nonatomic, assign) NSInteger selectedMenuIndex;
@property(nonatomic, copy) NSString *currentCategoryID;
@property (nonatomic, assign) int currentPage;
@property(nonatomic, assign) BOOL isReloading;

@end

@implementation VideoCategoryViewController
@synthesize categoriesArray, currentCategory, currentID, categoryNamesArray, visibleItems, horizontalMenu;
@synthesize selectedMenuIndex, currentCategoryID, currentPage, clipsArray;
-(id)initWithId:(NSString *)objID{
    if(self = [super init]){
        self.categoriesArray = [NSMutableArray new];
        self.categoryNamesArray = [NSMutableArray new];
        self.clipsArray = [NSMutableArray new];
        self.currentCategoryID = objID;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    
}

-(void)configureView{
    self.horizontalMenu.delegate = self;
    self.horizontalMenu.dataSource = self;
    
    self.horizontalMenu.alignment = SwipeViewAlignmentEdge;
    self.horizontalMenu.pagingEnabled = NO;
    self.horizontalMenu.itemsPerPage = visibleItems = 3;
    self.horizontalMenu.truncateFinalPage = YES;
    self.selectedMenuIndex = 0;
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.myTableView registerNib:[UINib nibWithNibName:[SearchClipTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[SearchClipTableViewCell reuseIdentifier]];
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    __weak typeof(self) weakSelf = self;
    [self.myTableView addPullToRefreshWithActionHandler:^{
       
        weakSelf.currentPage = 0;
        [weakSelf.clipsArray removeAllObjects];
        [weakSelf.myTableView reloadData]; // before load new content, clear the existing table list
        [weakSelf getClipForCategory:weakSelf.currentCategory]; // load new data
        [weakSelf.myTableView.pullToRefreshView stopAnimating]; // clear the animation
        
        // once refresh, allow the infinite scroll again
        weakSelf.myTableView.showsInfiniteScrolling = YES;
        
    }];
    
    // load more content when scroll to the bottom most
    [self.myTableView addInfiniteScrollingWithActionHandler:^{
        
        if(weakSelf.currentPage && weakSelf.currentPage > 0){
            [weakSelf getClipForCategory:weakSelf.currentCategory];
        }else{
            weakSelf.myTableView.showsInfiniteScrolling = NO;
            [weakSelf.myTableView.pullToRefreshView stopAnimating];
            [weakSelf.myTableView.infiniteScrollingView stopAnimating];
            
        }
    }];
    
    
    [self getCategoriesFromServer];
}

- (void)dealloc
{
    self.horizontalMenu.delegate = nil;
    self.horizontalMenu.dataSource = nil;
    self.myTableView.delegate = nil;
    self.myTableView.dataSource = nil;
}

-(void)getCategoriesFromServer{
    [ClipCategory getAllClipCategoriesWithAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *resultArray) {
        [self.categoriesArray addObjectsFromArray:resultArray];
        
        [self reloadHorizontalMenu];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
        }
    }];
}

-(void)getClipForCategory:(ClipCategory *)cat{
    [self.view startLoader:YES disableUI:NO];
    [ClipCategory getClipCategoryWithId:cat.clip_category_id pageNumber:@(currentPage) andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *resultArray) {
        
        
        NSData *responseData = operation.HTTPRequestOperation.responseData;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
        int currentRow = (int)[self.clipsArray count];
        [self.clipsArray addObjectsFromArray:resultArray];
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
        [self.view startLoader:NO disableUI:NO];
        

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error find clips");
        [self.view startLoader: NO disableUI:NO];
        if(operation.HTTPRequestOperation.responseData){
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


-(void)reloadHorizontalMenu{
    NSInteger idx = 0;
    for(ClipCategory *cat in categoriesArray){
        [categoryNamesArray addObject:cat.clip_category_name];
        
        if([cat.clip_category_id isEqualToString:currentCategoryID]){
            self.selectedMenuIndex = idx;
            self.currentCategory = cat;
            if(categoryNamesArray.count > visibleItems)
                self.horizontalMenu.currentItemIndex = idx;
        }
        idx++;
    }
    
    [self.horizontalMenu reloadData];
    [self getClipForCategory:currentCategory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark SwipeHorizontalMenu methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    //return the total number of items in the carousel
    return [categoryNamesArray count];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ceilf(horizontalMenu.frame.size.width)/visibleItems, horizontalMenu.frame.size.height)];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.backgroundColor = [UIColor clearColor];
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:InterfaceStr(@"default_font_bold") size:12.0];
        
        label.tag = 1;
        [view addSubview:label];
        
        UIView *sideSeparator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.frame)-1, 0, 1.0, CGRectGetHeight(view.frame))];
        sideSeparator.backgroundColor = HEXCOLOR(0xD6D6D6FF);
        
//        UIView *bottomSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(horizontalMenu.frame)-1, CGRectGetWidth(view.frame), 1.0)];
//        bottomSeparator.backgroundColor = HEXCOLOR(0xD6D6D6FF);
        
//        if(index < visibleItems-1)
            [view addSubview:sideSeparator];
//        [view addSubview:bottomSeparator];
        
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    
    label.text =  [categoryNamesArray[index] uppercaseString];
    label.textColor = index == selectedMenuIndex ? HEXCOLOR(0x333333FF) : HEXCOLOR(0x3333337F);
    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return CGSizeMake(ceilf(horizontalMenu.frame.size.width)/visibleItems, horizontalMenu.frame.size.height);
}

-(void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index{
    self.selectedMenuIndex = index;
    self.currentCategory = categoriesArray[index];
    self.currentCategoryID = currentCategory.clip_category_id;

    //
    self.currentPage = 0;
    [self.clipsArray removeAllObjects];
    [self.myTableView reloadData]; // before load new content, clear the existing table list
    [self getClipForCategory:self.currentCategory]; // load new data
    [self.myTableView.pullToRefreshView stopAnimating]; // clear the animation
    
    // once refresh, allow the infinite scroll again
    
    //
    
    if(categoryNamesArray.count > visibleItems)
        self.horizontalMenu.currentItemIndex = index;
    [self.horizontalMenu reloadData];
}

#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.clipsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchClipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SearchClipTableViewCell reuseIdentifier]];
    [cell fillWithClip:[self.clipsArray objectAtIndex:indexPath.row]];
    cell.delegate = self;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Clip *theClip = [self.clipsArray objectAtIndex:indexPath.row];
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
-(void)searchClipTableViewCell:(SearchClipTableViewCell *)cell moreButtonDidTapForClip:(Clip *)clip{
    self.currentClip = clip;
    [self moreButtonTappedForClip:clip];
}
@end
