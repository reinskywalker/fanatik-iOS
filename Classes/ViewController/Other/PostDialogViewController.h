//
//  PostDialogViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/22/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
@class PostDialogViewController;

@protocol PostDialogViewControllerDelegate <NSObject>

-(void)dialogDidCancel:(PostDialogViewController *)dialog;
-(void)dialogDidPost:(PostDialogViewController*)dialog withString:(NSString *)content;

@end

@interface PostDialogViewController : ParentViewController

@property (strong, nonatomic) IBOutlet CustomMediumButton *postButton;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *pageTitleLlabel;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UITextView *contentTextView;
@property (nonatomic, copy) NSString *currentTitle;
@property (nonatomic, retain) User *currentUser;
@property (nonatomic, copy) NSString *placeHolderText;
@property (nonatomic, copy) NSString *contentText;
@property (nonatomic, copy) NSString *buttonTitle;
@property (nonatomic, weak) id <PostDialogViewControllerDelegate> delegate;

- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)postButtonTapped:(id)sender;

-(id)initWithTitle:(NSString *)title andUser:(User *)user;
@end
