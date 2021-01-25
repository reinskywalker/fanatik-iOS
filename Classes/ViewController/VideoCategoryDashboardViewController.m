//
//  VideoCategoryDashboardViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 5/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "VideoCategoryDashboardViewController.h"
#import "VideoCategoryLayout.h"
#import "SearchClipTableViewCell.h"
#import "VideoCategoryFooterCell.h"
#import "VideoCategoryPickerViewController.h"
#import "VideoSubCategoryViewController.h"
#import "MoreVideosViewController.h"

@interface VideoCategoryDashboardViewController ()<VideoCategoryLayoutDelegate, SearchClipTableViewCellDelegate, VideoCategoryFooterCellDelegate, VideoCategoryPickerViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *clipGroupsArray;
@property (nonatomic, retain) NSString *categoryID;
@property (nonatomic, retain) ParentViewController *layoutViewController;
@property (nonatomic, assign) int layoutID;
@end

@implementation VideoCategoryDashboardViewController
@synthesize layoutViewController, layoutID, categoryID, clipGroupsArray, myTableView;
-(id)initWithCategoryID:(NSString *)catID andLayoutID:(int)idx{
    if(self = [super init]){
        self.clipGroupsArray = [NSMutableArray array];
        self.categoryID = catID;
        self.layoutID = idx;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getCategoryFromServer];
}

-(void)configureView{
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.alwaysBounceVertical = NO;
    [self.myTableView registerNib:[UINib nibWithNibName:[SearchClipTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[SearchClipTableViewCell reuseIdentifier]];
    
    [self.myTableView registerNib:[UINib nibWithNibName:[VideoCategoryFooterCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[VideoCategoryFooterCell reuseIdentifier]];
    
}

-(void)setupTableLayout{
    [self configureView];
    layoutViewController = [[VideoCategoryLayout alloc] initWithClipGroup:self.clipGroupsArray[0] andLayoutId:self.layoutID];
    [(VideoCategoryLayout *)layoutViewController setDelegate:self];
    [self.clipGroupsArray removeObjectAtIndex:0];

    self.myTableView.tableHeaderView = layoutViewController.view;
    CGRect destFrame = self.myTableView.tableHeaderView.frame;
    destFrame.size.height = [(VideoCategoryLayout *)layoutViewController getActualHeight];
    self.myTableView.tableHeaderView.frame = destFrame;
    self.myTableView.tableHeaderView = self.myTableView.tableHeaderView;
}

-(void)getCategoryFromServer{
    [self.view startLoader:YES disableUI:NO];
    [ClipGroup getClipGroupWithCategoryId:categoryID andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *clipsArray) {
        [self.clipGroupsArray removeAllObjects];
        
        self.clipGroupsArray = [NSMutableArray arrayWithArray:clipsArray];
        [self.view startLoader:NO disableUI:NO];
        [self setupTableLayout];
        [self.myTableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self.view startLoader:NO disableUI:NO];
    }];
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
    NSLog(@"section: %lu",(unsigned long)self.clipGroupsArray.count);
    return self.clipGroupsArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    ClipGroup *theClipGroup = clipGroupsArray[section];
    NSArray *arr = [theClipGroup.clip_group_clips array];
    NSLog(@"%@",arr);
    NSLog(@"rows: %lu",[theClipGroup.clip_group_clips array].count+1);
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
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

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    ClipGroup *theClipGroup = clipGroupsArray[indexPath.section];
    NSArray *clipsArray = [theClipGroup.clip_group_clips array];
    
    if(indexPath.row >= clipsArray.count)
        return NO;
    return YES;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectHeaderView = [UIView new];
    sectHeaderView.frame = CGRectMake(0, 0, self.myTableView.frame.size.width, 35);
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y<=0) {
        scrollView.contentOffset = CGPointZero;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showCategoryPicker{
//    VideoCategoryPickerViewController *picker = [[VideoCategoryPickerViewController alloc] init];
//    picker.delegate = self;
//    CustomNavigationController *customNav = [[CustomNavigationController alloc] initWithRootViewController:picker];
//    customNav.navigationBarHidden = YES;
//    [self presentViewController:customNav animated:YES completion:nil];
    
    VideoCategoryPickerViewController *picker = [[VideoCategoryPickerViewController alloc] initWithCategoryId:categoryID];

    picker.delegate = self;
    CustomNavigationController *customNav = [[CustomNavigationController alloc] initWithRootViewController:picker];
    customNav.navigationBarHidden = YES;
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:customNav];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.cornerRadius = 0.0;
    formSheet.portraitTopInset = -20.0;
    formSheet.landscapeTopInset = -20.0;
    formSheet.presentedFormSheetSize = [[UIScreen mainScreen] bounds].size;
    


    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
        presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
    };
    
    
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
    
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

-(void)didSelectVideo:(Clip *)clip{
    VideoDetailViewController *vc = [[VideoDetailViewController alloc] initWithClip:clip];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)didSelectCategory:(ClipCategory *)cat{
    VideoSubCategoryViewController *subCategoryVC = [[VideoSubCategoryViewController alloc] initWithCategory:cat];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:subCategoryVC animated:YES];

}
@end
