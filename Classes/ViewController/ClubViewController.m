//
//  ClubViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/13/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ClubViewController.h"
#import "ClubListTableViewCell.h"
#import "MZFormSheetController.h"
#import "ClubJoinDialogViewController.h"
#import "ThreadListTableViewCell.h"
#import "ThreadDetailsViewController.h"

@interface ClubViewController ()<UITableViewDataSource, UITableViewDelegate, ClubListTableViewCellDelegate, UIAlertViewDelegate, ClubJoinDialogViewControllerDelegate>

@property(nonatomic, retain) NSMutableArray *myClubsArray;
@property(nonatomic, retain) NSMutableArray *allClubsArray;
@property(nonatomic, retain) NSMutableArray *myThreadsArray;
@property(nonatomic, copy) NSString *currentID;
@property(nonatomic, assign) int visibleItems;
@property(nonatomic, assign) NSInteger selectedMenuIndex;
@property (nonatomic, assign) int allClubsCurrentPage;
@property (nonatomic, assign) int myClubsCurrentPage;
@property (nonatomic, assign) int myThreadsCurrentPage;
@property (nonatomic, assign) NSUInteger currentArrayIndex;
@property (nonatomic, assign) BOOL shouldRequestData;

@end

@implementation ClubViewController
@synthesize currentID, visibleItems, horizontalMenu;
@synthesize selectedMenuIndex, myThreadsCurrentPage, myClubsCurrentPage, allClubsCurrentPage, myClubsArray, allClubsArray, myThreadsArray, currentArrayIndex, shouldRequestData, searchBar, searchBarHeightConstraint;

- (IBAction)loginTapped:(id)sender {
    [self presentViewController:[[HomeViewController alloc] initByPresenting] animated:YES completion:nil];
}

