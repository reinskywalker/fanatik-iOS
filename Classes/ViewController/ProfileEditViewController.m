//
//  ProfileEditViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/23/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ProfileEditViewController.h"
#import "ProfileCustomHeader.h"
#import "ProfileVideoTableViewCell.h"
#import "TimelinePlaylistTableViewCell.h"
#import "TextFieldTableViewCell.h"
#import "LabelTableViewCell.h"
#import "DatePickerTableViewCell.h"
#import "SegmentedControlTableViewCell.h"
#import "ImageDetailViewController.h"

typedef enum{
    kRowUserName = 0,
    kRowName,
    kRowPhone,
    kRowDOBInfo,
    kRowDOBPicker,
    kRowGender,
} kRow;

typedef enum {
    kActionSheetCoverImage = 0,
    kActionSheetAvatarImage
}kActionSheet;

typedef enum{
    kUpdateImageAvatar,
    kUpdateImageCover
}kUpdateImage;

@interface ProfileEditViewController ()<TextFieldTableViewCellDelegate, LabelTableViewCellDelegate, SegmentedControlTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IBActionSheetDelegate>

@property(nonatomic, assign) BOOL isPickerExpanded;
@property(nonatomic, retain) UIDatePicker *myPicker;
@property (nonatomic, retain) NSMutableDictionary *currentProfileDict;
@property(nonatomic, assign) UIEdgeInsets defaultTableInsets;
@property(nonatomic, retain) UIImagePickerController *imagePickerController;

@property(nonatomic, retain) CoverImage *currentCoverImage;
@property(nonatomic, retain) Avatar *currentAvatar;

@property(nonatomic, retain) UIImage *currentImageAvatar;
@property(nonatomic, retain) UIImage *currentImageCover;
@property(nonatomic, assign) kUpdateImage updateImageMode;

@property (nonatomic, retain) NSMutableArray *pickerConstraints;
@property (nonatomic, retain) IBActionSheet *customIBAS;
@end

@implementation ProfileEditViewController
@synthesize currentUser, userImageView, userNameLabel, setAvatarButton, setCoverButton, currentProfileDict;
@synthesize imagePickerController, currentAvatar, currentCoverImage, currentImageAvatar, currentImageCover, updateImageMode;


-(id)initWithUser:(User *)user{
    if(self=[super init]){
        self.currentUser = user;
        self.currentProfileDict = [NSMutableDictionary new];
   }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPageCode = MenuPageEditProfile;
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self configureView];
    [self reloadData];
    if(!self.myPicker){
        NSDateFormatter *df = [TheAppDelegate defaultDateFormatter];
        NSDate *defaultDOB = self.currentUser.user_dob ? self.currentUser.user_dob : [df dateFromString:@"27 Feb 1990"];
        self.myPicker = [[UIDatePicker alloc] init];
        self.myPicker.datePickerMode = UIDatePickerModeDate;
        self.myPicker.date = defaultDOB;
        [self.myPicker addTarget:self action:@selector(datePickerValuChanged) forControlEvents:UIControlEventValueChanged];
    }
}

-(void)saveProfile{
    NSInteger gender = [(SegmentedControlTableViewCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kRowGender inSection:0]] mySegmentedControl].selectedSegmentIndex;;
    switch (gender) {
        case 0:
            self.currentProfileDict[@"gender"] = @"Male";
            break;
        case 1:
            self.currentProfileDict[@"gender"] = @"Female";
        break;
            
        default:
            self.currentProfileDict[@"gender"] = @"Unknown";
            break;
    }
    
    TextFieldTableViewCell *aCell = (TextFieldTableViewCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kRowUserName inSection:0]];
    self.currentProfileDict[@"username"] = aCell.myTextField.text? aCell.myTextField.text : @"";
    aCell = (TextFieldTableViewCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kRowName inSection:0]];
    self.currentProfileDict[@"name"] = aCell.myTextField.text? aCell.myTextField.text : @"";
    aCell = (TextFieldTableViewCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kRowPhone inSection:0]];
    self.currentProfileDict[@"phone"] = aCell.myTextField.text? aCell.myTextField.text : @"";
   
    [self.view startLoader:YES disableUI:YES];
    [User updateProfileForUserId:currentUser.user_id withProfileDictionary:self.currentProfileDict andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [self.view startLoader:NO disableUI:NO];
        [self showAlertWithMessage:@"Profile Berhasil Diupdate"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kProfileUpdatedNotification object:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self.view startLoader:NO disableUI:NO];
        
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
        
            [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
        }
    }];
}
- (void)reloadTableView:(int)startingRow;
{
//    // the last row after added new items
//    int endingRow = 0;
//    if(self.currentProfileMode == ProfileModeVideo)
//        endingRow = (int)[self.clipsArray count];
//    else if(self.currentProfileMode == ProfileModePlaylist)
//        endingRow = (int)[self.playlistsArray count];
//    else if(self.currentProfileMode == ProfileModeActivity)
//        endingRow = (int)[self.activitiesArray count];
//
//    
//    NSMutableArray *indexPaths = [NSMutableArray array];
//    for (; startingRow < endingRow; startingRow++) {
//        [indexPaths addObject:[NSIndexPath indexPathForRow:startingRow inSection:0]];
//    }
//    
//    [self.myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
}

