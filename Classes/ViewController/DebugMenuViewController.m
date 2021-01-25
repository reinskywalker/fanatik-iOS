//
//  DebugMenuViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 10/4/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "DebugMenuViewController.h"
#import "TimelineViewController.h"
@interface DebugMenuViewController ()

@property NSMutableArray *objects;
@end

@implementation DebugMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.menuOptions = [NSArray arrayWithObjects:@"Request Access Token", @"Request Profile User", @"Request User 11", @"Request user followers", @"Request user following",
                        @"Request User Clip", @"Request Clip By ID", @"Get All Live", @"Get Live By ID", @"Get All Playlist", @"Get All Activities", @"Login", @"Timeline", @"Menu", @"Logout", nil]; // menu options strings
    self.myTableView.backgroundColor = [UIColor darkGrayColor];
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.myTableView registerNib:[UINib nibWithNibName:@"SideMenuCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([SideMenuCell class])];
    [self.myTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
  }



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.menuOptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // example using a custom UITableViewCell
    static NSString *CellIdentifier = @"SideMenuCell";
    SideMenuCell *customCell = (SideMenuCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!customCell) {
        customCell = [[SideMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    customCell.cellLabel.text = [self.menuOptions objectAtIndex:indexPath.row];
    
   
    
    return customCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // controls your menu selection but first remove what is currently loaded
    switch (indexPath.row) {
        case 0:{
            [TheServerManager requestAccessTokenWithCompletion:nil andFailure:nil];
        }
            
            break;
        case 1:{
            [User getShowUserProfileWithAccesToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, User *user) {
                [TheAppDelegate writeLog:@"success"];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [TheAppDelegate writeLog:error.description];
            }]  ;
        }
            break;
        case 2:{
            [User getShowUserWithId:@"11" andAccesToken:ACCESS_TOKEN()  success:^(RKObjectRequestOperation *operation, User *user) {
                [TheAppDelegate writeLog:@"success"];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [TheAppDelegate writeLog:error.description];
            }]  ;
        }
            break;
        case 3:{
//            [User getUserFollowersWithId:@"11" andAccesToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *usersArray) {
//                NSLog(@"%@",usersArray);
//                [TheAppDelegate writeLog:@"success"];
//            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//                [TheAppDelegate writeLog:error.description];
//            }];
        }
            break;
        case 4:{
//            [User getUserFollowingWithId:@"11" andAccesToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *usersArray) {
//                NSLog(@"%@",usersArray);
//            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//            }];
        }
            break;
            
        case 5:{
//            [Clip getClipWithUserId:@"11" withAccessToken:ACCESS_TOKEN() success:nil failure:nil];
        }
            break;
        case 6:{
//            [Clip getClipWithUserId:@"11" andClipId:@"22" withAccessToken:ACCESS_TOKEN() success:nil failure:nil];
        }
            break;
        case 7:{
//            [Live getAllLivewithAccessToken:ACCESS_TOKEN() success:nil failure:nil];
        }
            break;
        case 8:{
//            [Live getLiveWithLiveId:@"1" withAccessToken:ACCESS_TOKEN() success:nil failure:nil];
        }
            break;
        case 9:{
            [Playlist getAllPlaylistWithUserId:@"11" andPageNumber:0 withAccessToken:ACCESS_TOKEN() success:nil failure:nil];
        }
            break;
        case 10:{
//            [Activity getAllActivitiesWithUserId:@"11" withAccessToken:ACCESS_TOKEN() success:nil failure:nil];
        }
            break;
        case 11:{
            NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             @"facebook", @"provider",
                                             @"testing-uid", @"uid",
                                             @"testing-token", @"token",
                                             @"teguh hidayatullah", @"name",
                                             @"fans.1@domikado.com", @"email",
                                             nil];
            [User loginWithUserDictionary:jsonDict withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                NSLog(@"Login OK");
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                NSLog(@"Login FAILED");
            }];
        }
            break;
        case 12:{
            [TheAppDelegate changeCenterController:[[TimelineViewController alloc] init]];
        }
            break;
        case 13:{
            [SectionMenu getSectionMenuWithAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *resultArray) {
                
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                
            }];
        }
            break;
        case 14:{
            [User logoutWithCompletion:^(NSString *message) {
//                [[FBSession activeSession] closeAndClearTokenInformation];
                [TheAppDelegate logoutSuccess];
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSUInteger statusCode = operation.response.statusCode;
                if(statusCode == StatusCodeExpired || statusCode == StatusCodeForbidden){
            if(statusCode == StatusCodeForbidden){
                [TheSettingsManager removeAccessToken];
                [TheSettingsManager removeSessionToken];
                [TheSettingsManager removeCurrentUserId];
                [TheSettingsManager resetSideMenuArray];
                [TheAppDelegate logoutSuccess];
            }
                    [TheServerManager requestAccessTokenWithCompletion:^(NSString *accessToken) {
                        [User logoutWithCompletion:^(NSString *message) {
//                            [[FBSession activeSession] closeAndClearTokenInformation];
                            [TheAppDelegate logoutSuccess];
                            
                        } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            [TheAppDelegate writeLog:error.description];
                        }];
                    } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        [TheAppDelegate writeLog:error.description];
                    }];
                    
                }
            }];
        }
            break;
            
        default:
            break;
    }
}
@end
