//
//  CheckoutViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "CheckoutViewController.h"
#import "PaymentMethodTableViewCell.h"
#import "PackageHeaderTableViewCell.h"

@interface CheckoutViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *paymentGroupsArray;
@property (nonatomic, retain) NSMutableArray *paymentMethodsArray;
@property (nonatomic, retain) Package *currentPackage;
@property (nonatomic, retain) NSMutableDictionary *objDictionary;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic, retain) Payment *currentPayment;

@end


@implementation CheckoutViewController
@synthesize shouldPresent, didPresent;

-(id)initWithPackage:(Package *)package{
    if(self=[super init]){
        self.currentPackage = package;
        self.paymentGroupsArray = [NSMutableArray array];
        self.paymentMethodsArray = [NSMutableArray array];
        self.objDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.myTableView registerNib:[UINib nibWithNibName:[PaymentMethodTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[PaymentMethodTableViewCell reuseIdentifier]];
    [self.myTableView registerNib:[UINib nibWithNibName:[PackageHeaderTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[PackageHeaderTableViewCell reuseIdentifier]];
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:@"Pembayaran" imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
    [lButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    if(didPresent){
        [self.leftButton setTitle:@"Tutup" forState:UIControlStateNormal];
        [self.leftButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [self.leftButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.leftButton setTitle:@"" forState:UIControlStateNormal];
        [self.leftButton setImage:[UIImage imageNamed:@"leftArrow"] forState:UIControlStateNormal];
        [self.leftButton setImage:[UIImage imageNamed:@"leftArrowHighlighted"] forState:UIControlStateSelected];
        [self.leftButton setImage:[UIImage imageNamed:@"leftArrowHighlighted"] forState:UIControlStateHighlighted];
        self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    }


    [self getDataFromServer];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getDataFromServer{
    [PaymentGroup getPaymentGroupWithAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *resultsArray) {
        [self.paymentGroupsArray addObjectsFromArray:resultsArray];
        [self sortResultsArray];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
        }
    }];
}

-(void)sortResultsArray{
    int sectionCount = (int)self.paymentGroupsArray.count;
    for (int i = 0 ; i < sectionCount; i++) {
        PaymentGroup *group = [self.paymentGroupsArray objectAtIndex:i];
        NSArray *tempPaymentArray = [group.paymentgroup_payment allObjects];
        NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"payment_id" ascending:YES];
        NSArray *paymentArray = [tempPaymentArray sortedArrayUsingDescriptors:@[sort1]];
        
        [self.paymentMethodsArray addObject:paymentArray];
    }
    [self.myTableView reloadData];
}

#pragma mark - UITableViewDelegate & Datasource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0)
        return 135.0;
    return 44.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.paymentGroupsArray.count +1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0)
        return 1;
    return [self.paymentMethodsArray[section-1] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell ;
    if(indexPath.section == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:[PackageHeaderTableViewCell reuseIdentifier]];
        [(PackageHeaderTableViewCell *) cell fillWithPackage:self.currentPackage andIsFavorite:NO];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:[PaymentMethodTableViewCell reuseIdentifier]];
        BOOL isFirstRow = indexPath.row == 0 ? YES : NO;
        BOOL isChecked = [self.selectedIndexPath isEqual:indexPath] ? YES : NO;
        [(PaymentMethodTableViewCell *)cell fillWithPayment:self.paymentMethodsArray[indexPath.section -1][indexPath.row] andIsChecked:isChecked andIsFirstRow:isFirstRow];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section > 0)
        return 50.0;
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section >0){
        PaymentGroup *group = self.paymentGroupsArray[section-1];
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.myTableView.frame.size.width, 50.0)];
        headerView.backgroundColor = HEXCOLOR(0xebebebff);
        
        CustomBoldLabel *titleLabel = [[CustomBoldLabel alloc] initWithFrame:CGRectMake(15, 5, 266, 21)];
        [titleLabel setFont:[UIFont fontWithName:InterfaceStr(@"default_font_bold") size:14.0]];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.backgroundColor = [UIColor clearColor];
        NSLog(@"%@",group.paymentgroup_name);
        titleLabel.text = group.paymentgroup_name;
        [headerView addSubview:titleLabel];
        [titleLabel sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:headerView inset:15.0];
        [titleLabel sdc_alignVerticalCenterWithView:headerView];
        [titleLabel sdc_pinWidth:266];
        [titleLabel sdc_pinHeight:21];
        return headerView;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.myTableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.section > 0){
        self.selectedIndexPath = indexPath;
        self.currentPayment = self.paymentMethodsArray[indexPath.section-1][indexPath.row];
        [self.myTableView reloadData];
    }
}


#pragma mark - IBActions
- (IBAction)nextButtonTapped:(id)sender {
    NSArray *idsArray = [NSArray arrayWithObjects:self.currentPackage.package_id, nil];
    [self.view startLoader:YES disableUI:YES];
    [Payment orderWithPackageIdArray:idsArray andPaymentId:self.currentPayment.payment_id withAccessToken:ACCESS_TOKEN() andCompletion:^(NSString *orderID) {
        NSString *baseAPI =  [TheConstantsManager getStringProperty:@"server_url"];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/orders/%@/payment-methods/%@?access_token=%@&last_page=%@",baseAPI,orderID,self.currentPayment.payment_id, ACCESS_TOKEN(),TheSettingsManager.selectedMenu]];
        WebViewController *vc = [[WebViewController alloc] initWithURL:url];
        vc.didPresent = shouldPresent;
        vc.currentOrderID = orderID;
        [self.view startLoader:NO disableUI:NO];
        if(shouldPresent){
            [self presentViewController:vc animated:YES completion:nil];
        }else{
            [self.navigationController pushViewController:vc animated:YES];
        }
    } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.view startLoader:NO disableUI:NO];
        NSUInteger statusCode = operation.response.statusCode;
        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
            [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
        }
        
        
        NSLog(@"%@",error.userInfo);
    }];
    
}


@end
