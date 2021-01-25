//
//  ThreadDetailsViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/18/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "SwipeView.h"

@interface ThreadDetailsViewController : ParentViewController<SwipeViewDataSource, SwipeViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIView *tableHeaderView;
@property (strong, nonatomic) IBOutlet UIImageView *threadImageView;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *threadTitleLabel;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *commentCountLabel;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *likeCountLabel;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *updatedLabel;
@property (strong, nonatomic) IBOutlet UIView *threadInfoContainerView;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *threadDetailsLabel;
@property (strong, nonatomic) IBOutlet UIView *paginationView;

@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *commentButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIButton *pagingButton;
@property (strong, nonatomic) IBOutlet SwipeView *pagesSwipeView;
@property (strong, nonatomic) IBOutlet UIButton *pagePrevButton;
@property (strong, nonatomic) IBOutlet UIButton *pageNextButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomHeightConst;

- (IBAction)likeButtonTapped:(id)sender;
- (IBAction)commentButtonTapped:(id)sender;
- (IBAction)shareButtonTapped:(id)sender;
- (IBAction)pageButtonTapped:(id)sender;
- (IBAction)pagePrevButtonTapped:(id)sender;
- (IBAction)pageNextButtonTapped:(id)sender;

-(id)initWithThreadId:(NSString *)threadId;
-(id)initWithThread:(Thread*) obj;

@end
