//
//  NotificationViewController.m
//  Fanatik
//
//  Created by Erick Martin on 4/27/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationTableViewCell.h"
#import "VideoDetailViewController.h"
#import "Like.h"
#import "Mention.h"

@interface NotificationViewController ()

@property (nonatomic, retain) NSMutableArray *notifArray;
@property(nonatomic, retain) PaginationModel *currentPagination;
@property (nonatomic, assign) int currentPage;
@end

@implementation NotificationViewController

@synthesize currentPage, currentPagination;

-(id)init{
    if(self = [super init]){
        self.notifArray = [NSMutableArray array];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.myTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [TheAppDelegate slidingViewController].title = @"Notifications";
    self.currentPageCode = MenuPageNotification;
    // Do any additional setup after loading the view from its nib.
    
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.myTableView registerNib:[UINib nibWithNibName:[NotificationTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([NotificationTableViewCell class])];
    [self.myTableView registerNib:[UINib nibWithNibName:[EmptyLabelTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[EmptyLabelTableViewCell reuseIdentifier]];
    
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    __weak typeof(self) weakSelf = self;
    [self.myTableView addPullToRefreshWithActionHandler:^{
        weakSelf.currentPage = 0; // reset the page
        [weakSelf.notifArray removeAllObjects]; // remove all data
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

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getDataFromServer{
    [self.view startLoader:YES disableUI:NO];
    [Notification getNotificationWithPageNumber:@(currentPage) withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation * _Nonnull operation, NSArray * _Nonnull resultArray) {
        NSData *responseData = operation.HTTPRequestOperation.responseData;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
        int currentRow = (int)[self.notifArray count];
        [self.notifArray addObjectsFromArray:resultArray];
        self.currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
        self.currentPage = currentPagination.nextPage;
        
        [self.view startLoader:NO disableUI:NO];
        if(currentRow == 0){
            self.isTableEmpty = self.notifArray.count == 0;
            [self.myTableView reloadData];
        }else{
            [self reloadTableView:currentRow];
        }
        
        [self.myTableView.pullToRefreshView stopAnimating];
        [self.myTableView.infiniteScrollingView stopAnimating];
    } failure:^(RKObjectRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
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
    int endingRow = (int)[self.notifArray count];
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSMutableIndexSet *sections = [NSMutableIndexSet new];
    for (; startingRow < endingRow; startingRow++) {
        [sections addIndex:startingRow];
        [indexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:startingRow]];
    }
    
    //    [self.myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.myTableView insertSections:sections withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isTableEmpty){
        return 57.0;
    }
    
    NotificationTableViewCell *cell = (NotificationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[NotificationTableViewCell reuseIdentifier]];
    Notification *aNotif = [self.notifArray objectAtIndex:indexPath.row];
    [cell fillCellWithNotif:aNotif];
    [cell.contentView layoutIfNeeded];
    
    if([cell cellHeight] <= 55.0)
        return 55.0;
    
    return [cell cellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.isTableEmpty){
        return 1;
    }
    return [self.notifArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isTableEmpty){
        EmptyLabelTableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:[EmptyLabelTableViewCell reuseIdentifier]];
        return emptyCell;
    }
    
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NotificationTableViewCell reuseIdentifier]];
    Notification *aNotif = [self.notifArray objectAtIndex:indexPath.row];
    [cell fillCellWithNotif:aNotif];
    cell.contentView.backgroundColor = aNotif.notification_read_at?[UIColor whiteColor]:HEXCOLOR(0xFFFAECFF);
    [cell.contentView layoutIfNeeded];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.isTableEmpty)
        return;
    
    Notification *aNotif = [self.notifArray objectAtIndex:indexPath.row];
    
    UIViewController *vc = nil;
    
    if(aNotif.notifType == NotifTypeLikeClip){
        vc = [[VideoDetailViewController alloc] initWithClip:aNotif.notification_like.like_clip];
    }else if(aNotif.notifType == NotifTypeNewClipUploaded){
        vc = [[VideoDetailViewController alloc] initWithClip:aNotif.notification_clip];
    }else if(aNotif.notifType == NotifTypeFollowUser){
        vc = [[ProfileViewController alloc] initWithUser:aNotif.notification_user];
    }else if(aNotif.notifType == NotifTypeCommentClip){
        vc = [[VideoDetailViewController alloc] initWithClip:aNotif.notification_comment.comment_clip];
    }else if(aNotif.notifType == NotifTypeCommentEvent){
        vc = [[EventDetailViewController alloc] initWithEvent:aNotif.notification_comment.comment_event];
    }else if(aNotif.notifType == NotifTypeMentionClip){
        vc = [[VideoDetailViewController alloc] initWithClip:aNotif.notification_mention.mention_comment.comment_clip];
    }else if(aNotif.notifType == NotifTypeMentionTVChannel){
        vc = [[TVChannelDetailViewController alloc] initWithLive:aNotif.notification_mention.mention_comment.comment_live];
    }
    
    if(vc){
        [Notification readNotificationWithNotifID:aNotif.notification_id withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation * _Nonnull operation, RKMappingResult * _Nonnull result) {
            NSLog(@"Read notification success");
            return;
        } failure:^(RKObjectRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            WRITE_LOG(error.localizedDescription);
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
            }
        }];
        
        aNotif.notification_read_at = [NSDate date];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
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

@end
