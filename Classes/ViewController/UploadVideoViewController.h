//
//  UploadVideoViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/25/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "CategoryPickerViewController.h"

@interface UploadVideoViewController : ParentViewController<UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, CategoryPickerViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *titleTableViewCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *descTableViewCell;
@property(nonatomic, retain) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) IBOutlet UITableViewCell *categoryTableViewCell;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *categoryLabel;
@property (weak, nonatomic) IBOutlet CustomBoldLabel *topTitleLabel;
@property (strong, nonatomic) IBOutlet UITableViewCell *tagTableViewCell;
@property (strong, nonatomic) IBOutlet UITextField *tagTextField;
@property (strong, nonatomic) IBOutlet UITextField *titleTextfield;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet DMMoviePlayer *playerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerAspectRationConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;

@property (nonatomic, retain) NSString *fileFormat;
@property (nonatomic, retain) NSURL *videoURL;
@property (nonatomic, copy) NSString *subCategoryId;

- (IBAction)changeTapped:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;

-(id)initWithUserUpload:(UserUploads *)uu andUserUploadsModel:(UserUploadsModel *)uum;
-(id)initWithContest:(Contest *)contest andUserUploadsModel:(UserUploadsModel *)uum;
-(id)initWithEvent:(Event *)event andUserUploadsModel:(UserUploadsModel *)uum;
@end
