//
//  PostDialogViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/22/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "PostDialogViewController.h"

@interface PostDialogViewController ()<UITextViewDelegate>

@end

@implementation PostDialogViewController
@synthesize delegate, placeHolderText, contentText;

-(id)initWithTitle:(NSString *)title andUser:(User *)user{
    if(self = [super init]){
        self.currentTitle = title;
        self.currentUser = user;
        self.placeHolderText = @"Silahkan tulis...";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageTitleLlabel.text = self.currentTitle;
    [self.postButton setTitle:self.buttonTitle && ![self.buttonTitle isEqualToString:@""]? self.buttonTitle : @"Post" forState:UIControlStateNormal];
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height /2;
    self.userImageView.layer.masksToBounds = YES;
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:self.currentUser.user_avatar.avatar_thumbnail] placeholderImage:nil options:SDWebImageRefreshCached];
    self.contentTextView.delegate = self;
    self.contentTextView.text = contentText && ![contentText isEqualToString:@""]? contentText : placeHolderText;
    self.contentTextView.textColor = contentText && ![contentText isEqualToString:@""]?[UIColor blackColor]:[UIColor lightGrayColor]; //optional
    self.contentTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;

    
}

-(void)viewWillAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:placeHolderText]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = placeHolderText;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}


- (IBAction)cancelButtonTapped:(id)sender {
    [delegate dialogDidCancel:self];
}

- (IBAction)postButtonTapped:(id)sender {
    
    if([self.contentTextView.text isEqualToString:@"Silahkan tulis..."] || [self.contentTextView.text isEqualToString:@""]){
        [delegate dialogDidCancel:self];
    }else{
        [delegate dialogDidPost:self withString:self.contentTextView.text];
    }
}

@end
