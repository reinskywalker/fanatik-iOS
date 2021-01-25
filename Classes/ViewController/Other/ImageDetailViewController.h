//
//  ImageDetailViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/26/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"

@interface ImageDetailViewController : ParentViewController<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, copy) NSString *imageURL;
@property (strong, nonatomic) IBOutlet CustomMediumButton *closeButton;
@property (strong, nonatomic) IBOutlet UIView *headerView;

- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer;
-(id)initWithImageURL:(NSString *)url;
- (IBAction)closeTapped:(id)sender;


@end
