//
//  UploadVideoViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/25/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "UploadVideoViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>

#define PERCENTAGE_OF_SHRINKEDVIDEO 0.7

@interface UploadVideoViewController ()<UITableViewDataSource, UITableViewDelegate, IBActionSheetDelegate>
@property(nonatomic, retain) NSMutableDictionary *paramsDict;
@property (nonatomic, assign) float textViewCellHeight;
@property (nonatomic, assign) float textViewCellHeightDefault;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *descriptionHeightConstraint;
@property IBActionSheet *customIBAS;
@property (nonatomic, retain) Contest *currentContest;
@property (nonatomic, retain) Event *currentEvent;

@end

@implementation UploadVideoViewController
@synthesize currentClub, paramsDict, textViewCellHeight, textViewCellHeightDefault, customIBAS, imagePickerController;
@synthesize videoURL, subCategoryId, currentUserUpload, currentUserUploadsModel, currentContest;
@synthesize currentEvent, playerView;

-(id)initWithUserUpload:(UserUploads *)uu andUserUploadsModel:(UserUploadsModel *)uum{
    if(self = [super init]){
        self.textViewCellHeight = 58.0;
        self.textViewCellHeightDefault = 80.0;
        self.currentUserUpload = uu;
        self.currentUserUploadsModel = uum;
    }
    return self;
}

-(id)initWithContest:(Contest *)contest andUserUploadsModel:(UserUploadsModel *)uum{
    if(self = [super init]){
        self.textViewCellHeight = 58.0;
        self.textViewCellHeightDefault = 80.0;
        self.currentContest = contest;
        self.currentUserUploadsModel = uum;
    }
    return self;
}

-(id)initWithEvent:(Event *)event andUserUploadsModel:(UserUploadsModel *)uum{
    if(self = [super init]){
        self.textViewCellHeight = 58.0;
        self.textViewCellHeightDefault = 80.0;
        self.currentEvent = event;
        self.currentUserUploadsModel = uum;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.myTableView reloadData];
    [self configureView];
    
    [self reloadVideo];
}

-(void)reloadVideo{
    [playerView setThumbnailImage:[self generateThumbImage:self.videoURL]];
    [playerView initializeWithContentURL:self.videoURL andThumbnailURL:nil andVastURL:nil durationString:@"13:31"];
    self.playerView.isLive = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self)
    {
        // View is disappearing because a new view controller was pushed onto the stack
        NSLog(@"New view controller was pushed");
        [playerView pause];
    } else{
        // View is disappearing because it was popped from the stack
        NSLog(@"View controller was popped");
        [playerView stopMovie];
    }
}

