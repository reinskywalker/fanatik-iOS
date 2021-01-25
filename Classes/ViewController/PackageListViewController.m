//
//  PackageListViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/4/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "PackageListViewController.h"
#import "PackageListTableViewCell.h"
#import "CheckoutViewController.h"
#import "SubscriptionViewController.h"

@interface PackageListViewController ()<UITableViewDataSource, UITableViewDelegate, PackageListTableViewCellDelegate, UIWebViewDelegate>

@property(nonatomic, retain) NSArray *packagesArray;
@property (strong, nonatomic) IBOutlet UIView *termsConditionView;
- (IBAction)linkButtonTapped:(id)sender;

@end

@implementation PackageListViewController
@synthesize myTableView, packagesArray, shouldPresent, delegate;

-(id)init{
    if(self = [super init]){
        self.packagesArray = [NSArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.myTableView registerNib:[UINib nibWithNibName:[PackageListTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[PackageListTableViewCell reuseIdentifier]];
    self.myTableView.tableFooterView = self.termsConditionView;
   
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"leftArrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    self.navigationItem.leftBarButtonItem = backButton;
    __weak typeof(self) weakSelf = self;
    [self.myTableView addPullToRefreshWithActionHandler:^{
        weakSelf.packagesArray = nil;
        [weakSelf.myTableView reloadData];
        [weakSelf getPackagesFromServer];
        [weakSelf.myTableView.pullToRefreshView stopAnimating];
        
    }];
    
    
    [self getPackagesFromServer];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentDidSuccess:) name:kPaymentCompleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentDidFail:) name:kPaymentFailed object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getPackagesFromServer{
    [self.view startLoader:YES disableUI:NO];
    [Package getPackageListWithAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *resultsArray) {
        self.packagesArray = resultsArray;
        [self.myTableView reloadData];
        [self.view startLoader:NO disableUI:NO];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
        }
        
        [self.view startLoader:NO disableUI:NO];
    }];
}

#pragma mark - UITableView Delegate * Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return packagesArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PackageListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[PackageListTableViewCell reuseIdentifier]];
    [cell fillCellWithPackage:[packagesArray objectAtIndex:indexPath.row]];
    cell.delegate = self;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Package *obj = self.packagesArray[indexPath.row];
    CheckoutViewController *vc = [[CheckoutViewController alloc] initWithPackage:obj];
    vc.shouldPresent = NO;
    if(shouldPresent){
        CustomNavigationController *navController = [[CustomNavigationController alloc] initWithRootViewController:vc];
        navController.navigationBarHidden = YES;
        vc.didPresent = YES;
        [self presentViewController:navController animated:YES completion:nil];
    }else{
        vc.didPresent = NO;
        [self.navigationController pushViewController: vc animated:YES];
    }
   
}

#pragma mark - PackageListTableViewCell Delegate
-(void)buyPackage:(Package *)obj{
}



- (IBAction)linkButtonTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ConstStr(@"website_url")]];
}

#pragma mark - Payment Notification Handler
-(void)paymentDidSuccess:(NSNotification *)notif{
    if ([TheSettingsManager.selectedMenu isEqualToString:MenuPagePackages]) {
        SubscriptionViewController *vc = [[SubscriptionViewController alloc] init];
        [TheAppDelegate changeCenterController:vc];
    }
    
}

-(void)paymentDidFail:(NSNotification *)notif{
    
}

-(IBAction)closeButtonTapped:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    [delegate didClosePackageList];
}

@end
