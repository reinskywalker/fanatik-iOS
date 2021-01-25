//
//  WebViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/3/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"

@interface WebViewController : ParentViewController<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSURL *currentURL;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *myActivityView;
@property (nonatomic, assign) BOOL didPresent;
@property (strong, nonatomic) IBOutlet CustomMediumButton *leftButton;
@property (nonatomic, retain) NSString *currentOrderID;
@property (nonatomic, retain) NSString *backButtonTitle;


-(id)initWithURL:(NSURL *)url;
@end
