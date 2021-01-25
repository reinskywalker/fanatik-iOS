//
//  Menu+functionality.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "RowMenu.h"


#define MenuPageHome  @"Page-3" //Dashboard page first page
#define MenuPageTVChannel  @"Page-27"
#define MenuPagePackages  @"Page-25"
#define MenuPageTimeline  @"Page-14"
#define MenuPageFollowing  @"Page-8"
#define MenuPageMyPackages  @"Page-24"
#define MenuPagePlaylist  @"Page-9"
#define MenuPageLogout  @""
#define MenuPageProfile @"Page-7"
#define MenuPageVideoCategory @"Page-30"
#define MenuPageVideoDetail @"Page-15"
#define MenuPageClub @"Page-31"
#define MenuPageChannel  @"Page-4"
#define MenuPageProfileVideo  @"Page-10"
#define MenuPageUserSearch  @"Page-11"
#define MenuPageVideoSearch  @"Page-12"
#define MenuPagePlaylistSearch @"Page-13"
#define MenuPageForgotPassword @"Page-21"
#define MenuPageLogin @"Page-22"
#define MenuPageRegister @"Page-23"
#define MenuPageTVChannelDetail @"Page-28"
#define MenuPageClubDetail @"Page-32"
#define MenuPageThread @"Page-33"
#define MenuPageThreadDetail @"Page-34"
#define MenuPageCreateThread @"Page-35"
#define MenuPagePlaylistDetail @"Page-36"
#define MenuPageEditProfile @"Page-42"
#define MenuPageSettings @"Page-43"
#define MenuPageChangePassword @"Page-44"
#define MenuPageVideoCategoryDashboard @"Page-45"
#define MenuPageContest @"Page-46"
#define MenuPageContestDetail @"Page-47"
#define MenuPageContestUpload @"Page-48"
#define MenuPageLiveChatList @"Page-49"
#define MenuPageLiveChatDetail @"Page-50"
#define MenuPageEventList @"Page-51"
#define MenuPageEventDetail @"Page-52"
#define MenuPageNotification @"Page-53"

typedef NSString *MenuPage;

@interface RowMenu (functionality)
+(RKEntityMapping *)myMapping;
+(NSSet *)mainMenuSet;
@end