-(id)initWithId:(NSInteger)selectedMenu{
    if(self = [super init]){
        self.myClubsArray = [NSMutableArray array];
        self.allClubsArray = [NSMutableArray array];
        self.myThreadsArray = [NSMutableArray array];
        self.selectedMenuIndex = selectedMenu;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

-(void)reloadHorizontalView{
    [self.myTableView triggerPullToRefresh];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadHorizontalView];
}

-(void)configureView{
    searchBarHeightConstraint.constant = 0;
    [self.searchBar setTintColor:[UIColor whiteColor]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor grayColor]];
    
    self.currentPageCode = MenuPageClub;
    self.horizontalMenu.delegate = self;
    self.horizontalMenu.dataSource = self;
    self.horizontalMenu.alignment = SwipeViewAlignmentEdge;
    self.horizontalMenu.pagingEnabled = NO;
    self.horizontalMenu.itemsPerPage = visibleItems = 3;
    self.horizontalMenu.truncateFinalPage = YES;
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.myTableView registerNib:[UINib nibWithNibName:[ClubListTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[ClubListTableViewCell reuseIdentifier]];
    [self.myTableView registerNib:[UINib nibWithNibName:[ThreadListTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[ThreadListTableViewCell reuseIdentifier]];
    [self.myTableView registerNib:[UINib nibWithNibName:[EmptyLabelTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[EmptyLabelTableViewCell reuseIdentifier]];
    
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    __weak typeof(self) weakSelf = self;
    [self.myTableView addPullToRefreshWithActionHandler:^{
        if(weakSelf.selectedMenuIndex == 0){
            weakSelf.allClubsCurrentPage = 0;
            [weakSelf.allClubsArray removeAllObjects];
        }else if(weakSelf.selectedMenuIndex == 1){
            weakSelf.myClubsCurrentPage = 0;
            [weakSelf.myClubsArray removeAllObjects];
        }else{
            weakSelf.myThreadsCurrentPage = 0;
            [weakSelf.myThreadsArray removeAllObjects];
        }
        
        [weakSelf.myTableView reloadData]; // before load new content, clear the existing table list
        [weakSelf getDataFromServer];
      // load new data
        [weakSelf.myTableView.pullToRefreshView stopAnimating]; // clear the animation
        
        // once refresh, allow the infinite scroll again
        weakSelf.myTableView.showsInfiniteScrolling = YES;
        
    }];
    
    // load more content when scroll to the bottom most
    [self.myTableView addInfiniteScrollingWithActionHandler:^{
        int currentPage = weakSelf.selectedMenuIndex == 0 ? weakSelf.allClubsCurrentPage : weakSelf.selectedMenuIndex == 1 ? weakSelf.myClubsCurrentPage : weakSelf.myThreadsCurrentPage;
        if(currentPage && currentPage > 0){
          [weakSelf getDataFromServer];
        }else{
            weakSelf.myTableView.showsInfiniteScrolling = NO;
            [weakSelf.myTableView.pullToRefreshView stopAnimating];
            [weakSelf.myTableView.infiniteScrollingView stopAnimating];
            
        }
    }];
    [self.horizontalMenu reloadData];
}

- (void)dealloc
{
    self.horizontalMenu.delegate = nil;
    self.horizontalMenu.dataSource = nil;
    self.myTableView.delegate = nil;
    self.myTableView.dataSource = nil;
}

-(void)getDataFromServer{
    
    if (selectedMenuIndex == 0) {

        [self.view startLoader:YES disableUI:NO];
        
        _loginText.hidden = YES;
        _loginButton.hidden = YES;

        [self.myTableView.pullToRefreshView stopAnimating]; // clear the animation
        self.myTableView.showsInfiniteScrolling = YES;
        
        [Club searchClubWithSearchString:self.searchBar.text andPageNumber:@(allClubsCurrentPage) withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
            
            NSData *responseData = operation.HTTPRequestOperation.responseData;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:responseData
                                  options:NSJSONReadingMutableLeaves
                                  error:nil];
            
            int currentRow = (int)[self.allClubsArray count];
            [self.allClubsArray addObjectsFromArray:[result array]];
            PaginationModel *currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
            
            NSLog(@"pagination : %@", currentPagination);
            self.allClubsCurrentPage = currentPagination.nextPage;
            
            if(currentRow == 0){
                self.isTableEmpty = self.allClubsArray.count == 0;
                [self.myTableView reloadData];
            }else{
                [self reloadTableView:currentRow];
            }
            [self.myTableView startLoader:NO disableUI:NO];
            [self.myTableView.pullToRefreshView stopAnimating];
            [self.myTableView.infiniteScrollingView stopAnimating];
            [self.view startLoader:NO disableUI:NO];
            shouldRequestData = NO;
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self.myTableView startLoader:NO disableUI:NO];
            [self.myTableView.pullToRefreshView stopAnimating];
            [self.myTableView.infiniteScrollingView stopAnimating];
            
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
            }
        }];
        
    }else if (selectedMenuIndex == 1){
    
        _loginText.hidden = (BOOL)[User fetchLoginUser];
        _loginButton.hidden = (BOOL)[User fetchLoginUser];
        
        if([User fetchLoginUser]){
            
            [self.view startLoader:YES disableUI:NO];
            [self.myTableView.pullToRefreshView stopAnimating]; // clear the animation
            self.myTableView.showsInfiniteScrolling = YES;
            
            [Club getMyClubWithAccessToken:ACCESS_TOKEN() pageNumber:@(myClubsCurrentPage) success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                NSData *responseData = operation.HTTPRequestOperation.responseData;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
                
                int currentRow = (int)[self.myClubsArray count];
                [self.myClubsArray addObjectsFromArray:[result array]];
                PaginationModel *currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
                self.myClubsCurrentPage = currentPagination.nextPage;
                
                
                if(currentRow == 0){
                    self.isTableEmpty = self.myClubsArray.count == 0;
                    [self.myTableView reloadData];
                }else{
                    [self reloadTableView:currentRow];
                }
                [self.myTableView startLoader:NO disableUI:NO];
                [self.myTableView.pullToRefreshView stopAnimating];
                [self.myTableView.infiniteScrollingView stopAnimating];
                [self.view startLoader:NO disableUI:NO];
                shouldRequestData = NO;
                
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [self.view startLoader: NO disableUI:NO];
                [self.myTableView startLoader:NO disableUI:NO];
                [self.myTableView.pullToRefreshView stopAnimating];
                [self.myTableView.infiniteScrollingView stopAnimating];
                
                NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                }
            }];
        }
    }else{

        _loginText.hidden = (BOOL)[User fetchLoginUser];
        _loginButton.hidden = (BOOL)[User fetchLoginUser];
        
        if([User fetchLoginUser]){
            
            [self.view startLoader:YES disableUI:NO];
            [self.myTableView.pullToRefreshView stopAnimating]; // clear the animation
            self.myTableView.showsInfiniteScrolling = YES;
            
            [Thread getUserThreadsWithPageNumber:@(myThreadsCurrentPage) withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *threadsArray) {
                NSData *responseData = operation.HTTPRequestOperation.responseData;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
                
                int currentRow = (int)[self.myThreadsArray count];
                [self.myThreadsArray addObjectsFromArray:threadsArray];
                PaginationModel *currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
                self.myClubsCurrentPage = currentPagination.nextPage;
                
                
                if(currentRow == 0){
                    self.isTableEmpty = self.myThreadsArray.count == 0;
                    [self.myTableView reloadData];
                }else{
                    [self reloadTableView:currentRow];
                }
                [self.myTableView startLoader:NO disableUI:NO];
                [self.myTableView.pullToRefreshView stopAnimating];
                [self.myTableView.infiniteScrollingView stopAnimating];
                [self.view startLoader:NO disableUI:NO];
                shouldRequestData = NO;
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [self.view startLoader: NO disableUI:NO];
                [self.myTableView startLoader:NO disableUI:NO];
                [self.myTableView.pullToRefreshView stopAnimating];
                [self.myTableView.infiniteScrollingView stopAnimating];
                
                NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                }
            }];
        }
    }
}