-(void)configureView{
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:nil imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
    [lButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *rButton = [TheAppDelegate createButtonWithTitle:@"Submit"imageName:@"" highlightedImageName:@"" forLeftButton:NO];
    [rButton addTarget:self action:@selector(saveProfile) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithCustomView:rButton];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    [self.myTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    self.defaultTableInsets = self.myTableView.contentInset;
  
    [self.myTableView registerNib:[UINib nibWithNibName:[TextFieldTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[TextFieldTableViewCell reuseIdentifier]];
    [self.myTableView registerNib:[UINib nibWithNibName:[LabelTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[LabelTableViewCell reuseIdentifier]];
    [self.myTableView registerNib:[UINib nibWithNibName:[DatePickerTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[DatePickerTableViewCell reuseIdentifier]];
    [self.myTableView registerNib:[UINib nibWithNibName:[SegmentedControlTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[SegmentedControlTableViewCell reuseIdentifier]];
    
    self.userImageView.layer.cornerRadius = CGRectGetHeight(self.userImageView.frame)/2;
    self.userImageView.layer.masksToBounds = YES;
    [TheInterfaceManager addBorderViewForImageView:self.userImageView withBorderWidth:5.0 andBorderColor:nil];
    

    
    self.setCoverButton.layer.cornerRadius = 1.0;
    self.setCoverButton.layer.masksToBounds = YES;
    self.setCoverButton.layer.borderColor = [self.setCoverButton.titleLabel.textColor CGColor];
    self.setCoverButton.layer.borderWidth = 1.0;
    
    self.setAvatarButton.layer.cornerRadius = 1.0;
    self.setAvatarButton.layer.masksToBounds = YES;
    self.setAvatarButton.layer.borderColor = [self.setCoverButton.titleLabel.textColor CGColor];
    self.setAvatarButton.layer.borderWidth = 1.0;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [self.userCoverImageView setUserInteractionEnabled:YES];
    [self.userCoverImageView addGestureRecognizer:tapGestureRecognizer];
    
    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped:)];
    [self.userImageView setUserInteractionEnabled:YES];
    [self.userImageView addGestureRecognizer:tapGestureRecognizer2];
    
}

- (void)avatarTapped:(UITapGestureRecognizer *)recognizer {
    ImageDetailViewController *vc = [[ImageDetailViewController alloc] initWithImageURL:self.currentUser.user_avatar.avatar_original];
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)backgroundTapped:(UITapGestureRecognizer *)recognizer{
    ImageDetailViewController *vc = [[ImageDetailViewController alloc] initWithImageURL:self.currentUser.user_cover_image.cover_image_original];
    
    [self presentViewController:vc animated:YES completion:nil];
}



-(void)reloadData{
    NSLog(@"imageURL:%@",currentUser.user_avatar.avatar_original);

    [[SDImageCache sharedImageCache] removeImageForKey:currentUser.user_cover_image.cover_image_640 fromDisk:YES withCompletion:^{
        [self.userCoverImageView sd_setImageWithURL:[NSURL URLWithString:currentUser.user_cover_image.cover_image_640] placeholderImage:nil options:SDWebImageRefreshCached];
    }];

    [[SDImageCache sharedImageCache] removeImageForKey:currentUser.user_avatar.avatar_thumbnail fromDisk:YES withCompletion:^{
        [self.userImageView sd_setImageWithURL:[NSURL URLWithString:currentUser.user_avatar.avatar_thumbnail] placeholderImage:nil options:SDWebImageRefreshCached];
    }];
    
    self.userNameLabel.text = currentUser.user_name;
    
    [self.myTableView reloadData];
}




#pragma mark - IBActions
-(void)setCoverButtonTapped:(id)sender{

    self.customIBAS = [[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Kamera", @"Album Foto", @"Tutup", nil];
    self.customIBAS.tag = kActionSheetCoverImage;
    self.customIBAS.blurBackground = NO;
    [self.customIBAS setFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:14.0]];
    [self.customIBAS setButtonBackgroundColor:HEXCOLOR(0xFFFFFFFF)];
    [self.customIBAS setButtonTextColor:HEXCOLOR(0x3399FFFF)];
    [self.customIBAS setButtonTextColor:[UIColor redColor] forButtonAtIndex:2];
    self.customIBAS.buttonResponse = IBActionSheetButtonResponseFadesOnPress;
    self.updateImageMode = kUpdateImageCover;
    [self.customIBAS showInView:self.view];
    
    
}

-(void)setAvatarButtonTapped:(id)sender{
    self.customIBAS = [[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Kamera", @"Album Foto", @"Tutup", nil];
    self.customIBAS.tag = kActionSheetAvatarImage;
    self.customIBAS.blurBackground = NO;
    [self.customIBAS setFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:14.0]];
    [self.customIBAS setButtonBackgroundColor:HEXCOLOR(0xFFFFFFFF)];
    [self.customIBAS setButtonTextColor:HEXCOLOR(0x3399FFFF)];
    [self.customIBAS setButtonTextColor:[UIColor redColor] forButtonAtIndex:2];
    self.customIBAS.buttonResponse = IBActionSheetButtonResponseFadesOnPress;
    self.updateImageMode = kUpdateImageAvatar;
    [self.customIBAS showInView:self.view];
}


#pragma mark - IBActionSheet/UIActionSheet Delegate Method

// the delegate method to receive notifications is exactly the same as the one for UIActionSheet
- (void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    BOOL showCamera = buttonIndex==0;
    BOOL showAlbum  = buttonIndex==1;
    
    if(showCamera || showAlbum){
        
        imagePickerController= [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        
        BOOL letShowImagePicker = (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && showCamera)||
                                   (showAlbum && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]));
        
        if(letShowImagePicker){
            
            imagePickerController.sourceType = showCamera?UIImagePickerControllerSourceTypeCamera:UIImagePickerControllerSourceTypePhotoLibrary;
            
            if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0){
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self presentViewController:imagePickerController animated:YES completion:nil];
                }];
            }
            else{
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }
        }else if(!letShowImagePicker && showCamera){
            [self showAlertWithMessage:@"Kamera Tidak Tersedia"];
        }
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
}

#pragma mark - UIImagePickerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if(updateImageMode == kUpdateImageAvatar){
        self.currentImageAvatar = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.userImageView.image = currentImageAvatar;
        [self.view startLoader:YES disableUI:NO];
        [User updateAvatarImage:currentImageAvatar accessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
            
            self.userImageView.image = currentImageAvatar;
            [self.view startLoader:NO disableUI:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:kProfileUpdatedNotification object:nil];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self.view startLoader:NO disableUI:NO];
            
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
            }
        }];
        
    }else{
        self.currentImageCover = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self.view startLoader:YES disableUI:NO];
        [User updateCoverImage:currentImageCover accessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
            self.userCoverImageView.image = currentImageCover;
            [self.view startLoader:NO disableUI:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:kProfileUpdatedNotification object:nil];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self.view startLoader:NO disableUI:NO];
            
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
            }
        }];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableView delegate
