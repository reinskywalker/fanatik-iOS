//
//  DashboardViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/12/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "DashboardViewController.h"
#import "LargeVideoTableViewCell.h"
#import "SmallVideoTableViewCell.h"
#import "NSObject+DelayedBlock.h"
#import "MoreVideosViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DashboardViewController ()

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *clipGroupsArray;


@end

@implementation DashboardViewController
@synthesize clipGroupsArray, imgView;

-(instancetype)init{
    if(self =[super init]){
        self.clipGroupsArray = [NSMutableArray new];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clipGroupsArray = [NSMutableArray arrayWithArray:[ClipGroup fetchDashboardMenu]];
    [self.myTableView reloadData];
    
    self.currentPageCode = MenuPageHome;
    [self.view setBackgroundColor:HEXCOLOR(0xf0f4f4ff)];
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.myTableView registerNib:[UINib nibWithNibName:[LargeVideoTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([LargeVideoTableViewCell class])];
    [self.myTableView registerNib:[UINib nibWithNibName:[SmallVideoTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([SmallVideoTableViewCell class])];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDashboardFromServer) name:kLogoutCompletedNotification object:nil];
    
    __weak typeof(self) weakSelf = self;
    [self.myTableView addPullToRefreshWithActionHandler:^{
        [weakSelf.myTableView reloadData]; // before load new content, clear the existing table list
        [weakSelf getDashboardFromServer]; // load new data
        [weakSelf.myTableView.pullToRefreshView stopAnimating]; // clear the animation
    }];

    [self getDashboardFromServer];
    [self.myTableView setTranslatesAutoresizingMaskIntoConstraints:NO];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* foofile = [documentsPath stringByAppendingPathComponent:@"test.png"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
    
    if(!TheSettingsManager.isLoadSplashScreen && fileExists){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kHideNavBar" object:@(YES)];

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:@"test.png"];
        UIImage* image = [UIImage imageWithContentsOfFile:path];
        [imgView setImage:image];
        
        NSLog(@"%f",[TheSettingsManager.currentSplashScreen.splash_screen_time doubleValue]);
        
        [self performBlock:^{
            //fade out
            [UIView animateWithDuration:0.3 animations:^{
                [imgView setAlpha:0.0f];
                
                [TheSettingsManager loadedSplashScreen:YES];
                [self performBlock:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kHideNavBar" object:@(NO)];
                } afterDelay:0.2];
            } completion:nil];
        } afterDelay:[TheSettingsManager.currentSplashScreen.splash_screen_time doubleValue]];
    }

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getDashboardFromServer{
    [self.view startLoader:YES disableUI:NO];

    [ClipGroup getDashboardWithAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *clipsArray) {
        self.clipGroupsArray = [NSMutableArray arrayWithArray:clipsArray];
        [self.view startLoader:NO disableUI:NO];
        [self.myTableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self.view startLoader:NO disableUI:NO];
    }];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 60;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0)
        return 250.0;
    return 151.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.clipGroupsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // example using a custom UITableViewCell
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:{
            cell = (LargeVideoTableViewCell *) [tableView dequeueReusableCellWithIdentifier:[LargeVideoTableViewCell reuseIdentifier]];
            [(LargeVideoTableViewCell *)cell setDelegate:self];
            [(LargeVideoTableViewCell *)cell setCellWithClipGroup:self.clipGroupsArray[indexPath.section]];
        }
            break;
        case 1:{
            cell = (SmallVideoTableViewCell *) [tableView dequeueReusableCellWithIdentifier:[SmallVideoTableViewCell reuseIdentifier]];
            [(SmallVideoTableViewCell *)cell setDelegate:self];
            [(SmallVideoTableViewCell *)cell setCellWithClipGroup:self.clipGroupsArray[indexPath.section] andIndex:indexPath.section];
        }
            break;
            
        default:{
            cell = (SmallVideoTableViewCell *) [tableView dequeueReusableCellWithIdentifier:[SmallVideoTableViewCell reuseIdentifier]];
            [(SmallVideoTableViewCell *)cell setDelegate:self];
            [(SmallVideoTableViewCell *)cell setCellWithClipGroup:self.clipGroupsArray[indexPath.section] andIndex:indexPath.section];
        }
            break;
    }
   
    
    
    
    return cell;
}

- (void)configureCell:(SideMenuCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    RowMenu *info = [_fetchedResultsController objectAtIndexPath:indexPath];
//    [cell setCellWithRowMenu:info];

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 40.0;
    }
    return 60.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectHeaderView = [UIView new];
    sectHeaderView.frame = CGRectMake(0, 0, self.myTableView.frame.size.width, section==0?40.0:60.0);
    ClipGroup *theClipGroup = [clipGroupsArray objectAtIndex:section];
    if(section == 0){
        
        sectHeaderView.backgroundColor = HEXCOLOR(0xf0f4f4ff);
        CustomBoldLabel *titleLabel = [CustomBoldLabel new];
        titleLabel.frame =CGRectMake(0, 5, self.myTableView.frame.size.width, 35);
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = theClipGroup.clip_group_name;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont fontWithName:InterfaceStr(@"default_font_bold") size:16.0];
        titleLabel.textColor = HEXCOLOR(0x666666ff);
        [sectHeaderView addSubview:titleLabel];
    }else{
        sectHeaderView.backgroundColor = [UIColor whiteColor];
        UIImageView *iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 30, 30)];
        iconImage.image = nil;
        [iconImage sd_setImageWithURL:[NSURL URLWithString:theClipGroup.clip_group_thumbnail.thumbnail_480] placeholderImage:[UIImage imageNamed:@"popularVid"]];
        [iconImage setContentMode:UIViewContentModeScaleAspectFit];
        iconImage.layer.cornerRadius = 15.0;
        iconImage.clipsToBounds = YES;
        CustomBoldLabel *titleLabel = [[CustomBoldLabel alloc] initWithFrame:CGRectMake(45, 0, 320-15, 60)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = [UIFont fontWithName:InterfaceStr(@"default_font_bold") size:14.0];
        titleLabel.textColor = HEXCOLOR(0x333333ff);
        titleLabel.text = theClipGroup.clip_group_name;
        [sectHeaderView addSubview:titleLabel];
        [sectHeaderView addSubview:iconImage];
    }
    return sectHeaderView;
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



#pragma mark - LargeVideoTableViewCellDelegate
-(void)didSelectClip:(Clip *)aClip{
    [self.navigationController pushViewController:[[VideoDetailViewController alloc] initWithClip:aClip] animated:YES];
}

-(void)didTapMoreButtonForClip:(Clip *)aClip{
    self.currentClip = aClip;
    [self moreButtonTappedForClip:aClip];
}

#pragma mark - SmallVideoTableViewCellDelegate
-(void)didTapMoreVideoButton:(NSInteger)index{
    [self.navigationController pushViewController:[[MoreVideosViewController alloc]initWithClipGroup:self.clipGroupsArray[index]] animated:YES];
}

-(void)didSelectFeaturedUser:(User *)usr{
    ProfileViewController *controller = [[ProfileViewController alloc] initWithUser:usr];
    controller.currentProfileMode = ProfileModeVideo;
    [self.navigationController pushViewController:controller animated:YES];

}

@end
