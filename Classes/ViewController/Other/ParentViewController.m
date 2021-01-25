//
//  ParentViewController.m
//  Urband Sport Finder
//
//  Created by Teguh Hidayatullah on 10/4/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "PlaylistViewController.h"
#import "IBActionSheet.h"
#import "PostDialogViewController.h"
#import "CreateThreadViewController.h"
#import "MenuViewController.h"
#import "HomeViewController.h"
#import "VideoCategoryDashboardViewController.h"
#import "VideoCategoryViewController.h"
#import "UIAlertView+Blocks.h"
#import "Reachability.h"
#import "CSNotificationView.h"
#import "UploadVideoViewController.h"
#import "LiveChatDetailViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "ContestDetailViewController.h"

@interface ParentViewController()<PlaylistViewControllerDelegate, IBActionSheetDelegate, PostDialogViewControllerDelegate>

@property(nonatomic, retain) CSNotificationView *navBarNotification;

@end

@implementation ParentViewController
int const kActionSheetPlaylist = 210;
int const kActionSheetClub = 220;
int const kActionSheetUserUpload = 230;
int const kActionSheetThread = 212;
int const kActionSheetThreadComment = 2121;

@synthesize appName, isNavigationBarHidden, menuButton, currentClip, currentApplicationMenu, currentUserUploadsModel, currentUserUpload, pageObjectName, imagePickerController;
@synthesize currentEvent, currentContest;

-(void)commonInit{
    if([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        [self commonInit];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self=[super initWithCoder:aDecoder]){
        [self commonInit];
    }
    return self;
}

-(id)init{
    
    NSString *nibName = [NSString stringWithFormat:@"%@%@",NSStringFromClass([self class]),@""];
    self.isNavigationBarHidden = NO;
    
    if(self = [super initWithNibName:nibName bundle:nil]){
        [self commonInit];
    }
    
    return self;
}

-(id)initWithNibName:(NSString *)name{
    if(self = [super initWithNibName:name bundle:nil]){
        [self commonInit];
    }
    
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:nil imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
    [lButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    if (![self isKindOfClass: [MenuViewController class]]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowFailedNotification:) name:kShowFailedNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenLoginPageNotification:) name:kOpenLoginPageNotification object:nil];
    
    
    [self addKeyboardbserver];
    if(![self connected]){
        [self showAlertWithMessage:@"Tidak ada koneksi internet"];
        return;
    }
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![self isKindOfClass: [MenuViewController class]]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetPushNotification:) name:kGetPushNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetInAppPushNotifcation:) name:kGetInAppPushNotification object:nil];
        
    }
    currentApplicationMenu = [TheDatabaseManager getApplicationMenudByPageCode:_currentPageCode];
    
    NSLog(@"curr app menu :%@", currentApplicationMenu);
    if (self.currentApplicationMenu.pageTitle && ![self.currentApplicationMenu.pageTitle isEqualToString:@"-"] && ![self isKindOfClass:[LiveChatDetailViewController class]])
    {
        self.navigationItem.title = self.currentApplicationMenu.pageTitle;
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:InterfaceStr(@"default_font_bold") size:17]}];
    }
    NSString *GAScreenName = [NSString stringWithFormat:@"iOS - %@",self.currentApplicationMenu.pageName? self.currentApplicationMenu.pageName : NSStringFromClass([self class])];
    if([self.currentApplicationMenu.pageCode isEqualToString:MenuPageLiveChatDetail] ||
       [self.currentApplicationMenu.pageCode isEqualToString:MenuPageVideoDetail] ||
       [self.currentApplicationMenu.pageCode isEqualToString:MenuPageClubDetail] ||
       [self.currentApplicationMenu.pageCode isEqualToString:MenuPageContestDetail] ||
       [self.currentApplicationMenu.pageCode isEqualToString:MenuPageProfile] ||
       [self.currentApplicationMenu.pageCode isEqualToString:MenuPageThreadDetail] ||
       [self.currentApplicationMenu.pageCode isEqualToString:MenuPageTVChannelDetail] ||
       [self.currentApplicationMenu.pageCode isEqualToString:MenuPageEventDetail]){
        
        if (self.pageObjectName && ![self.pageObjectName isEqualToString:@""]) {
            GAScreenName = [GAScreenName stringByAppendingString:[NSString stringWithFormat:@" - %@",self.pageObjectName]];
        }
        
    }

    self.screenName = GAScreenName;
    NSLog(@"screenName: %@",self.screenName);
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGetInAppPushNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGetPushNotification object:nil];
}


#pragma mark - Notification Handlers
-(void)handleOpenLoginPageNotification:(NSNotification *)notif{
// handle completion here
    [self presentViewController:[[HomeViewController alloc] initByPresenting] animated:YES completion:nil];
}

