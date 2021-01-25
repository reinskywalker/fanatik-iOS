//
//  ParentViewController.h
//  Urband Sport Finder
//
//  Created by Teguh Hidayatullah on 10/4/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "MZFormSheetController.h"
#import "Clip.h"
#import "Club.h"
#import "Thread.h"
#import "UserUploads.h"
#import "GAITrackedViewController.h"
#import "IBActionSheet.h"
#import "EmptyLabelTableViewCell.h"

extern int const kActionSheetPlaylist;
extern int const kActionSheetClub;
extern int const kActionSheetThread;
extern int const kActionSheetThreadComment;

typedef enum{
    kFormElementTypeTextfield = 0,
    kFormElementTypeSecureTextfield = 1,
    kFormElementTypeLabel = 2,
    kFormElementTypeDatePicker = 3
}kFormElementType;

@interface ParentViewController : GAITrackedViewController<UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) IBActionSheet *customIBAS;
@property (nonatomic,copy) NSString *appName;
@property (nonatomic, assign) BOOL isNavigationBarHidden;
@property (nonatomic,retain) IBOutlet UIButton *menuButton;
@property (nonatomic, copy) NSString *pageTitle;
@property (nonatomic, retain) MZFormSheetController *formSheet;
@property (nonatomic, retain) Clip *currentClip;
@property (nonatomic, retain) Club *currentClub;
@property (nonatomic, retain) UserUploads *currentUserUpload;
@property (nonatomic, retain) Thread *currentThread;
@property (nonatomic, assign) BOOL isTableEmpty;
@property (nonatomic, copy) NSString *currentPageCode;
@property (nonatomic, retain) ApplicationMenuModel *currentApplicationMenu;
@property (nonatomic, retain) UserUploadsModel *currentUserUploadsModel;
@property (nonatomic, copy) NSString *pageObjectName;
@property(nonatomic, retain) UIAlertView *resultAlertView;
@property(nonatomic, retain) UIImagePickerController *imagePickerController;
@property(nonatomic, retain) Event *currentEvent;
@property(nonatomic, retain) Contest *currentContest;

-(void)commonInit;
-(id)initWithNibName:(NSString *)name;

-(void)showLocalValidationError:(NSString *)errorMessage;
-(void)showAlertWithMessage:(NSString *)message;

-(void)addToPlaylist:(Clip *)clip;
-(void)moreButtonTappedForClip:(Clip *)clip;
-(void)moreButtonTappedForUserUpload:(UserUploads *)uu;
-(void)moreButtonTappedForClub:(Club *)club;
#pragma mark - UIKeyboard observer
- (void)addKeyboardbserver;
- (void)removeKeyboardbserver;

#pragma mark - keyboard action
- (void)keyboardWillShow:(NSNotification *)notification;

- (void)keyboardWillHide:(NSNotification *)notification;

- (void)keyboardDidShow:(NSNotification *)notification;

- (void)keyboardDidHide:(NSNotification *)notification;

- (void)keyboardDidChangeFrame:(NSNotification *)notification;

- (void)keyboardWillShowWithRect:(CGRect)keyboardRect;

- (void)keyboardWillHideWithRect:(CGRect)keyboardRect;

- (void)keyboardDidShowWithRect:(CGRect)keyboardRect;

- (void)keyboardDidHideWithRect:(CGRect)keyboardRect;

- (void)keyboardDidChangeFrameWithRect:(CGRect)keyboardRect;

- (IBAction)backButtonTapped:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;
- (void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
-(void)showAlbum;
-(BOOL)connected;
@end