- (void)reloadTableView:(int)startingRow;
{
    // the last row after added new items
    int endingRow = selectedMenuIndex == 0 ? (int)allClubsArray.count : selectedMenuIndex == 1 ? (int)myClubsArray.count : (int)myThreadsArray.count;
   
   
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (; startingRow < endingRow; startingRow++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:startingRow inSection:0]];
    }
    
    [self.myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
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
    return 3;
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
        label.textColor = index == selectedMenuIndex ? HEXCOLOR(0x333333FF) : HEXCOLOR(0x3333337F);
        label.tag = 1;
        [view addSubview:label];
        
        UIView *sideSeparator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.frame)-1, 0, 1.0, CGRectGetHeight(view.frame))];
        sideSeparator.backgroundColor = HEXCOLOR(0xD6D6D6FF);
        
      if(index < visibleItems-1)
            [view addSubview:sideSeparator];
        
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    
    if (index == 0) {
        label.text = @"ALL CLUBS";
    }else if(index == 1){
        label.text = @"MY CLUBS";
    }else{
        label.text = @"MY THREADS";
    }
    
    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return CGSizeMake(ceilf(horizontalMenu.frame.size.width)/visibleItems, horizontalMenu.frame.size.height);
}

-(void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index{
    self.selectedMenuIndex = index;
    self.isTableEmpty = NO;
    if(selectedMenuIndex > visibleItems)
        self.horizontalMenu.currentItemIndex = index;
    [self.horizontalMenu reloadData];
    switch (selectedMenuIndex) {
        case 0:{
            searchBarHeightConstraint.constant = 44.0;
            
            _loginText.hidden = YES;
            _loginButton.hidden = YES;
            
            if(allClubsArray.count == 0 || shouldRequestData){
                self.allClubsCurrentPage = 0;
                [self.allClubsArray removeAllObjects];
                [self.myTableView reloadData];
                [self getDataFromServer];
            }else{
                [self.myTableView reloadData];
            }
        }
            break;
        case 1:{
            
            searchBarHeightConstraint.constant = 0;
            
            _loginText.hidden = (BOOL)[User fetchLoginUser];
            _loginButton.hidden = (BOOL)[User fetchLoginUser];
        
            if(myClubsArray.count == 0 || shouldRequestData){
                self.myClubsCurrentPage = 0;
                [self.myClubsArray removeAllObjects];
                [self.myTableView reloadData];
                
                [self getDataFromServer];
            }else{
                [self.myTableView reloadData];
            }
        }
            break;
        case 2:{
            
            searchBarHeightConstraint.constant = 0;
            
            _loginText.hidden = (BOOL)[User fetchLoginUser];
            _loginButton.hidden = (BOOL)[User fetchLoginUser];
    
            if(myThreadsArray.count == 0 || shouldRequestData){
                self.myThreadsCurrentPage = 0;
                [self.myThreadsArray removeAllObjects];
                [self.myTableView reloadData];
        
                [self getDataFromServer];
            }else{
                [self.myTableView reloadData];
            }
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isTableEmpty){
        return 57.0;
    }
    return selectedMenuIndex == 2 ? 90.0 : 62.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.isTableEmpty){
        return 1;
    }
    return selectedMenuIndex == 0 ? allClubsArray.count : selectedMenuIndex == 1 ? myClubsArray.count : myThreadsArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isTableEmpty){
        EmptyLabelTableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:[EmptyLabelTableViewCell reuseIdentifier]];
        
        
        return emptyCell;
    }
    
    ClubListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[ClubListTableViewCell reuseIdentifier]];
    cell.delegate = self;
    Club *aClub = nil;
    if(self.selectedMenuIndex == 0){
        aClub = self.allClubsArray[indexPath.row];
    }else if (self.selectedMenuIndex == 1){
        aClub = self.myClubsArray[indexPath.row];
    }else{
        Thread *aThread = self.myThreadsArray[indexPath.row];
        ThreadListTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:[ThreadListTableViewCell reuseIdentifier]];
        [aCell fillWithThread:aThread];
        return aCell;
    }
    [cell fillWithClub:aClub];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isTableEmpty)
        return;
    Club *aClub;
    if(self.selectedMenuIndex == 0){
        aClub = self.allClubsArray[indexPath.row];
    }else if (self.selectedMenuIndex == 1){
        aClub = self.myClubsArray[indexPath.row];
    }else{
        Thread *aThread = self.myThreadsArray[indexPath.row];
        ThreadDetailsViewController *tVc = [[ThreadDetailsViewController alloc] initWithThread:aThread];
        [self.navigationController pushViewController:tVc animated:YES];
        return;
    }
    
    [searchBar resignFirstResponder];
    ClubProfileViewController *vc = [[ClubProfileViewController alloc] initWithClub:aClub];
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


