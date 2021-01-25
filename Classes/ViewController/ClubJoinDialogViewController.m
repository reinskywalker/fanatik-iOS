
//
//  ClubJoinDialogViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/22/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ClubJoinDialogViewController.h"

@interface ClubJoinDialogViewController ()<UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *clubImageView;
@property (strong, nonatomic) IBOutlet DTAttributedLabel *joinMessageLabel;
@property (strong, nonatomic) IBOutlet UIWebView *myWebView;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;

- (IBAction)closeDialog:(id)sender;

@end

@implementation ClubJoinDialogViewController
@synthesize delegate, currentClub, joinMessageLabel;

-(id)initWithClub:(Club *)club{
    if(self = [super init]){
        self.currentClub = club;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clubImageView.layer.cornerRadius = self.clubImageView.frame.size.height /2;
    self.clubImageView.layer.masksToBounds = YES;
    NSLog(@"%@",self.currentClub.club_user.user_avatar.avatar_thumbnail);
    [self.clubImageView sd_setImageWithURL:[NSURL URLWithString:self.currentClub.club_user.user_avatar.avatar_thumbnail]];
    
    
    NSString *currentMessage =  [NSString stringWithFormat:@"<div style=\"text-align: center;\">%@</div>",self.currentClub.club_join_message];

    NSAttributedString *as = [[[DTHTMLAttributedStringBuilder alloc]
                               initWithHTML:[currentMessage dataUsingEncoding:NSUnicodeStringEncoding]
                               options:@{
                                         DTDefaultFontSize: @(12),
                                         DTDefaultFontFamily: InterfaceStr(@"default_font_regular"),
                                         }
                               documentAttributes:NULL] generatedAttributedString];


    
    self.joinMessageLabel.attributedString = as;
//    self.joinMessageLabel.numberOfLines = 100;
    
    [self.myWebView loadHTMLString:currentMessage baseURL:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)closeDialog:(id)sender {
    [delegate dialogDidClose:currentClub];
}
@end
