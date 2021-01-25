//
//  VideoSubCategoryViewController.m
//  Fanatik
//
//  Created by Erick Martin on 5/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "VideoSubCategoryViewController.h"
#import "MoreVideosViewController.h"

@implementation VideoSubCategoryViewController
@synthesize horizontalMenu, subCategoryTableView, subCategoryBannerView, subCategoryNamesArray, subCategoriesArray, visibleItems;
@synthesize currentCategoryID, currentCategory, selectedMenuIndex, clipGroupsArray;
@synthesize layoutSubView, heightOfHorizontalMenu;

-(id)initWithCategory:(ClipCategory *)cat{

    if(self=[super init]){
        self.subCategoryNamesArray = [NSMutableArray array];
        self.subCategoriesArray = [NSMutableArray array];
        self.clipGroupsArray = [NSMutableArray array];
        self.currentCategory = cat;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self configureView];
    
    [self getSubCategoriesFromServerWithCategoryId:currentCategory.clip_category_id];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self getClipGroupFromServerWithCategoryId:currentCategory.clip_category_id];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    self.navigationController.navigationBarHidden = YES;
}


-(void)getClipGroupFromServerWithCategoryId:(NSString *)catId{
    [self.view startLoader:YES disableUI:NO];
    [ClipGroup getClipGroupWithCategoryId:catId andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *clipsArray) {
        [self.clipGroupsArray removeAllObjects];
        
        self.clipGroupsArray = [NSMutableArray arrayWithArray:clipsArray];
        [self.view startLoader:NO disableUI:NO];
        
        [self setupTableLayout];
        [subCategoryTableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self.view startLoader:NO disableUI:NO];
        
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){

            NSData *responseData = operation.HTTPRequestOperation.responseData;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:responseData //1
                                  options:NSJSONReadingMutableLeaves
                                  error:nil];
            NSString *message = json[@"error"][@"messages"][0];
            [self showLocalValidationError:message];
        }
        
    }];
    

}

-(void)getSubCategoriesFromServerWithCategoryId:(NSString *)catId{
    
    [ClipCategory getSubCategoryWithCategoryId:catId andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *resultArray) {
        [self.subCategoriesArray removeAllObjects];
        [self.subCategoriesArray addObjectsFromArray:resultArray];
        
        [self reloadHorizontalMenu];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
        }
    }];
}

-(void)configureView{
    self.navigationController.navigationBar.barTintColor = [TheInterfaceManager headerBGColor];
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:nil imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
    [lButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.title = self.currentCategory.clip_category_name;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:InterfaceStr(@"default_font_bold") size:17]}];    
    
    self.horizontalMenu.alignment = SwipeViewAlignmentEdge;
    self.horizontalMenu.pagingEnabled = NO;
    self.horizontalMenu.itemsPerPage = visibleItems = 3;
    self.horizontalMenu.truncateFinalPage = YES;
    self.selectedMenuIndex = 0;
    [self.subCategoryTableView registerNib:[UINib nibWithNibName:[SearchClipTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[SearchClipTableViewCell reuseIdentifier]];
    
    [self.subCategoryTableView registerNib:[UINib nibWithNibName:[VideoCategoryFooterCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[VideoCategoryFooterCell reuseIdentifier]];
    
}

-(void)setupTableLayout{
    
    if(clipGroupsArray.count > 0){
        if(!layoutSubView){
            layoutSubView = [[VideoSubCategoryLayout alloc] initWithClipGroup:clipGroupsArray[0] andLayoutId:1];
        }else{
            [layoutSubView setCurrentClipGroup:clipGroupsArray[0]];
            [layoutSubView setLayoutID:1];
            [layoutSubView configureView];
        }
        
        layoutSubView.delegate = self;
        self.subCategoryTableView.tableHeaderView = layoutSubView.view;
        
        CGRect destFrame = self.subCategoryTableView.tableHeaderView.frame;
        destFrame.size.height = [(VideoSubCategoryLayout *)layoutSubView getActualHeight];
        self.subCategoryTableView.tableHeaderView.frame = destFrame;
        self.subCategoryTableView.tableHeaderView = self.subCategoryTableView.tableHeaderView;
    }else{
        self.subCategoryTableView.tableHeaderView = nil;
    }
}

-(void)reloadHorizontalMenu{
    
    [UIView animateWithDuration:3 animations:^{
        heightOfHorizontalMenu.constant = subCategoriesArray.count>0?37.0:0;
    }];

    NSInteger idx = 0;
    
    [subCategoryNamesArray removeAllObjects];
    for(ClipCategory *cat in subCategoriesArray){
        [subCategoryNamesArray addObject:cat.clip_category_name];
        
        if([cat.clip_category_id isEqualToString:currentCategoryID]){
            self.selectedMenuIndex = idx;
            self.currentCategory = cat;
            if(subCategoryNamesArray.count > visibleItems)
                self.horizontalMenu.currentItemIndex = idx;
        }
        idx++;
    }
    
    [self.horizontalMenu reloadData];
}

#pragma mark - IBActions
-(IBAction)backButtonTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - SwipeHorizontalMenu methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    //return the total number of items in the carousel
    return [subCategoryNamesArray count];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ceilf(horizontalMenu.frame.size.width)/visibleItems, horizontalMenu.frame.size.height)];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.backgroundColor = [UIColor whiteColor];
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:InterfaceStr(@"default_font_bold") size:12.0];
        
        

        label.tag = 1;
        [view addSubview:label];
        
        UIView *sideSeparator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.frame)-1, 0, 1.0, CGRectGetHeight(view.frame))];
        sideSeparator.backgroundColor = HEXCOLOR(0xD6D6D6FF);
    
        [view addSubview:sideSeparator];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    if(index != selectedMenuIndex){
        label.textColor = HEXCOLOR(0x3333337F);
    }else{
        label.textColor = HEXCOLOR(0x333333FF);
        
        NSLog(@"index yg kepilih : %zd", index);
    }
    
    label.text =  [subCategoryNamesArray[index] uppercaseString];
    
    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return CGSizeMake(ceilf(horizontalMenu.frame.size.width)/visibleItems, horizontalMenu.frame.size.height);
}