////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == kRowDOBPicker){
        
        self.isPickerExpanded ? [[(DatePickerTableViewCell *)cell datePickerContainer] addSubview:self.myPicker] : [self.myPicker removeFromSuperview];
        if(self.isPickerExpanded){
            self.myPicker.translatesAutoresizingMaskIntoConstraints = NO;
            NSMutableArray *constraints = [NSMutableArray new];
            [constraints addObject:[self.myPicker sdc_alignHorizontalCenterWithView:self.myPicker.superview]];
            [constraints addObject:[self.myPicker sdc_alignVerticalCenterWithView:self.myPicker.superview]];
            
            self.pickerConstraints = constraints;
        }
        else{
            if(self.pickerConstraints){
                [self.myPicker removeConstraints:self.pickerConstraints];
            }
        }
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
        
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == kRowDOBPicker){
        
        return self.isPickerExpanded? [DatePickerTableViewCell pickerHeightExpanded] : 0;
        
    }
    return 58.0;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case kRowUserName:{
            TextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TextFieldTableViewCell reuseIdentifier]];
            cell.isSecure = NO;
            cell.placeHolder = @"Username";
            cell.myTextField.text = currentUser.user_username;
            cell.textLabel.text = @"Username";
            cell.myID = @"username";
            cell.delegate =self;
            return cell;
        }
            break;
            
        case kRowName:{
            TextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TextFieldTableViewCell reuseIdentifier]];
            cell.isSecure = NO;
            cell.placeHolder = @"Full Name";
            cell.myTextField.text = currentUser.user_name;
            cell.textLabel.text = @"Full Name";
            cell.myID = @"name";
            cell.delegate =self;
            return cell;
        }
            break;
        case kRowPhone:{
            TextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TextFieldTableViewCell reuseIdentifier]];
            cell.placeHolder = @"Phone";
            cell.myTextField.text = currentUser.user_phone ? currentUser.user_phone : nil;
            cell.textLabel.text = @"Phone";
            cell.myID = @"phone";
            cell.delegate =self;
            return cell;
        }
            break;
        case kRowDOBInfo:{
            LabelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[LabelTableViewCell reuseIdentifier]];
            NSString *dobString = [[TheAppDelegate defaultDateFormatter] stringFromDate:currentUser.user_dob];
            cell.myLabel.text = currentUser.user_dob ? dobString : @"Date of Birth";
            cell.myLabel.textColor = COLOR_HEX(currentUser.user_dob?@"333333":@"cccccc");
            cell.textLabel.text = @"Date of Birth";
            cell.myID = @"dob";
            cell.delegate =self;
            return cell;
        }
            break;
        case kRowDOBPicker:{
            DatePickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[DatePickerTableViewCell reuseIdentifier]];
            cell.myID = @"dobPicker";
            cell.isExpanded = self.isPickerExpanded;
            return cell;
        }
            break;
        case kRowGender:{
            SegmentedControlTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SegmentedControlTableViewCell reuseIdentifier]];
    
            [cell.mySegmentedControl setTitle:@"Pria" forSegmentAtIndex:0];
            [cell.mySegmentedControl setTitle:@"Wanita" forSegmentAtIndex:1];
            cell.myID = @"gender";
            cell.delegate =self;
            return cell;
        }
            break;
            
        default:
            break;
    }
    return nil;
}