-(void)configureView{
    self.navigationController.navigationBar.barTintColor = [TheInterfaceManager headerBGColor];
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:nil imageName:@"closeButton" highlightedImageName:@"closeButton" forLeftButton:YES];
    [lButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.navigationItem.title = @"Upload Video";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:InterfaceStr(@"default_font_bold") size:17]}];
    
    _topViewHeightConstraint.constant = 40.0;
    if(currentContest){
        self.topTitleLabel.text = currentContest.contest_name;
    }else if(currentEvent){
        self.topTitleLabel.text = currentEvent.event_name;
    }else{
        _topViewHeightConstraint.constant = 0.0;
    }
    
    if(self.currentUserUpload){
        _titleTextfield.text = self.currentUserUpload.user_uploads_title;
        _descriptionTextView.text = self.currentUserUpload.user_uploads_description;
        _categoryLabel.text = self.currentUserUploadsModel.clip_category_string;
        _categoryLabel.textColor = [UIColor blackColor];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setThreadTitle:(NSString *)title{
    self.titleTextfield.text = title;
}

- (void)setThreadDescription:(NSString *)description{
    self.descriptionTextView.text = description;
    [self textViewDidChange:self.descriptionTextView];
}

#pragma mark - IBActions
- (IBAction)changeTapped:(id)sender{
    [self.titleTextfield resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];
    
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

-(BOOL)isValidate{

    BOOL isValid = YES;
    
    if([self.titleTextfield.text isEqualToString:@""]){
        isValid = NO;
        [self showAlertWithMessage:@"Judul video wajib diisi"];
    }else if([self.descriptionTextView.text isEqualToString:@""]){
        isValid = NO;
        [self showAlertWithMessage:@"Deskripsi video wajib diisi"];
    }else if(!self.subCategoryId){
        isValid = NO;
        [self showAlertWithMessage:@"Pilih kategori terlebih dahulu"];
    }else if(!self.videoURL){
        isValid = NO;
        [self showAlertWithMessage:@"Pilih video terlebih dahulu"];
    }
    
    return isValid;
}

- (IBAction)saveButtonTapped:(id)sender {
    
    if(![self isValidate])
        return;
    
    self.currentUserUpload = nil;
    [self.view startLoader:YES disableUI:NO];
    
    NSMutableDictionary *uuDict = [NSMutableDictionary dictionaryWithDictionary:
                                @{@"title":self.titleTextfield.text,
                                  @"description":self.descriptionTextView.text,
                                  @"clip_category_id":self.subCategoryId,
                                  @"file_extension":self.fileFormat}];
    
    if(currentContest){
        [uuDict setObject:currentContest.contest_id forKey:@"contest_id"];
    }
    
    if(currentEvent){
        [uuDict setObject:currentEvent.event_id forKey:@"event_id"];
    }

    //upload meta dulu baru upload video
    [UserUploads createUserUploadsWithUserUploadsDictionary:uuDict withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, UserUploads *result) {
        
        [self.view startLoader:NO disableUI:NO];
        NSLog(@"success dong");
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshProfilePage object:nil];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        ProfileViewController *controller = [[ProfileViewController alloc] initWithUser:[User fetchLoginUser]];
        controller.currentProfileMode = ProfileModeModerasi;
        [TheAppDelegate changeCenterController:controller];
        [TheSettingsManager saveSelectedMenu:MenuPageProfile];
        [TheSettingsManager saveUserUploadModelId:result.user_uploads_id];

        NSLog(@"Path Video NSURL : %@", self.videoURL);
        NSLog(@"Path Video URL Path : %@", [self.videoURL path]);
        NSLog(@"Path Video URL Absolute Str : %@", [self.videoURL absoluteString]);
        
        
        UserUploadsModel *uum = [[UserUploadsModel alloc] init];
        uum.user_uploads_id = result.user_uploads_id;
        uum.user_uploads_title = result.user_uploads_title;
        uum.user_uploads_video_url_local = [self.videoURL absoluteString];
        uum.clip_category_string = self.categoryLabel.text;
        uum.user_uploads_status = UseruploadStatusOnProgress;
    
        NSLog(@"user upload model = %@", uum);

        [TheDatabaseManager updateUserUploadsModel:uum];

        AWSRequestObject *aws = result.user_uploads_aws;
        NSMutableDictionary *s3UploadParam = [NSMutableDictionary new];
        s3UploadParam[@"videoURL"] = self.videoURL;
        s3UploadParam[@"aws"] = aws;
        s3UploadParam[@"userUploadModel"] = uum;
        s3UploadParam[@"categoryName"] = self.categoryLabel.text;
        s3UploadParam[@"fileExtension"] = self.fileFormat;
        [[NSNotificationCenter defaultCenter]postNotificationName:kUploadVideoMetaFinished object:nil userInfo:s3UploadParam];
        
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        //failed when upload meta data
        
        NSLog(@"failed when upload meta data");
        [self.view startLoader:NO disableUI:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshProfilePage object:nil];
        
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            if(jsonDict[@"error"][@"messages"][0])
                [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
        }
    }];

    
}

