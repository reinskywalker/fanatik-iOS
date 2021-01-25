//
//  ThreadDetailsViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/18/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ThreadDetailsViewController.h"
#import "PostDialogViewController.h"
#import "ThreadCommentTableViewCell.h"
#import "CreateThreadViewController.h"
#import "ImageDetailViewController.h"
@interface ThreadDetailsViewController ()<UITableViewDataSource, UITableViewDelegate, PostDialogViewControllerDelegate, ThreadCommentTableViewCellDelegate, IBActionSheetDelegate, UIAlertViewDelegate>{
    BOOL isReloading;
    BOOL isPagingShown;
    
}

@property (strong, nonatomic) IBOutlet UIView *bottomButtonContainerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoContainerHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *detailHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomEdgeConstraint;
@property (nonatomic, retain) PaginationModel *currentPagination;
@property (nonatomic, retain) NSMutableArray *commentsArray;
@property (nonatomic, retain) ThreadComment *currentComment;

@property (nonatomic, strong) NSLayoutConstraint *constraintYThreadInfoContainer;

@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, copy) NSString *currentThreadId;
@property (nonatomic, retain) UIRefreshControl *refreshControl;

- (IBAction)threadImageTapped:(id)sender;

@end

@implementation ThreadDetailsViewController
@synthesize currentThread, commentButton, likeButton, shareButton, pagingButton, commentsArray, currentComment, currentPagination, paginationView, pagesSwipeView, bottomHeightConst, currentThreadId, refreshControl;

-(id)initWithThreadId:(NSString *)threadId{
    if(self=[super init]){
        self.currentThreadId = threadId;
        self.commentsArray = [NSMutableArray new];
        self.currentPagination = [[PaginationModel alloc]init];
    }
    return self;
}