-(void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index{
    self.selectedMenuIndex = index;
    self.currentCategory = subCategoriesArray[index];
    
    [self.clipGroupsArray removeAllObjects];

    [self getClipGroupFromServerWithCategoryId:currentCategory.clip_category_id]; // load new data
    [self.subCategoryTableView.pullToRefreshView stopAnimating]; // clear the animation

    self.horizontalMenu.currentItemIndex = index;
    [self.horizontalMenu reloadData];
    
}

#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ClipGroup *theClipGroup = clipGroupsArray[indexPath.section];
    if(indexPath.row > [theClipGroup.clip_group_clips array].count){
        //for footer cell
        return 54.0;
    }
    return 85.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.clipGroupsArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    ClipGroup *theClipGroup = clipGroupsArray[section];
    return [theClipGroup.clip_group_clips array].count+1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    ClipGroup *theClipGroup = clipGroupsArray[indexPath.section];
    NSArray *clipsArray = [theClipGroup.clip_group_clips array];
    if(indexPath.row >= clipsArray.count){
        VideoCategoryFooterCell *cell = [tableView dequeueReusableCellWithIdentifier:[VideoCategoryFooterCell reuseIdentifier]];
        [cell setCurrentClipGroup:theClipGroup];
        cell.delegate = self;
        return cell;
    }else{
        SearchClipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SearchClipTableViewCell reuseIdentifier]];
        [cell fillWithClip:[clipsArray objectAtIndex:indexPath.row]];
        cell.delegate = self;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClipGroup *theClipGroup = clipGroupsArray[indexPath.section];
    NSArray *clipsArray = [theClipGroup.clip_group_clips array];
    if(indexPath.row < clipsArray.count){
        ClipGroup *theClipGroup = clipGroupsArray[indexPath.section];
        NSArray *clipsArray = [theClipGroup.clip_group_clips array];
        Clip *theClip = [clipsArray objectAtIndex:indexPath.row];
        VideoDetailViewController *vc = [[VideoDetailViewController alloc] initWithClip:theClip];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self.navigationController pushViewController:[[MoreVideosViewController alloc] initWithClipGroup:theClipGroup] animated:YES];
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectHeaderView = [UIView new];
    sectHeaderView.frame = CGRectMake(0, 0, self.subCategoryTableView.frame.size.width, 35);
    ClipGroup *theClipGroup = [clipGroupsArray objectAtIndex:section];
    
    sectHeaderView.backgroundColor = [UIColor whiteColor];
    UIImageView *iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 0, 15, 15)];
    CGPoint center = sectHeaderView.center;
    center.x = iconImage.center.x;
    iconImage.center = center;
    iconImage.image = nil;
    [iconImage sd_setImageWithURL:[NSURL URLWithString:theClipGroup.clip_group_thumbnail.thumbnail_720] placeholderImage:[UIImage imageNamed:@"popularVid"]];
    CustomBoldLabel *titleLabel = [[CustomBoldLabel alloc] initWithFrame:CGRectMake(30, 0, 320-15, 35)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont fontWithName:InterfaceStr(@"default_font_bold") size:12.0];
    titleLabel.textColor = HEXCOLOR(0x333333ff);
    titleLabel.text = theClipGroup.clip_group_name;
    [sectHeaderView addSubview:titleLabel];
    [sectHeaderView addSubview:iconImage];
    
    return sectHeaderView;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    ClipGroup *theClipGroup = clipGroupsArray[indexPath.section];
    NSArray *clipsArray = [theClipGroup.clip_group_clips array];
    
    if(indexPath.row >= clipsArray.count)
        return NO;
    return YES;
}

#pragma mark - Banner Delegate
-(void)didSelectVideo:(Clip *)clip{
    VideoDetailViewController *vc = [[VideoDetailViewController alloc] initWithClip:clip];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Cell Delegate
-(void)moreButtonDidTapForClip:(Clip *)clip{
    self.currentClip = clip;
    [self moreButtonTappedForClip:clip];
}

-(void)didTapMoreVideosButton:(id)currClipGroup{
    NSLog(@"more videos!");
    [self.navigationController pushViewController:[[MoreVideosViewController alloc] initWithClipGroup:(ClipGroup *)currClipGroup] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.horizontalMenu.delegate = nil;
    self.horizontalMenu.dataSource = nil;
    self.subCategoryTableView.delegate = nil;
    self.subCategoryTableView.dataSource = nil;
}

@end
