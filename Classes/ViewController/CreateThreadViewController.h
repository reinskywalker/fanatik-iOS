//
//  CreateThreadViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/25/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"

@interface CreateThreadViewController : ParentViewController<UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *titleTableViewCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *descTableViewCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *attachmentTableViewCell;
@property (strong, nonatomic) IBOutlet UIImageView *attachedImageView;
@property (strong, nonatomic) IBOutlet UIView *attachmentMediaView;
@property (strong, nonatomic) IBOutlet UIView *attachmentButtonView;
@property (strong, nonatomic) IBOutlet UITextField *titleTextfield;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;

- (IBAction)deleteAttachmentTapped:(id)sender;

- (IBAction)saveButtonTapped:(id)sender;
-(id)initWithClub:(Club *)aClub;

- (instancetype)initWithThread:(Thread *)thread;

@end