#pragma mark - ClubTableViewCellDelegate
-(void)clubListTableViewCell:(ClubListTableViewCell *)cell joinClub:(Club *)obj{
    self.currentClub = obj;
    self.currentArrayIndex = selectedMenuIndex == 0 ? [allClubsArray indexOfObject:obj] : selectedMenuIndex == 1 ? [myClubsArray indexOfObject:obj] : [myThreadsArray indexOfObject:obj];
    [self.view startLoader:YES disableUI:NO];
    [Club joinClubWithID:self.currentClub.club_id andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result){
        [self.view startLoader:NO disableUI:NO];
        self.currentClub = [result firstObject];
        ClubJoinDialogViewController *vc = [[ClubJoinDialogViewController alloc] initWithClub:self.currentClub];
        
        vc.delegate = self;
        self.formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
        self.formSheet.shouldDismissOnBackgroundViewTap = YES;
        self.formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
        self.formSheet.cornerRadius = 5.0;
        float height = 260;
        self.formSheet.portraitTopInset = ([UIScreen mainScreen].bounds.size.height - height) / 2;
        self.formSheet.landscapeTopInset = 6.0;
        self.formSheet.presentedFormSheetSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width - 50, height);
        
        
        self.formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
            presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
        };
        
        
        self.shouldRequestData = YES;
        [self mz_presentFormSheetController:self.formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            switch (selectedMenuIndex) {
                case 0:{
                    [self.allClubsArray replaceObjectAtIndex:currentArrayIndex withObject:result.firstObject];
                }
                    break;
                case 1:{
                    [self.myClubsArray replaceObjectAtIndex:currentArrayIndex withObject:result.firstObject];
                }
                    break;
                case 2:{
                    [self.myThreadsArray replaceObjectAtIndex:currentArrayIndex withObject:result.firstObject];
                }
                    break;
                    
                default:
                    break;
            }
            
            [self.myTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:currentArrayIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self.view startLoader:NO disableUI:NO];
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
        }
    }];

}

-(void)clubListTableViewCell:(ClubListTableViewCell *)cell leaveClub:(Club *)obj{
    self.currentClub = obj;
    self.currentArrayIndex =  selectedMenuIndex == 0 ? [allClubsArray indexOfObject:obj] : selectedMenuIndex == 1 ? [myClubsArray indexOfObject:obj] : [myThreadsArray indexOfObject:obj];
    
    NSString *title = [NSString stringWithFormat:@"Tinggalkan %@",obj.club_name];
    NSString *msg = [NSString stringWithFormat:@"Kamu yakin mau meninggalkan %@ ? :'(", obj.club_name];

    [UIAlertView showWithTitle:title
                       message:msg
             cancelButtonTitle:@"Tidak"
             otherButtonTitles:@[@"Ya"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex != [alertView cancelButtonIndex]) {
                              [Club leaveClubWithID:self.currentClub.club_id withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                                  switch (selectedMenuIndex) {
                                      case 0:{
                                          [self.allClubsArray replaceObjectAtIndex:currentArrayIndex withObject:result.firstObject];
                                      }
                                          break;
                                      case 1:{
                                          [self.myClubsArray replaceObjectAtIndex:currentArrayIndex withObject:result.firstObject];
                                      }
                                          break;
                                      case 2:{
                                          [self.myThreadsArray replaceObjectAtIndex:currentArrayIndex withObject:result.firstObject];
                                      }
                                          break;
                                          
                                      default:
                                          break;
                                  }
                                  self.shouldRequestData = YES;
                                  [self.myTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:currentArrayIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark - ClubJoinMessageDelegate
-(void)dialogDidClose:(Club *)currClub{
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        ClubProfileViewController *vc = [[ClubProfileViewController alloc] initWithClub:currClub];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] == 0)
    {
        [self.searchBar performSelector:@selector(resignFirstResponder)
                        withObject:nil
                        afterDelay:0];
        [self.allClubsArray removeAllObjects];
        self.allClubsCurrentPage = 0;
        self.myTableView.showsInfiniteScrolling = YES;
        [self getDataFromServer];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [searchBar resignFirstResponder];
    
    [self.view startLoader:YES disableUI:NO];
    
    [self.allClubsArray removeAllObjects];
    self.allClubsCurrentPage = 0;
    [self getDataFromServer];
}

@end