-(void)handleShowFailedNotification:(NSNotification *)notif{
    NSLog(@"class gw: %@",NSStringFromClass([self class]));
    [self showAlertWithMessage:@"Pembelian Anda gagal, silahkan coba beberapa saat lagi"];
}

-(void)handleGetPushNotification:(NSNotification *)notif{
    if ([self isKindOfClass:[HomeViewController class]]) {
        [TheAppDelegate loginSuccessAndShouldDismiss:NO];
    }
    
    NSLog(@"cont: %@ | nav: %@",NSStringFromClass([self class]), self.navigationController);
    NSString *pageName = notif.userInfo[@"application_page"];
    NSNumber *pageParam = notif.userInfo[@"id"];

    [TheSettingsManager saveSelectedMenu:pageName];
    if([[RowMenu mainMenuSet] containsObject:pageName]){
        [self.navigationController popToRootViewControllerAnimated:NO];
        [TheAppDelegate changeCenterController:[TheAppDelegate getViewControllerById:pageName withParamId:pageParam]];
    }else{
        [self performBlock:^{
            [self.navigationController pushViewController:[TheAppDelegate getViewControllerById:pageName withParamId:pageParam] animated:YES];
        } afterDelay:1];
        
    }

}

-(void)handleGetInAppPushNotifcation:(NSNotification *)notif{
    [self.navBarNotification setVisible:NO animated:YES completion:nil];
    self.navBarNotification = nil;
    
    NSLog(@"cont: %@ | nav: %@",NSStringFromClass([self class]), self.navigationController);
    if(self.navigationController == nil){
        return;
    }
    self.navBarNotification =
    [CSNotificationView notificationViewWithParentViewController:self.navigationController
                                                       tintColor:[UIColor colorWithRed:1.000 green:1.0 blue:1.000 alpha:0.8]
                                                           image:nil message:notif.userInfo[@"aps"][@"alert"]];
    

    
    __block typeof(self) welf = self;
    self.navBarNotification.tapHandler = ^{
        [[UIDevice currentDevice] setValue:
         [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                    forKey:@"orientation"];
        [welf.navBarNotification setVisible:NO animated:YES completion:nil];
        welf.navBarNotification = nil;
        if ([welf isKindOfClass:[HomeViewController class]]) {
            [TheAppDelegate loginSuccessAndShouldDismiss:NO];
        }
        
        NSString *pageName = notif.userInfo[@"application_page"];
        NSNumber *pageParam = notif.userInfo[@"params"][@"id"];
        [TheSettingsManager saveSelectedMenu:pageName];
        [welf.navigationController pushViewController:[TheAppDelegate getViewControllerById:pageName withParamId:pageParam] animated:YES];
    };
    
    [self.navBarNotification setVisible:YES animated:YES completion:^{

        double delayInSeconds = 4.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [welf.navBarNotification setVisible:NO animated:YES completion:nil];
            welf.navBarNotification = nil;
        });
        
    }];
    
}


#pragma mark - IBActions
-(IBAction)backButtonTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)closeButtonTapped:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Common Method

-(void)showLocalValidationError:(NSString *)errorMessage{
    NSString *title = [NSString stringWithFormat:@"%@ Error",appName];
    UIAlertView *resultAlertView = [[UIAlertView alloc] initWithTitle:title message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [resultAlertView show];
}

-(void)showAlertWithMessage:(NSString *)message{
    if(!message || [message isEqualToString:@""]){
        message = @"Error.  Silahkan Coba Lagi.";
    }
    UIAlertView *resultAlertView = [[UIAlertView alloc] initWithTitle:appName message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [resultAlertView show];
}

#pragma mark - PlaylistViewController Delegate

-(void)addToPlaylist:(Clip *)clip{

    if([User fetchLoginUser]){
        PlaylistViewController *vc = [[PlaylistViewController alloc] initWithClip:clip];
        vc.delegate = self;
        self.formSheet = nil;
        self.formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
        self.formSheet.shouldDismissOnBackgroundViewTap = YES;
        self.formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
        self.formSheet.cornerRadius = 5.0;
        float height = 260;
        self.formSheet.portraitTopInset = ([UIScreen mainScreen].bounds.size.height - height) / 2;
        self.formSheet.landscapeTopInset = 6.0;
        self.formSheet.presentedFormSheetSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width - 50, height);
        
        
        self.formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
            presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
        };
        
        
        
        [self mz_presentFormSheetController:self.formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            
        }];
    }else{
    
    [UIAlertView showWithTitle:appName
                       message:@"Anda harus login untuk membuat playlist."
             cancelButtonTitle:@"OK"
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                             [self presentViewController:[[HomeViewController alloc] initByPresenting] animated:YES completion:nil];
                          }
                      }];
    }
}

