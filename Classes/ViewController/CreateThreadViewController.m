//
//  CreateThreadViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/25/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "CreateThreadViewController.h"

@interface CreateThreadViewController ()<UITableViewDataSource, UITableViewDelegate, IBActionSheetDelegate>
@property(nonatomic, retain) NSMutableDictionary *paramsDict;
@property (nonatomic, assign) float textViewCellHeight;
@property (nonatomic, assign) float textViewCellHeightDefault;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *descriptionHeightConstraint;
@property IBActionSheet *customIBAS;
@property(nonatomic, retain) UIImagePickerController *imagePickerController;
@property (nonatomic, retain) UIImage *currentAttachment;
@property (weak, nonatomic) IBOutlet CustomBoldLabel *topTitleLabel;
@end

@implementation CreateThreadViewController
@synthesize currentClub, paramsDict, textViewCellHeight, textViewCellHeightDefault, customIBAS, imagePickerController, attachedImageView, currentAttachment;

-(id)initWithClub:(Club *)aClub{
    if(self = [super init]){
        self.textViewCellHeight = 58.0;
        self.textViewCellHeightDefault = 58.0;
        self.currentClub = aClub;
        self.paramsDict = [NSMutableDictionary new];
    }
    return self;
}

- (instancetype)initWithThread:(Thread *)thread{
    if(self = [super init]){
        
        self.currentThread = thread;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.myTableView reloadData];
    
    if(self.currentThread){
        self.topTitleLabel.text = @"Ubah Thread";
        Thread *thread = self.currentThread;
        
        self.textViewCellHeightDefault = 58;
        
        [self.myTableView reloadData];
        
        [self setThreadTitle:thread.thread_title];
        [self setThreadDescription:thread.thread_content.thread_content_plain];
        if(thread.thread_image_url && ![thread.thread_image_url isEqualToString:@""])
            [self setImageAttachMentWithURL:[NSURL URLWithString:thread.thread_image_url] completion:nil];
//
//        [self.myTableView reloadData];
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
- (IBAction)deleteAttachmentTapped:(id)sender {
    self.currentAttachment = nil;
    self.attachmentButtonView.hidden = NO;
    self.attachmentMediaView.hidden = YES;
}

- (IBAction)saveButtonTapped:(id)sender {
    if(self.currentThread){
        // ubah thread
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.titleTextfield.text, @"title",
                                self.descriptionTextView.text, @"content",
                                nil];
        [self.view startLoader:YES disableUI:NO];
        NSString *threadId = self.currentThread.thread_id;
        UIImage *attachmentImage = self.currentAttachment;
        
        
        [Thread updateThreadWithId:threadId andDict:params attachedImage:attachmentImage withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Thread *result) {
            NSLog(@"%@", result.thread_image_url);
            NSLog(@"success");
            [self.view startLoader:NO disableUI:NO];
            [self closeButtonTapped:nil];
            [self resignFirstResponder];
            [[NSNotificationCenter defaultCenter] postNotificationName:kThreadUpdated object:result];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"failed");
            [self.view startLoader:NO disableUI:NO];
        
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){

                NSData *responseData = operation.HTTPRequestOperation.responseData;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:responseData //1
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
                NSString *message = json[@"error"][@"messages"][0];
                [self showAlertWithMessage:message];
            }
        }];
    }
    else{
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.titleTextfield.text, @"title",
                                self.descriptionTextView.text, @"content",
                                nil];
        [self.view startLoader:YES disableUI:NO];
        [Thread createThreadWithClubId:self.currentClub.club_id andDict:params attachedImage:currentAttachment withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Thread *result) {
            NSLog(@"success");
            [self.view startLoader:NO disableUI:NO];
            [self closeButtonTapped:nil];
            [self resignFirstResponder];
            [[NSNotificationCenter defaultCenter] postNotificationName:kThreadCreated object:result];
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"failed");
            [self.view startLoader:NO disableUI:NO];
            
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){

                NSData *responseData = operation.HTTPRequestOperation.responseData;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:responseData //1
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
                NSString *message = json[@"error"][@"messages"][0];
                [self showAlertWithMessage:message];
            }
        }];
    }
    
}