-(id)initWithThread:(Thread *)obj{
    if(self=[super init]){
        self.currentThread = obj;
        self.commentsArray = [NSMutableArray new];
        self.currentPagination = [[PaginationModel alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPageCode = MenuPageThreadDetail;
    [self configureView];
    [self setupThreadInfo];
    [self.myTableView registerNib:[UINib nibWithNibName:[ThreadCommentTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([ThreadCommentTableViewCell class])];
    
    [self.myTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(pullToRefreshTable) forControlEvents:UIControlEventValueChanged];
    [self.myTableView addSubview:refreshControl];
    
//    __weak typeof(self) weakSelf = self;
//    self.myTableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
//    [self.myTableView addPullToRefreshWithActionHandler:^{
//        weakSelf.currentPagination.currentPage = 1;
//        [weakSelf.commentsArray removeAllObjects];
//        [weakSelf.myTableView reloadData]; // before load new content, clear the existing table list
//        [weakSelf getThreadCommentFromServerWithScrollDown:NO]; // load new data
//        [weakSelf.myTableView.pullToRefreshView stopAnimating]; // clear the animation
//    }];
    self.pagingButton.enabled = NO;
    [self getThreadCommentFromServerWithScrollDown:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadThreadInfo:) name:kThreadUpdated object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    self.pageObjectName = self.currentThread.thread_title;
    [super viewWillAppear:animated];
}

-(void)pullToRefreshTable{
    [self.myTableView setContentOffset:CGPointMake(0, -1.0f * self.refreshControl.frame.size.height) animated:YES];
    [self.refreshControl beginRefreshing];
    self.currentPagination.currentPage = 1;
    [self.commentsArray removeAllObjects];
    [self.myTableView reloadData]; // before load new content, clear the existing table list
    [self getThreadCommentFromServerWithScrollDown:NO]; // load new data
}

-(void)configureView{
    
    bottomHeightConst.constant = -paginationView.frame.size.height;
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:@""imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
    [lButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *rButton = [TheAppDelegate createButtonWithTitle:@"" imageName:@"btnReport" highlightedImageName:@"btnReportHighlight" forLeftButton:NO];
    [rButton addTarget:self action:@selector(threadMoreButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithCustomView:rButton];
    self.navigationItem.rightBarButtonItem = moreButton;
    
    likeButton.layer.cornerRadius = 2.0;
    likeButton.layer.masksToBounds = YES;
    
    if([currentThread.thread_liked boolValue]){
        likeButton.layer.borderWidth = 0.0;
        [likeButton setBackgroundColor:HEXCOLOR(0xd83831ff)];
        [likeButton setImage:[[UIImage imageNamed:@"btnThreadLike"] tintImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        likeButton.layer.borderColor = [HEXCOLOR(0xa9a9a9ff) CGColor];
    }else{
        likeButton.layer.borderWidth = 1.0;
        [likeButton setBackgroundColor:[UIColor clearColor]];
        [likeButton setImage:[UIImage imageNamed:@"btnThreadLike"]  forState:UIControlStateNormal];
        likeButton.layer.borderColor = [HEXCOLOR(0xa9a9a9ff) CGColor];
    }
    
    commentButton.layer.cornerRadius = 2.0;
    commentButton.layer.masksToBounds = YES;
    commentButton.layer.borderWidth = 1.0;
    [commentButton setBackgroundColor:[UIColor clearColor]];
    commentButton.layer.borderColor = [HEXCOLOR(0xa9a9a9ff) CGColor];
    
    shareButton.layer.cornerRadius = 2.0;
    shareButton.layer.masksToBounds = YES;
    shareButton.layer.borderWidth = 1.0;
    [shareButton setBackgroundColor:[UIColor clearColor]];
    shareButton.layer.borderColor = [HEXCOLOR(0xa9a9a9ff) CGColor];

    pagingButton.layer.cornerRadius = 2.0;
    pagingButton.layer.masksToBounds = YES;
    pagingButton.layer.borderWidth = 1.0;
    [pagingButton setBackgroundColor:[UIColor clearColor]];
    pagingButton.layer.borderColor = [HEXCOLOR(0xa9a9a9ff) CGColor];
    
    self.pagesSwipeView.bounces = NO;
    self.pagesSwipeView.pagingEnabled = YES;
    self.pagesSwipeView.scrollEnabled = YES;
    
//    NSLog(@"swipeWidth :%.2f | itemWidth: %.2f | itemsPerPage: %d",[UIScreen mainScreen].bounds.size.width - 100  ,[self swipeViewItemSize:self.pagesSwipeView].width,  (int)(([UIScreen mainScreen].bounds.size.width - 100) / [self swipeViewItemSize:self.pagesSwipeView].width));
    self.pagesSwipeView.delegate = self;
    self.pagesSwipeView.dataSource = self;
    self.pagesSwipeView.alignment = SwipeViewAlignmentEdge;
    self.pagesSwipeView.pagingEnabled = YES;
    self.pagesSwipeView.itemsPerPage  =  (int)(([UIScreen mainScreen].bounds.size.width - 100) / [self swipeViewItemSize:self.pagesSwipeView].width);
    self.pagesSwipeView.truncateFinalPage = YES;
    
    if(currentThread.thread_image_url && ![currentThread.thread_image_url isEqualToString:@""]){
        self.threadImageView.hidden = NO;
        if(self.constraintYThreadInfoContainer){
            [self.threadInfoContainerView.superview removeConstraint:self.constraintYThreadInfoContainer];
        }
        self.constraintYThreadInfoContainer = [self.threadInfoContainerView sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeBottom ofView:self.threadImageView inset:10.0];
    }else{
        self.threadImageView.hidden = YES;
        
        !self.constraintYThreadInfoContainer?:[self.threadInfoContainerView.superview removeConstraint:self.constraintYThreadInfoContainer];
        self.constraintYThreadInfoContainer = [self.threadInfoContainerView sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:[self.threadInfoContainerView superview] inset:10.0];
    }
    self.myTableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
}

-(void)setupThreadInfo{
    if(currentThread.thread_image_url && ![currentThread.thread_image_url isEqualToString:@""]){
        [self.threadImageView sd_setImageWithURL:[NSURL URLWithString:currentThread.thread_image_url]];
    }
    self.threadTitleLabel.text = currentThread.thread_title;
    self.commentCountLabel.text = currentThread.thread_stats.thread_stats_comments;
    self.likeCountLabel.text = currentThread.thread_stats.thread_stats_likes;
    self.updatedLabel.text = currentThread.thread_time_ago;
    
    NSString *htmlContent = currentThread.thread_content.thread_content_html;
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithData:[htmlContent dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:12.0]} documentAttributes:nil error:nil];
    
    self.threadDetailsLabel.attributedText = attrStr;
    [self configureThreadInfoHeight];
    
    //ini udah jadul suka crash klo atur ulang Framenya
//    NSAttributedString *contentString = GET_ATTRIBUTED_STRING(htmlContent, 12);
//    self.threadDetailsLabel.attributedText = contentString;

}

-(void)configureThreadInfoHeight{

    CGFloat cellPadding = 42;
    CGSize titleSize = [self.threadTitleLabel sizeThatFits:self.threadTitleLabel.frame.size];

    self.titleHeightConstraint.constant = titleSize.height;
    self.infoContainerHeightConstraint.constant = titleSize.height + cellPadding;
    
    CGSize contentSize = [self.threadDetailsLabel sizeThatFits:self.threadDetailsLabel.frame.size];
    self.detailHeightConstraint.constant = contentSize.height + 5;
    
    CGRect headerFrame = self.tableHeaderView.frame;
    float imageHeight = 0;
    if(currentThread.thread_image_url && ![currentThread.thread_image_url isEqualToString:@""]){
        imageHeight = [UIScreen mainScreen].bounds.size.width / 1.422;
    }
    
    headerFrame.size.height = imageHeight + self.infoContainerHeightConstraint.constant + self.detailHeightConstraint.constant + 90;
    self.tableHeaderView.frame = headerFrame;
    [self.myTableView setTableHeaderView:self.tableHeaderView];
    [self.tableHeaderView setNeedsLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getThreadCommentFromServerWithScrollDown:(BOOL)isScroll{
    
    NSString *threadId = currentThreadId?currentThreadId:currentThread.thread_id;
    [self.view startLoader:YES disableUI:NO];
    if(!isReloading){
        isReloading = YES;
        [ThreadComment getThreadCommentsWithThreadId:threadId andPageNumber:@(self.currentPagination.currentPage) withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *resultsArray) {
            
            [self.myTableView setContentOffset:CGPointMake(0, 0) animated:YES];
            [self.refreshControl endRefreshing];
            
            self.pagingButton.enabled = YES;
            [self.view startLoader:NO disableUI:NO];
            [self.commentsArray addObjectsFromArray:resultsArray];
            [self.myTableView reloadData];
            [self.myTableView.pullToRefreshView stopAnimating];
            isReloading = NO;
            NSData *responseData = operation.HTTPRequestOperation.responseData;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:responseData
                                  options:NSJSONReadingMutableLeaves
                                  error:nil];
            self.currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
            int totalPage = self.currentPagination.totalPage > 0 ? self.currentPagination.totalPage : 1;
            if (totalPage <= 1) {
                self.pageNextButton.enabled = NO;
            }
            [self.pagingButton setTitle:[NSString stringWithFormat:@"Page %d of %d",self.currentPagination.currentPage, totalPage] forState:UIControlStateNormal];
            [self.pagesSwipeView reloadData];
            
            
            //animate to scroll down after adding new commend
            if (self.commentsArray.count > 0 && isScroll)
                [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.commentsArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            
            [self.myTableView setContentOffset:CGPointMake(0, 0) animated:YES];
            [self.refreshControl endRefreshing];
            
            self.pagingButton.enabled = YES;
            [self.myTableView.pullToRefreshView stopAnimating];
            [self.view startLoader:NO disableUI:NO];
            isReloading = NO;
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
            }
        }];
    }
}


#pragma mark - ScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint currentOffset = scrollView.contentOffset;
    [self.view layoutIfNeeded];
    
    if(currentOffset.y <= 0){
        // Ada
        self.bottomEdgeConstraint.constant = 0;
    }else{
    
        if (currentOffset.y > self.lastContentOffset.y){
            // Ilang
            self.bottomEdgeConstraint.constant = -self.bottomButtonContainerView.frame.size.height;
        }
        else{
            // Ada
            self.bottomEdgeConstraint.constant = 0;
        }
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    self.lastContentOffset = currentOffset;
    
}

#pragma mark - IBActions
- (IBAction)likeButtonTapped:(id)sender {
    if([currentThread.thread_restriction.thread_restriction_open boolValue]) {
        if([currentThread.thread_liked boolValue]){
            //already liked, unlike
            
            likeButton.layer.borderWidth = 1.0;
            [likeButton setBackgroundColor:[UIColor clearColor]];
            [likeButton setImage:[UIImage imageNamed:@"btnThreadLike"]  forState:UIControlStateNormal];
            likeButton.layer.borderColor = [HEXCOLOR(0xa9a9a9ff) CGColor];

            [Thread unlikeUserThreadsWithId:currentThread.thread_id withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Thread *result) {
                self.currentThread.thread_liked = @(0);
                self.currentThread.thread_stats = result.thread_stats;
                [self setupThreadInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:kThreadUpdated object:nil];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [self configureView];
                NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                }
            }];
        }else{
            //not yet liked, like
            likeButton.layer.borderWidth = 0.0;
            [likeButton setBackgroundColor:HEXCOLOR(0xd83831ff)];
            [likeButton setImage:[[UIImage imageNamed:@"btnThreadLike"] tintImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            [Thread likeUserThreadsWithId:currentThread.thread_id withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Thread *result) {
                self.currentThread.thread_liked = @(1);
                self.currentThread.thread_stats = result.thread_stats;
                [self setupThreadInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:kThreadUpdated object:nil];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [self configureView];
                NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                }
            }];
        }
    }else{
        [self showAlertWithMessage:@"Anda harus bergabung ke Klub ini untuk menyukai thread ini."];
        return;
    }
    
}

- (IBAction)commentButtonTapped:(id)sender {
//    if([currentThread.thread_restriction.thread_restriction_open boolValue]) {
        PostDialogViewController *vc = [[PostDialogViewController alloc] initWithTitle:@"Tambah Komentar" andUser:[User fetchLoginUser]];
        vc.delegate = self;
        MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
        formSheet.shouldDismissOnBackgroundViewTap = YES;
        formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
        formSheet.cornerRadius = 5.0;
        formSheet.portraitTopInset = 24.0;
        formSheet.landscapeTopInset = 6.0;
        formSheet.presentedFormSheetSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width - 20, 300);
        
        vc.title = @"thread comment";
        formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
            presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
        };
        
        
        
        [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            
        }];
//    }else{
//        [self showAlertWithMessage:@"Anda harus bergabung ke Klub ini untuk manambah komentar."];
//        return;
//    }
    
    
}

- (IBAction)shareButtonTapped:(id)sender {
    
    
}

- (IBAction)pageButtonTapped:(id)sender {

    [self.view layoutIfNeeded];
    
    if (!isPagingShown) {
        bottomHeightConst.constant = 0;
    
    }else{
        bottomHeightConst.constant = -paginationView.frame.size.height;
    }

    [UIView animateWithDuration:0.3
                     animations:^{

                         [self.view layoutIfNeeded]; // Called on parent view
                     }];
        
    self.myTableView.contentInset = UIEdgeInsetsMake(0, 0, isPagingShown?60:105, 0);
    
    isPagingShown = !isPagingShown;
}


-(void)threadMoreButtonTapped{
    NSString *title;
    int cancelButtonIdx;
    if([self.currentThread.thread_user.user_id isEqualToString:[User fetchLoginUser].user_id]){
        self.customIBAS = [[IBActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Tutup" destructiveButtonTitle:nil otherButtonTitles:@"Ubah Thread", @"Hapus Thread", nil];
        cancelButtonIdx = 2;
    }else{
        self.customIBAS = [[IBActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Tutup" destructiveButtonTitle:nil otherButtonTitles:@"Laporkan", nil];
        cancelButtonIdx = 1;
    }
    
    self.customIBAS.blurBackground = NO;
    [self.customIBAS setFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:14.0]];
    
    [self.customIBAS setButtonBackgroundColor:HEXCOLOR(0xFFFFFFFF)];
    [self.customIBAS setButtonTextColor:HEXCOLOR(0x3399FFFF)];
    [self.customIBAS setButtonTextColor:[UIColor redColor] forButtonAtIndex:cancelButtonIdx];
    
    self.customIBAS.buttonResponse = IBActionSheetButtonResponseFadesOnPress;
    self.customIBAS.tag = kActionSheetThread;
    [self.customIBAS showInView:self.view];
}

- (IBAction)pagePrevButtonTapped:(id)sender {
    [self swipeView:self.pagesSwipeView didSelectItemAtIndex:currentPagination.prevPage-1];
}

- (IBAction)pageNextButtonTapped:(id)sender {
    [self swipeView:self.pagesSwipeView didSelectItemAtIndex:currentPagination.nextPage-1];
}

-(IBAction)threadImageTapped:(id)sender{
    ImageDetailViewController *vc = [[ImageDetailViewController alloc] initWithImageURL:self.currentThread.thread_image_url];
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark -
#pragma mark SwipeHorizontalMenu methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    //return the total number of items in the carousel
    return self.currentPagination.totalPage > 0 ? self.currentPagination.totalPage : 1;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50.0, pagesSwipeView.frame.size.height)];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.backgroundColor = [UIColor clearColor];
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:InterfaceStr(@"default_font_bold") size:12.0];
        label.textColor = index == self.currentPagination.currentPage-1 ? HEXCOLOR(0xFFFFFFFF) : HEXCOLOR(0x606060FF);
        label.tag = 1;
        [view addSubview:label];
        
        
        
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    label.textColor = index == self.currentPagination.currentPage-1 ? HEXCOLOR(0xFFFFFFFF) : HEXCOLOR(0x606060FF);
    label.text =  [NSString stringWithFormat:@"%ld",index+1];
    
    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return CGSizeMake(50.0, pagesSwipeView.frame.size.height);
}

-(void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index{
    self.pagesSwipeView.truncateFinalPage = YES;
    self.currentPagination.currentPage = (int)index+1;
    
    [self.commentsArray removeAllObjects];
    [self.myTableView reloadData]; // before load new content, clear the existing table list
    [self getThreadCommentFromServerWithScrollDown:NO]; // load new data
    [self.myTableView.pullToRefreshView stopAnimating]; // clear the animation

    if(currentPagination.currentPage <= 1)
        self.pagePrevButton.enabled = NO;
    else
        self.pagePrevButton.enabled = YES;
    if(currentPagination.currentPage >= currentPagination.totalPage)
        self.pageNextButton.enabled = NO;
    else
        self.pageNextButton.enabled = YES;
    
    if(currentPagination.currentPage > swipeView.itemsPerPage)
        self.pagesSwipeView.currentItemIndex = index;
    [self.pagesSwipeView reloadData];
}


#pragma mark - PostDialogViewController delegate
-(void)dialogDidCancel:(PostDialogViewController *)dialog{
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

-(void)dialogDidPost:(PostDialogViewController *)dialog withString:(NSString *)content{
    if([dialog.title isEqualToString:@"report thread"]){
        [Thread reportUserThreadsWithId:self.currentThread.thread_id andMessage:content withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *resultsArray) {
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
                [self showAlertWithMessage:@"Laporan berhasil dikirimkan"];
                [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
            }];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self showAlertWithMessage:@"Laporan gagal dikirim"];
        }];
    }else if([dialog.title isEqualToString:@"report comment"]){
        //report thread comment
        [Thread reportUserThreadsWithId:self.currentThread.thread_id andMessage:content withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *resultsArray) {
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
                [self showAlertWithMessage:@"Laporan berhasil dikirimkan"];
                [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
            }];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
            }
        }];
    }
    else if([dialog.title isEqualToString:@"thread comment"]){
        
        dialog.postButton.enabled = NO;
        [dialog.postButton setTitle:@"Loading ..." forState:UIControlStateNormal];
        
        [ThreadComment createThreadCommentWithThreadId:currentThread.thread_id andComment:content withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, ThreadComment *result) {
            
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *commentCount = jsonDict[@"thread"][@"stats"][@"comments"];
            self.commentCountLabel.text = [commentCount stringValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:kThreadUpdated object:nil];
            
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
            //
            self.currentPagination = [[PaginationModel alloc] initWithDictionary:jsonDict[@"pagination"]];
            int totalPage = self.currentPagination.totalPage > 0 ? self.currentPagination.totalPage : 1;
            if (totalPage <= 1) {
                self.pageNextButton.enabled = NO;
            }
            self.currentPagination.currentPage = totalPage;

            [self.commentsArray removeAllObjects];
            [self.myTableView reloadData]; // before load new content, clear the existing table list
            [self getThreadCommentFromServerWithScrollDown:YES];
            self.pagesSwipeView.truncateFinalPage = YES;
            [self swipeView:self.pagesSwipeView didSelectItemAtIndex:self.currentPagination.currentPage-1];

        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            
            dialog.postButton.enabled = YES;
            [dialog.postButton setTitle:@"Post" forState:UIControlStateNormal];
            
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
            }
        }];
        
    }else if([dialog.title isEqualToString:@"thread comment update"]){
        [ThreadComment updateThreadCommentWithThreadId:currentThread.thread_id andCommentId:currentComment.thread_comment_id andComment:content withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Thread *result) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kThreadUpdated object:nil];
            [self.myTableView reloadData];
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
            }
        }];
        
        
        
    }
    
}

