//
//  SettingsViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/27/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "SettingsViewController.h"
#import "LabelTableViewCell.h"
#import "ProfileEditViewController.h"
#import "ChangePasswordViewController.h"
#import "SubscriptionViewController.h"
#import "SectionModel.h"

@interface SettingsViewController ()

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *versionLabel;
@property (strong, nonatomic) NSArray *sectionArray;
@property (nonatomic, assign) int numRequest;
@end

@implementation SettingsViewController

@synthesize numRequest, sectionArray;

-(id)init{
    if(self=[super init]){
        self.sectionArray = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPageCode = MenuPageSettings;
    [self configureView];
    [self.myTableView reloadData];
    [self checkNewNotificationSettings];
}

-(void)checkNewNotificationSettings{
    User *currentUser = [User fetchLoginUser];
    NSLog(@"settings: %@", currentUser.user_settings);
    if(!currentUser.user_settings.settings_like_notif){
        [User getShowUserProfileWithAccesToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation * _Nonnull operation, User * _Nonnull user) {
            [TheSettingsManager saveCurrentUserId:user.user_id];
        } failure:^(RKObjectRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            return;
        }];
    }
}

-(void)configureView{

    [self.myTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.myTableView registerNib:[UINib nibWithNibName:[SwitchTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([SwitchTableViewCell class])];
    
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:nil imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
    [lButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];

    self.versionLabel.text = [NSString stringWithFormat:@"version %@ \n build %@", version, build];
    self.myTableView.tableFooterView = self.footerView;
    
    SectionModel *sec0 = [[SectionModel alloc] init];
    sec0.cellArray = @[_editCell, _passCell, _packageCell];
    
    SectionModel *sec1 = [[SectionModel alloc] init];
    sec1.cellArray = @[];
    
    SectionModel *sec2 = [[SectionModel alloc] init];
    sec2.cellArray = @[_privacyCell, _logoutCell];
    
    self.sectionArray = @[sec0, sec1, sec2];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableView delegate
////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SectionModel *sec = sectionArray[section];
    if(section == 1){ // for notification array
        return 5.0;
    }
    
    return sec.cellArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        return 112.0;
    }
    return 58.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    view.backgroundColor = HEXCOLOR(0xf0f4f4FF);
    CustomRegularLabel *label = [[CustomRegularLabel alloc] initWithFrame:CGRectMake(18, 20, 147, 30)];
    label.text = section==0?@"ACCOUNT":section==1?@"NOTIFICATIONS":@"";
    [label setFont:[UIFont fontWithName:InterfaceStr(@"defaul_font_regular") size:14]];
    label.textColor = HEXCOLOR(0x6D6D72FF);
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    return view;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if(indexPath.section == 1){
        SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SwitchTableViewCell reuseIdentifier]];
        
        cell.delegate = self;
        User *currentUser = CURRENT_USER();
        
        switch (indexPath.row) {
            case 0:{
                cell.titleLabel.text = @"New Upload";
                cell.descLabel.text = @"Get New Upload notifications from people you follow.";
                cell.myID = @"upload_notification";
                [cell.theSwitch setOn: [currentUser.user_settings.settings_upload_notif boolValue]];
            }break;
                
            case 1:{
                cell.titleLabel.text = @"Mentions";
                cell.descLabel.text = @"Receive notifications when people mention your Comment.";
                cell.myID = @"mention_notification";
                [cell.theSwitch setOn: [currentUser.user_settings.settings_mention_notif boolValue]];
            }break;
                
            case 2:{
                cell.titleLabel.text = @"Likes";
                cell.descLabel.text = @"Receive notifications when people like your Video.";
                cell.myID = @"like_notification";
                [cell.theSwitch setOn: [currentUser.user_settings.settings_like_notif boolValue]];
            }break;
                
            case 3:{
                cell.titleLabel.text = @"New Followers";
                cell.descLabel.text = @"Get New Follower notifications from anyone who following you.";
                cell.myID = @"follow_notification";
                [cell.theSwitch setOn: [currentUser.user_settings.settings_follow_notif boolValue]];
            }break;
                
            case 4:{
                cell.titleLabel.text = @"Comments";
                cell.descLabel.text = @"Receive notifications when people comment your Video.";
                cell.myID = @"comment_notification";
                [cell.theSwitch setOn: [currentUser.user_settings.settings_comment_notif boolValue]];
            }break;
                
            default:
                break;
        }
        
        return cell;
    }
    
    SectionModel *sec = sectionArray[indexPath.section];
    return sec.cellArray[indexPath.row];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if(indexPath.section != 1){
        SectionModel *sec = sectionArray[indexPath.section];
        UITableViewCell *cell = sec.cellArray[indexPath.row];
        if (cell == _editCell) {
            ProfileEditViewController *vc = [[ProfileEditViewController alloc] initWithUser:[User fetchLoginUser]];
            [self.navigationController pushViewController:vc animated:YES];
        }else if(cell == _passCell){
            ChangePasswordViewController *vc = [[ChangePasswordViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }else if(cell == _packageCell){
            SubscriptionViewController *vc = [[SubscriptionViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }else if(cell == _privacyCell){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/privacy-policy",ConstStr(@"website_url")]]];
        }else if(cell == _logoutCell){
            if(![self connected]){
                [self showAlertWithMessage:@"Tidak ada koneksi internet"];
                return;
            }
            [self doLogoutUser];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section != 1){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.contentView.backgroundColor = HEXCOLOR(0xEEEEEEFF);
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1)
        return NO;
    return YES;
}

#pragma mark - CustomCell Delegate
-(void)switchTableViewCell:(SwitchTableViewCell *)cell switchValueDidChange:(UISwitch *)sender{
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@(cell.theSwitch.isOn) forKey:cell.myID];
    [self saveSettings:dict];
}

-(void)doLogoutUser{
    
    [self.view startLoader:YES disableUI:NO];
    
    [User logoutWithCompletion:^(NSString *message) {
        [self.view startLoader:NO disableUI:NO];
        [self.navigationController popViewControllerAnimated:YES];
        [TheAppDelegate logoutSuccess];
        [TheSettingsManager saveCurrentUserId:nil];
    } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.view startLoader:NO disableUI:NO];
        
        NSUInteger statusCode = operation.response.statusCode;
        if(statusCode == StatusCodeExpired){
            [TheServerManager requestAccessTokenWithCompletion:^(NSString *accessToken) {
                [User logoutWithCompletion:^(NSString *message) {
                    [TheAppDelegate logoutSuccess];
                } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [TheAppDelegate writeLog:error.description];
                    NSUInteger statusCode = operation.response.statusCode;
                    if(statusCode == StatusCodeExpired){
                        [TheServerManager requestAccessTokenWithCompletion:^(NSString *accessToken) {
                            
                            if(numRequest<kRequestLimit){
                                numRequest++;
                                [self doLogoutUser];
                            }
                            else return;
                            
                        } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            [TheAppDelegate writeLog:error.description];
                        }];
                    }else if (statusCode == StatusCodeForbidden){
                        [TheAppDelegate logoutSuccess];
                    }
                    else{
                        
                        NSUInteger statusCode = operation.response.statusCode;
                        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.responseData){
                            NSData *responseData = operation.responseData;
                            NSDictionary* json = [NSJSONSerialization
                                                  JSONObjectWithData:responseData //1
                                                  options:NSJSONReadingMutableLeaves
                                                  error:nil];
                            NSString *message = json[@"error"][@"messages"][0];
                            [self showLocalValidationError:message];
                        }
                    }
                    WRITE_LOG(operation.responseString);
                }];
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [TheAppDelegate writeLog:error.description];
            }];
        }else if (statusCode == StatusCodeForbidden){
            [TheAppDelegate logoutSuccess];
        }
    }];
}

#pragma mark - IBAction

-(void)saveSettings:(NSDictionary *)dict{
    
    [Settings setUserSetting:dict withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Settings *result) {
        
        [User getShowUserProfileWithAccesToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation * _Nonnull operation, User * _Nonnull user) {
            return;
        } failure:^(RKObjectRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            return;
        }];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
        }
    }];
}
@end