////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewCell delegate
////////////////////////////////////////////////////////////////////////


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            return 98.0;
            break;
        case 1:
            return 58.0;
            break;
        case 2:
            return MAX(textViewCellHeight, textViewCellHeightDefault);
            break;
        default:
            return 58.0;
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:{
            self.attachmentTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;

            return self.attachmentTableViewCell;
        }
            break;
        case 1:{
            self.titleTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return self.titleTableViewCell;
        }
            break;
        case 2:{
            self.descTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.descriptionTextView.placeholder = @"Isi thread...";
            
            [self.descriptionTextView setScrollEnabled:YES];
            self.descriptionTextView.textContainerInset = UIEdgeInsetsMake(20, -5, 0, 5);
            return self.descTableViewCell;
        }
            break;
            
        default:
            return nil;
            break;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        [self.titleTextfield resignFirstResponder];
        [self.descriptionTextView resignFirstResponder];
        
        self.customIBAS = [[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Kamera", @"Album Foto", @"Tutup", nil];
        
        
        
        self.customIBAS.tag = 100;
        self.customIBAS.blurBackground = NO;
        [self.customIBAS setFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:14.0]];
        
        [self.customIBAS setButtonBackgroundColor:HEXCOLOR(0xFFFFFFFF)];
        [self.customIBAS setButtonTextColor:HEXCOLOR(0x3399FFFF)];
        [self.customIBAS setButtonTextColor:[UIColor redColor] forButtonAtIndex:2];
        
        self.customIBAS.buttonResponse = IBActionSheetButtonResponseFadesOnPress;
        [self.customIBAS showInView:self.view];
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

#pragma mark - attachment
- (void)setImageAttachMent:(UIImage *)imageAttachment completion:(void(^)(void))completion{
    
    self.attachmentButtonView.hidden = YES;
    self.attachmentMediaView.hidden = NO;
    self.currentAttachment = imageAttachment;
    [self.attachedImageView setImage:self.currentAttachment];
    
    !completion?:completion();
}

- (void)setImageAttachMentWithURL:(NSURL *)imageAttachmentURL completion:(void(^)(void))completion{
    
    self.attachmentButtonView.hidden = YES;
    self.attachmentMediaView.hidden = NO;
    
    __weak typeof(self) weakSelf = self;
    [self.attachedImageView setImageWithURLRequest:[NSURLRequest requestWithURL:imageAttachmentURL] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        weakSelf.currentAttachment = image;
        [weakSelf.attachedImageView setImage:image];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"failed to load image");
    }];
    
    !completion?:completion();
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

#pragma mark - UIImagePickerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    [self setImageAttachMent:[info objectForKey:UIImagePickerControllerOriginalImage] completion:^{
        [picker dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
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
    size.height+=20;
    
    CGSize descriptionSize = size;
    
    [_descriptionHeightConstraint setConstant:descriptionSize.height];
    
    [self.descriptionTextView layoutIfNeeded];
    
    textViewCellHeight = _descriptionHeightConstraint.constant+10;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];//[self.myTableView indexPathForCell:self.descTableViewCell];
    if(indexPath){
        [self.myTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
       
        [self.myTableView beginUpdates];
        [self.myTableView endUpdates];
        [self.myTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}



#pragma mark - keyboard
- (void)keyboardDidShowWithRect:(CGRect)keyboardRect{
    CGSize keyboardSize = keyboardRect.size;
//    CGPoint offset = self.myTableView.contentOffset;
//    CGSize sizeTable = self.myTableView.contentSize;
    
//    offset.y = sizeTable.height - keyboardSize.height;
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


@end