-(void)playlistViewController:(PlaylistViewController *)vc closeButtonDidTap:(id)sender{
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

-(void)playlistViewController:(PlaylistViewController *)vc newPlaylistButtonDidTap:(id)sender{
    
}

#pragma mark - Public Method
-(void)moreButtonTappedForClip:(Clip *)clip{
    NSString *title;
    
    if(!self.customIBAS.visible){
        self.customIBAS = nil;
        self.customIBAS = [[IBActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Close" destructiveButtonTitle:nil otherButtonTitles:@"Share", @"Add to Playlist", nil];
        self.customIBAS.userObject = clip;
        self.customIBAS.blurBackground = NO;
        [self.customIBAS setFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:14.0]];
        [self.customIBAS setButtonBackgroundColor:HEXCOLOR(0xFFFFFFFF)];
        [self.customIBAS setButtonTextColor:HEXCOLOR(0x3399FFFF)];
        [self.customIBAS setButtonTextColor:[UIColor redColor] forButtonAtIndex:2];
        [self.customIBAS setCancelButtonIndex:2];
        self.customIBAS.buttonResponse = IBActionSheetButtonResponseFadesOnPress;
        self.customIBAS.tag = kActionSheetPlaylist;
        [self.customIBAS showInView:self.view];
    }else{
        NSLog(@"ha:%ld",(long)self.customIBAS.cancelButtonIndex);
        [self.customIBAS dismissWithClickedButtonIndex:self.customIBAS.numberOfButtons-1 animated:YES];
    }
}

-(void)moreButtonTappedForUserUpload:(UserUploads *)uu{
    NSString *title;

    
    if(!self.customIBAS.visible){
        self.customIBAS = nil;
        
        self.currentUserUploadsModel = [TheDatabaseManager getUserUploadsModelById:uu.user_uploads_id];

        if(currentUserUploadsModel.user_uploads_status == UserUploadStatusIncomplete){
            self.customIBAS = [[IBActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Tutup" destructiveButtonTitle:nil otherButtonTitles:@"Reupload", @"Hapus", nil];
        }else if(currentUserUploadsModel.user_uploads_status == UseruploadStatusOnProgress){
            self.customIBAS = [[IBActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Tutup" destructiveButtonTitle:nil otherButtonTitles:@"Batal Upload", @"Hapus", nil];
        }else{
            self.customIBAS = [[IBActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Tutup" destructiveButtonTitle:nil otherButtonTitles:@"Hapus", nil];
        }
        
        self.customIBAS.userObject = uu;
        self.customIBAS.blurBackground = NO;
        [self.customIBAS setFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:14.0]];
        [self.customIBAS setButtonBackgroundColor:HEXCOLOR(0xFFFFFFFF)];
        [self.customIBAS setButtonTextColor:HEXCOLOR(0x3399FFFF)];
        [self.customIBAS setButtonTextColor:[UIColor redColor] forButtonAtIndex:1];
        [self.customIBAS setCancelButtonIndex:1];
        self.currentUserUpload = uu;
        self.customIBAS.buttonResponse = IBActionSheetButtonResponseFadesOnPress;
        self.customIBAS.tag = kActionSheetUserUpload;
        [self.customIBAS showInView:self.view];
        
    }else{
        NSLog(@"ha:%ld",(long)self.customIBAS.cancelButtonIndex);
        [self.customIBAS dismissWithClickedButtonIndex:self.customIBAS.numberOfButtons-1 animated:YES];
    }
}

-(void)moreButtonTappedForClub:(Club *)club{
    NSString *title;
    
    if(!self.customIBAS.visible){
        self.customIBAS = [[IBActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Close" destructiveButtonTitle:nil otherButtonTitles:@"New Thread", nil];
        self.customIBAS.blurBackground = NO;
        [self.customIBAS setFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:14.0]];
        
        [self.customIBAS setButtonBackgroundColor:HEXCOLOR(0xFFFFFFFF)];
        [self.customIBAS setButtonTextColor:HEXCOLOR(0x3399FFFF)];
        [self.customIBAS setButtonTextColor:[UIColor redColor] forButtonAtIndex:self.customIBAS.numberOfButtons-1];
        [self.customIBAS setCancelButtonIndex:1];
        self.currentClub = club;
        self.customIBAS.buttonResponse = IBActionSheetButtonResponseFadesOnPress;
        self.customIBAS.tag = kActionSheetClub;
        [self.customIBAS showInView:self.view];
    }else{
        NSLog(@"ha:%ld",(long)self.customIBAS.cancelButtonIndex);
        [self.customIBAS dismissWithClickedButtonIndex:self.customIBAS.numberOfButtons-1 animated:YES];
    }
}

#pragma mark - UIImagePickerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSLog(@"metadata : %@, type : %@",[info objectForKey:UIImagePickerControllerMediaMetadata], [info objectForKey:UIImagePickerControllerMediaType]);
    
    NSURL *urlvideo = [info objectForKey:UIImagePickerControllerMediaURL];
    NSLog(@"urlvideo is :::%@",urlvideo);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UploadVideoViewController *uploadVC = nil;
    if([self isKindOfClass:[ProfileViewController class]]){
        uploadVC = [[UploadVideoViewController alloc] initWithUserUpload:self.currentUserUpload andUserUploadsModel:self.currentUserUploadsModel];
    }else if([self isKindOfClass:[ContestDetailViewController class]]){
        uploadVC = [[UploadVideoViewController alloc] initWithContest:self.currentContest andUserUploadsModel:nil];
    }else if([self isKindOfClass:[EventDetailViewController class]]){
        uploadVC = [[UploadVideoViewController alloc] initWithEvent:self.currentEvent andUserUploadsModel:nil];
    }else{
        uploadVC = [[UploadVideoViewController alloc] initWithContest:nil andUserUploadsModel:nil];
    }
    
    uploadVC.videoURL = urlvideo;
    uploadVC.fileFormat = [urlvideo pathExtension];
    
    CustomNavigationController *navCon = [[CustomNavigationController alloc]initWithRootViewController:uploadVC];
    [self presentViewController:navCon animated:YES completion:nil];
}

-(void)showAlbum{
    imagePickerController= [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeMovie, nil];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }];
    }
    else{
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - IBActionSheet/UIActionSheet Delegate Method

// the delegate method to receive notifications is exactly the same as the one for UIActionSheet
- (void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag == kActionSheetPlaylist){
        switch (buttonIndex) {
            case 0:{
                NSString* someText = self.currentClip.clip_shareable.shareable_content;
                NSURL* linkText = [[NSURL alloc] initWithString: self.currentClip.clip_shareable.shareable_url];
                NSArray* dataToShare = [NSArray arrayWithObjects: someText,linkText, nil];
                UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
                activityViewController.excludedActivityTypes = @[ UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypePrint ];
                [self presentViewController:activityViewController animated:YES completion:^{}];

            }
                break;
            case 1:{
                [self addToPlaylist:actionSheet.userObject];
            }
                break;
            default:
                break;
        }
    }else if(actionSheet.tag == kActionSheetClub){
        
        NSString *titleButton = [actionSheet buttonTitleAtIndex:buttonIndex];
        if([titleButton isEqualToString:@"Buat Thread"]){
            
            CreateThreadViewController *vc = [[CreateThreadViewController alloc] initWithClub:self.currentClub];
            CustomNavigationController *navController = [[CustomNavigationController alloc] initWithRootViewController:vc];
            navController.navigationBarHidden = YES;
            [self presentViewController:navController animated:YES completion:nil];
        }
    }
}

#pragma mark - PostDialogViewController delegate
-(void)dialogDidCancel:(PostDialogViewController *)dialog
{
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
    
}

-(void)dialogDidPost:(PostDialogViewController *)dialog withString:(NSString *)content
{
    
    
}

#pragma mark - UIKeyboard observer
- (void)addKeyboardbserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
}
- (void)removeKeyboardbserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

#pragma mark - keyboard action
- (void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    [self keyboardWillShowWithRect:keyboardRect];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    [self keyboardWillHideWithRect:keyboardRect];
}

- (void)keyboardDidShow:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    [self keyboardDidShowWithRect:keyboardRect];
}

- (void)keyboardDidHide:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    [self keyboardDidHideWithRect:keyboardRect];
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    [self keyboardDidChangeFrameWithRect:keyboardRect];
}

- (void)keyboardWillShowWithRect:(CGRect)keyboardRect{
    
}

- (void)keyboardWillHideWithRect:(CGRect)keyboardRect{
    
}

- (void)keyboardDidShowWithRect:(CGRect)keyboardRect{
    
}

- (void)keyboardDidHideWithRect:(CGRect)keyboardRect{
    
}

- (void)keyboardDidChangeFrameWithRect:(CGRect)keyboardRect{
    
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    NSURLCache * const urlCache = [NSURLCache sharedURLCache];
    const NSUInteger memoryCapacity = urlCache.memoryCapacity;
    urlCache.memoryCapacity = 0;
    urlCache.memoryCapacity = memoryCapacity;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}
@end