#pragma mark - UITableView Delegate & Datasource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ThreadCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[ThreadCommentTableViewCell reuseIdentifier]];
    [cell fillCellWithComment:commentsArray[indexPath.row]];
    return [cell cellHeight];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commentsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ThreadCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[ThreadCommentTableViewCell reuseIdentifier]];
    cell.delegate = self;
    [cell fillCellWithComment:commentsArray[indexPath.row]];
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - CustomCell Delegate
-(void)threadCommentTableViewCell:(ThreadCommentTableViewCell *)cell moreButtonDidTapForComment:(ThreadComment *)cmn{
    self.currentComment = cmn;
    NSString *title;
    int cancelButtonIdx;
    if([cmn.thread_comment_user.user_id isEqualToString:CURRENT_USER_ID()]){
        //own comment
        self.customIBAS = [[IBActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Tutup" destructiveButtonTitle:nil otherButtonTitles:@"Ubah Komen", @"Hapus Komen", nil];
        cancelButtonIdx = 2;
    }else{
        //other people comment
        self.customIBAS = [[IBActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Tutup" destructiveButtonTitle:nil otherButtonTitles:@"Laporkan", nil];
        cancelButtonIdx = 1;
    }
    
    
    self.customIBAS.blurBackground = NO;
    [self.customIBAS setFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:14.0]];
    
    [self.customIBAS setButtonBackgroundColor:HEXCOLOR(0xFFFFFFFF)];
    [self.customIBAS setButtonTextColor:HEXCOLOR(0x3399FFFF)];
    [self.customIBAS setButtonTextColor:[UIColor redColor] forButtonAtIndex:cancelButtonIdx];
    
    self.customIBAS.buttonResponse = IBActionSheetButtonResponseFadesOnPress;
    self.customIBAS.tag = kActionSheetThreadComment;
    [self.customIBAS showInView:self.view];
}


- (void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if(actionSheet.tag == kActionSheetThreadComment){
        BOOL isCommentOwner = [self.currentComment.thread_comment_user.user_id isEqualToString:[User fetchLoginUser].user_id];
        NSInteger numButtons = actionSheet.numberOfButtons;
        BOOL tapLastButton = (buttonIndex == numButtons-2);
        
        BOOL deleteComment   = (isCommentOwner && tapLastButton);
        BOOL reportComment   = (!isCommentOwner && tapLastButton);
        BOOL editComment     = (isCommentOwner && buttonIndex == 0);
        
        if(deleteComment){
            [self deleteComment];
        }
        else if(editComment){
            [self editComment];
        }
        else if(reportComment){
            [self reportComment];
        }
    }else if(actionSheet.tag == kActionSheetThread){
        BOOL isThreadOwner = [self.currentThread.thread_user.user_id isEqualToString:[User fetchLoginUser].user_id];
        NSInteger numButtons = actionSheet.numberOfButtons;
        BOOL tapLastButton = (buttonIndex == numButtons-2);
        
        BOOL deleteThread   = (isThreadOwner && tapLastButton);
        BOOL reportThread   = (!isThreadOwner && tapLastButton);
        BOOL editThread     = (isThreadOwner && buttonIndex == 0);
        
        if(deleteThread){
            [self deleteThread];
        }
        else if(editThread){
            [self editThread:self.currentThread];
        }
        else if(reportThread){
            [self reportThread];
        }
    }

}

#pragma mark - Thread action
- (void)deleteThread{
    
    [UIAlertView showWithTitle:self.appName
                       message:@"Anda yakin?"
             cancelButtonTitle:@"Tidak"
             otherButtonTitles:@[@"Ya"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex != [alertView cancelButtonIndex]) {
                             
                              [Thread deleteUserThreadsWithId:self.currentThread.thread_id withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *resultsArray) {
                                  [self showAlertWithMessage:@"Thread berhasil dihapus"];
                                  [[NSNotificationCenter defaultCenter] postNotificationName:kThreadDeleted object:nil];
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

- (void)editThread:(Thread *)thread{
    
    if([thread.thread_restriction.thread_restriction_open boolValue]) {
        
        CreateThreadViewController *vc = [[CreateThreadViewController alloc]initWithThread:thread];
        CustomNavigationController *navController = [[CustomNavigationController alloc] initWithRootViewController:vc];
        navController.navigationBarHidden = YES;
        [self presentViewController:navController animated:YES completion:nil];
        return;
    }
}


- (void)reportThread{
    PostDialogViewController *vc = [[PostDialogViewController alloc] initWithTitle:@"Alasan" andUser:[User fetchLoginUser]];
    vc.buttonTitle = @"Laporkan";
    vc.placeHolderText = @"(contoh: Thread mengandung SARA, dsb...)";
    vc.delegate = self;
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.cornerRadius = 5.0;
    formSheet.portraitTopInset = 24.0;
    formSheet.landscapeTopInset = 6.0;
    formSheet.presentedFormSheetSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width - 20, 300);
    
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
        presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
    };
    vc.title = @"report thread";
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
}

#pragma mark - Thread Comment action
- (void)deleteComment{
    
    [UIAlertView showWithTitle:self.appName
                       message:@"Anda yakin?"
             cancelButtonTitle:@"Tidak"
             otherButtonTitles:@[@"Ya"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          
        if (buttonIndex != [alertView cancelButtonIndex]) {
    
            [ThreadComment deleteThreadCommentWithThreadId:self.currentThread.thread_id andCommentId:self.currentComment.thread_comment_id withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, ThreadComment *result) {
                NSLog(@"success");
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                self.currentPagination = [[PaginationModel alloc] initWithDictionary:jsonDict[@"pagination"]];
                int totalPage = self.currentPagination.totalPage > 0 ? self.currentPagination.totalPage : 1;
                if (totalPage <= 1) {
                    self.pageNextButton.enabled = NO;
                }

                [self swipeView:self.pagesSwipeView didSelectItemAtIndex:self.currentPagination.currentPage-1];

                
                NSNumber *commentCount = jsonDict[@"thread"][@"stats"][@"comments"];
                self.commentCountLabel.text = [commentCount stringValue];
                [[NSNotificationCenter defaultCenter] postNotificationName:kThreadUpdated object:nil];
                [self.commentsArray removeObject:result];
                [self.myTableView reloadData];
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

- (void)editComment{
    PostDialogViewController *vc = [[PostDialogViewController alloc] initWithTitle:@"Ubah Komentar" andUser:[User fetchLoginUser]];
    vc.delegate = self;
    vc.contentText = currentComment.thread_comment_content;
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.cornerRadius = 5.0;
    formSheet.portraitTopInset = 24.0;
    formSheet.landscapeTopInset = 6.0;
    formSheet.presentedFormSheetSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width - 20, 300);
    
    vc.title = @"thread comment update";
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
        presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
    };
    
    
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
    
}


- (void)reportComment{
    PostDialogViewController *vc = [[PostDialogViewController alloc] initWithTitle:@"Alasan" andUser:[User fetchLoginUser]];
    vc.buttonTitle = @"Laporkan";
    vc.placeHolderText = @"(contoh: Komentar mengandung SARA, dsb...)";
    vc.delegate = self;
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.cornerRadius = 5.0;
    formSheet.portraitTopInset = 24.0;
    formSheet.landscapeTopInset = 6.0;
    formSheet.presentedFormSheetSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width - 20, 300);
    
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
        presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
    };
    vc.title = @"report comment";
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
}

#pragma mark - ThreadUpdatedNotifications Handler
-(void)reloadThreadInfo:(NSNotification *)notif{
    if(notif.object && [notif.object isKindOfClass:[Thread class]])
    {
        self.currentThread = notif.object;
        [self configureView];
        [self setupThreadInfo];
        [self.threadImageView setNeedsLayout];
        [self.threadInfoContainerView setNeedsLayout];
    }

}

@end
