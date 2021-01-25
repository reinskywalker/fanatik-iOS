//
//  SubscriptionViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/9/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "SubscriptionViewController.h"
#import "SubscriptionTableViewCell.h"
#import "CheckoutViewController.h"
#import "SectionModel.h"

@interface SubscriptionViewController ()<SubscriptionTableViewCellDelegate>
@property (nonatomic, retain) NSMutableArray *activeSubsArray;
@property (nonatomic, retain) NSMutableArray *inactiveSubsArray;
@property (nonatomic, retain) NSMutableArray *sectionArray;

@end

@implementation SubscriptionViewController

@synthesize myTableView, subscriptionsArray, activeSubsArray, inactiveSubsArray;

-(instancetype)init{
    if(self = [super init]){
        self.subscriptionsArray = [NSMutableArray new];
        self.activeSubsArray = [NSMutableArray new];
        self.inactiveSubsArray = [NSMutableArray new];
        self.sectionArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPageCode = MenuPageMyPackages;
    [self.myTableView registerNib:[UINib nibWithNibName:[SubscriptionTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[SubscriptionTableViewCell reuseIdentifier]];
    [self.myTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self getDataFromServer];
}

-(void)getDataFromServer{
    [self.view startLoader:YES disableUI:NO];
    [Package getUserPackageListWithAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *resultsArray) {
        
        [self.view startLoader:NO disableUI:NO];
        
        [self.subscriptionsArray addObjectsFromArray:resultsArray];
        self.blankLabel.hidden = self.subscriptionsArray.count>0?YES:NO;
        
        [self sortArray];
        [self.myTableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        [self.view startLoader:NO disableUI:NO];
        
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
        }
    }];
}

-(void)sortArray{

    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"package_inactive_at" ascending:YES];
    NSArray *sortedArray = [subscriptionsArray sortedArrayUsingDescriptors:@[sort]];
    for(Package *package in sortedArray){
        if ([package.package_inactive_at isLaterThanDate:[NSDate date]]) {
            [activeSubsArray addObject:package];
        }else{
            [inactiveSubsArray addObject:package];
        }
    }
    
    if(activeSubsArray.count > 0){
        SectionModel *sec0 = [[SectionModel alloc] init];
        sec0.cellArray = activeSubsArray;
        sec0.sectionName = @"SUBSCRIPTION ACTIVE";
        [self.sectionArray addObject:sec0];
    }
    
    if(inactiveSubsArray.count > 0){
        SectionModel *sec1 = [[SectionModel alloc] init];
        sec1.cellArray = inactiveSubsArray;
        sec1.sectionName = @"SUBSCRIPTION INACTIVE";
        [self.sectionArray addObject:sec1];
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView Delegate & Datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SectionModel *sec = self.sectionArray[section];
    return sec.cellArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 78.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.myTableView.frame.size.width, 35.0)];
    NSLog(@"width: %f",self.myTableView.frame.size.width);
    headerView.backgroundColor = HEXCOLOR(0xF0F4F4F4FF);
    [headerView sdc_pinHeight:35.0];
    [headerView sdc_pinWidth:self.myTableView.frame.size.width];
//    [headerView sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:headerView.superview];
//    [headerView sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:headerView.superview];
    CustomBoldLabel *titleLabel = [[CustomBoldLabel alloc] initWithFrame:CGRectMake(10, 8, 180, 20)];
    [titleLabel setFont:[UIFont fontWithName:InterfaceStr(@"default_font_bold") size:12.0]];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.backgroundColor = [UIColor clearColor];
    
    SectionModel *sec = self.sectionArray[section];
    titleLabel.text = sec.sectionName;
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [headerView addSubview:titleLabel];
    [titleLabel sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:headerView inset:10.0];
    [titleLabel sdc_alignVerticalCenterWithView:headerView];
    [titleLabel sdc_pinWidth:180];
    [titleLabel sdc_pinHeight:20];

    
    CustomBoldLabel *countLabel = [[CustomBoldLabel alloc] initWithFrame:CGRectMake(257, 8, 50, 20)];
    [countLabel setFont:[UIFont fontWithName:InterfaceStr(@"default_font_bold") size:12.0]];
    countLabel.translatesAutoresizingMaskIntoConstraints = NO;
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.text = section == 0 ? [NSString stringWithFormat:@"%lu",(unsigned long)activeSubsArray.count] : [NSString stringWithFormat:@"%lu",(unsigned long)inactiveSubsArray.count];
    [countLabel setTextAlignment:NSTextAlignmentRight];
    [headerView addSubview:countLabel];
    [countLabel sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:headerView inset:-10.0];
    [countLabel sdc_alignVerticalCenterWithView:headerView];
    [countLabel sdc_pinWidth:50];
    [countLabel sdc_pinHeight:20];

    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SectionModel *sec = self.sectionArray[indexPath.section];
    Package *aPackage = sec.cellArray[indexPath.row];;
    SubscriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SubscriptionTableViewCell reuseIdentifier]];
    cell.buyButton.hidden = indexPath.section == 0;
    cell.delegate = self;
    [cell fillCellWithPackage:aPackage];
    return cell;
    
}

#pragma mark - SubscriptionTableViewCellDelegate
-(void)buyPackage:(Package *)obj{
    [TheServerManager openPackagesForContentClass:ContentClassNone withID:nil];
//    obj.package_id = obj.package_renewal_id;
//    CheckoutViewController *vc = [[CheckoutViewController alloc] initWithPackage:obj];
//    [self.navigationController pushViewController:vc animated:YES];
}

@end