#pragma mark - UITableViewCell delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            return 65.0;
            break;
        case 1:
            return MAX(textViewCellHeight, textViewCellHeightDefault);
            break;
        case 2:
            return 75.0;
            break;
        default:
            return 65.0;
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:{
            self.titleTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return self.titleTableViewCell;
        }
            break;
        case 1:{
            self.descTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.descriptionTextView.placeholder = @"Write your description here";
            
            [self.descriptionTextView setScrollEnabled:NO];
            self.descriptionTextView.textContainerInset = UIEdgeInsetsMake(10, -5, 0, 5);
            return self.descTableViewCell;
        }
            break;
        case 2:{
            self.categoryTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return self.categoryTableViewCell;
        }
            break;
        case 3:{
            self.tagTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return self.tagTableViewCell;
        }
            break;
            
        default:
            return nil;
            break;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
    if(indexPath.row == 2){
        [self.titleTextfield resignFirstResponder];
        [self.descriptionTextView resignFirstResponder];
        [self.myTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
        CategoryPickerViewController *controller = [[CategoryPickerViewController alloc] init];
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - IOS7 Orientation Change
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        self.videoPlayerTopConstraint.constant = 0.0;
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        
    }else{
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
        self.videoPlayerTopConstraint.constant = 64.0;
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    self.playerView.originalPlayerSize = self.playerView.frame.size;
    playerView.zoomButton.selected = !playerView.zoomButton.selected;
    
    if(playerView.isShrink){
        [playerView shrinkMainVideoWithAnimation:NO andSize:CGSizeMake(PERCENTAGE_OF_SHRINKEDVIDEO * self.playerView.originalPlayerSize.width, PERCENTAGE_OF_SHRINKEDVIDEO * self.playerView.originalPlayerSize.height)];
    }
    
    if(fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }else{
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

#pragma mark - IOS8 Orientation Change
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.playerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    playerView.zoomButton.selected = !playerView.zoomButton.selected;
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         // do whatever
         self.playerView.originalPlayerSize = self.playerView.frame.size;
         
         if(playerView.isShrink){
             [playerView shrinkMainVideoWithAnimation:NO andSize:CGSizeMake(PERCENTAGE_OF_SHRINKEDVIDEO * self.playerView.originalPlayerSize.width, PERCENTAGE_OF_SHRINKEDVIDEO * self.playerView.originalPlayerSize.height)];
         }
         
         if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
             
             [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
             
             self.navigationController.interactivePopGestureRecognizer.enabled = NO;
             
             [self.navigationController setNavigationBarHidden:YES animated:YES];
             _videoPlayerTopConstraint.constant = 0;
             if(IS_IPAD){
                 self.videoPlayerAspectRationConstraint.active = NO;
                 self.videoPlayerBottomConstraint.constant = 0;
                 self.videoPlayerBottomConstraint.active = YES;
             }
             self.myTableView.hidden = YES;
             [self.view endEditing:YES];
            
         }else{
             
             [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
             
             self.navigationController.interactivePopGestureRecognizer.enabled = YES;
             
             self.videoPlayerTopConstraint.constant = 64.0;
             self.myTableView.hidden = NO;
             if(IS_IPAD){
                 self.videoPlayerAspectRationConstraint.active = YES;
                 self.videoPlayerBottomConstraint.active = NO;
             }
             
             [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         // do whatever
         if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
             
             
         }else{
             
         }
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - DMMoviePlayerViewDelegate
-(void)DMMoviePlayer:(DMMoviePlayer *)moviePlayer resolutionButtonTapped:(NSArray *)resoArray andSeekTime:(CMTime)time{
    
    NSMutableArray *resolutionStringArray = [NSMutableArray array];
    
    for(M3U8ExtXStreamInf *info in resoArray){
        [resolutionStringArray addObject:[NSString stringWithFormat:@"%0.fx%0.f",[info resolution].width, [info resolution].height]];
    }
    
    [UIActionSheet showInView:self.view withTitle:@"Change Resolution" cancelButtonTitle:@"Batal" destructiveButtonTitle:nil otherButtonTitles:resolutionStringArray tapBlock:^(UIActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
        
        if(buttonIndex != actionSheet.cancelButtonIndex){
            M3U8ExtXStreamInf *info = [resoArray objectAtIndex:buttonIndex];
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:info.URI]];
            [self.playerView.moviePlayer.player replaceCurrentItemWithPlayerItem:playerItem];
            [self.playerView.moviePlayer.player.currentItem seekToTime:time];
        }
    }];
}

-(IBAction)PIPtapped:(id)sender{
    [playerView commencingPIPWithMainVideoURL:nil andMiniVideoURL:[NSURL URLWithString:@"http://www.ciphertrick.com/demo/htmlvast/vod/sample.mp4"]];
}

-(IBAction)shrinkTapped:(id)sender{
    
    if(!self.playerView.isShrink){
        [playerView shrinkMainVideoWithAnimation:YES andSize: CGSizeMake(PERCENTAGE_OF_SHRINKEDVIDEO * self.playerView.frame.size.width, PERCENTAGE_OF_SHRINKEDVIDEO * self.playerView.frame.size.height)];
    }else{
        [playerView shrinkMainVideoWithAnimation:YES andSize:self.playerView.frame.size];
    }
}

#pragma mark - UIImagePickerDelegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self reloadVideo];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    NSLog(@"metadata : %@, type : %@",[info objectForKey:UIImagePickerControllerMediaMetadata], [info objectForKey:UIImagePickerControllerMediaType]);
    
    NSURL *urlvideo = [info objectForKey:UIImagePickerControllerMediaURL];
    NSLog(@"urlvideo is :::%@",urlvideo);
    self.videoURL = urlvideo;
    
    NSError *error = nil;
    NSDictionary * properties = [[NSFileManager defaultManager] attributesOfItemAtPath:urlvideo.path error:&error];
    NSNumber * size = [properties objectForKey: NSFileSize];
    NSLog(@"video size: %@", size);
    
    self.fileFormat = [urlvideo pathExtension];

    [self reloadVideo];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(UIImage *)generateThumbImage:(NSURL *)url
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generate.appliesPreferredTrackTransform=TRUE;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    NSLog(@"err==%@, imageRef==%@", err, imgRef);
    
    return [[UIImage alloc] initWithCGImage:imgRef];
}

#pragma mark - UITextViewDelegate
-(void)textViewDidChange:(UITextView *)textView{
    
    CGRect frameTextView            = self.descriptionTextView.frame;
    CGRect frameDescTextViewCell    = self.descTableViewCell.frame;
    CGRect mainBound = [[UIScreen mainScreen] bounds];
    CGFloat margin = (frameDescTextViewCell.size.width - frameTextView.size.width);
    frameTextView.size.width = mainBound.size.width - margin;
    
//    CGSize descriptionSize = self.descriptionTextView.contentSize;

    NSString *text = textView.text;
    CGSize size = [text sizeOfTextWithfont:self.descriptionTextView.font frame:frameTextView];
    size.height+=40;
    
    CGSize descriptionSize = size;
    
    [_descriptionHeightConstraint setConstant:descriptionSize.height];
    
    [self.descriptionTextView layoutIfNeeded];
    
    textViewCellHeight = _descriptionHeightConstraint.constant+10;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];//[self.myTableView indexPathForCell:self.descTableViewCell];
    if(indexPath){
//        [self.myTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
       
        [self.myTableView beginUpdates];
        [self.myTableView endUpdates];
        [self.myTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}



#pragma mark - keyboard
- (void)keyboardDidShowWithRect:(CGRect)keyboardRect{
    CGSize keyboardSize = keyboardRect.size;
    UIEdgeInsets inset = self.myTableView.contentInset;
    

    inset.bottom = keyboardSize.height + 10;
    self.myTableView.contentInset = inset;
    
}

- (void)keyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:0.3 animations:^{
        self.myTableView.contentOffset = CGPointZero;
        self.myTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);;
    }];
}

#pragma mark - CategoryPicker
-(void)didSelectSubCategoryArray:(NSArray *)arrayOfSelectedSubCategory{
    NSLog(@"array = %@", arrayOfSelectedSubCategory);
}

-(void)didSelectSubCategory:(ClipSubCategoryModel *)clipSubCat{
    self.categoryLabel.text = clipSubCat.clip_subcategory_name;
    self.subCategoryId = clipSubCat.clip_subcategory_id;
    self.categoryLabel.textColor = [UIColor blackColor];
}

-(void)didSelectCategory:(ClipCategoryModel *)clipCat{
    self.categoryLabel.text = clipCat.clip_category_name;
    self.subCategoryId = clipCat.clip_category_id;
    self.categoryLabel.textColor = [UIColor blackColor];
}

#pragma mark - UITextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(textField == self.titleTextfield){
        [self.descriptionTextView becomeFirstResponder];
    }
    return YES;
}

@end