#pragma mark CustomCellDelegate
-(void)labelTableViewCell:(LabelTableViewCell *)cell buttonDidTap:(id)sender{
    self.isPickerExpanded = !self.isPickerExpanded;
    TextFieldTableViewCell *tfCell = (TextFieldTableViewCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kRowUserName inSection:0]];
    [tfCell.myTextField resignFirstResponder];
    TextFieldTableViewCell *tfCell2 = (TextFieldTableViewCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kRowName inSection:0]];
    [tfCell.myTextField resignFirstResponder];
    TextFieldTableViewCell *tfCell3 = (TextFieldTableViewCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kRowPhone inSection:0]];
    [tfCell.myTextField resignFirstResponder];
    [tfCell2.myTextField resignFirstResponder];
    [tfCell3.myTextField resignFirstResponder];
    [self resignFirstResponder];
    NSIndexPath *index = [NSIndexPath indexPathForRow:kRowDOBPicker inSection:0];
    [self.myTableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationFade];
    if(self.isPickerExpanded){
        [self.myTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }else{
        CGPoint bottomOffset = self.myTableView.contentOffset;
        bottomOffset.y += 1;
        [self.scrollView setContentOffset:bottomOffset animated:NO];
    }

}

-(void)segmentedControlTableViewCell:(SegmentedControlTableViewCell *)cell didChangeSegmentedControl:(id)sender{
    if (cell.mySegmentedControl.selectedSegmentIndex == 0) {
        self.currentProfileDict[@"gender"] = @"Male";
    }else{
        self.currentProfileDict[@"gender"] = @"Female";
    }
}

-(void)datePickerValuChanged{
    NSDateFormatter *df = [TheAppDelegate defaultDateFormatter];
    LabelTableViewCell *cell = (LabelTableViewCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kRowDOBInfo inSection:0]];
    cell.myLabel.text = [df stringFromDate:self.myPicker.date];
    
    self.currentProfileDict[@"dob"] = self.myPicker.date;
    
}

- (void)textFieldTableViewCell:(TextFieldTableViewCell *)cell textFieldDidBeginEditing:(UITextField *)textField{
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
    [self.myTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

-(BOOL)textFieldTableViewCell:(TextFieldTableViewCell *)cell textFieldShouldReturn:(UITextField *)textFiel{
    [cell.myTextField resignFirstResponder];
    return YES;
}

#pragma mark - keyboard action

-(void)keyboardWillShowWithRect:(CGRect)keyboardRect{
    UIEdgeInsets insetTable = self.myTableView.contentInset;
    insetTable.bottom = keyboardRect.size.height;
    [self.myTableView setContentInset:insetTable];
}

-(void)keyboardWillHideWithRect:(CGRect)keyboardRect{
    [self.myTableView setContentInset:self.defaultTableInsets];
}

@end

