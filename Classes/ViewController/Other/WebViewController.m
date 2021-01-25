//
//  WebViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/3/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
<UIWebViewDelegate>

@end

@implementation WebViewController
@synthesize didPresent, currentOrderID, backButtonTitle;

-(id)initWithURL:(NSURL *)url{
    if(self=[super init]){
        self.currentURL = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:nil imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
    [lButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.title = @"Tentang Kami";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:InterfaceStr(@"default_font_bold") size:17]}];
    
    if(didPresent){
        [self.leftButton setTitle:@"Tutup" forState:UIControlStateNormal];
        [self.leftButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [self.leftButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.leftButton setTitle:@"" forState:UIControlStateNormal];
        [self.leftButton setImage:[UIImage imageNamed:@"leftArrow"] forState:UIControlStateNormal];
        [self.leftButton setImage:[UIImage imageNamed:@"leftArrowHighlighted"] forState:UIControlStateSelected];
        [self.leftButton setImage:[UIImage imageNamed:@"leftArrowHighlighted"] forState:UIControlStateHighlighted];
        self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.currentURL];
    self.webView.delegate = self;
    [self.webView loadRequest:request];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    self.myActivityView.hidden = NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    self.myActivityView.hidden = YES;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.myActivityView.hidden = YES;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //orders
    NSString *urlString = request.mainDocumentURL.absoluteString;
    NSRange result = [urlString rangeOfString:@"mobile_action"];
    if (result.location != NSNotFound) {
        NSMutableDictionary *params = [TheAppDelegate stripURL:urlString];
        if([params[@"mobile_action"] isEqualToString:@"success_view"]){
            //payment success
            [[NSNotificationCenter defaultCenter] postNotificationName:kPaymentCompleted object:nil];
            [self closeButtonTapped:nil];
        }else{
            //payment failed
            [[NSNotificationCenter defaultCenter] postNotificationName:kPaymentFailed object:nil];
            [self backButtonTapped:nil];
        }
        return  NO;
    }else{
        NSRange result2 = [urlString rangeOfString:@"result"];
        NSRange result3 = [urlString rangeOfString:@"orders"];
        if(result2.location != NSNotFound && result3.location != NSNotFound){
            self.leftButton.hidden = YES;
        }
        return YES;
    }
    
        
   


}


@end
