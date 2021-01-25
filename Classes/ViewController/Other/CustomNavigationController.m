//
//  CustomNavigationController.m
//  RupiahKu
//
//  Created by Teguh Hidayatullah on 12/19/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "CustomNavigationController.h"
#import "UIViewController+REFrostedViewController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

-(instancetype)init{
    if(self = [super init]){
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI orientation
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        //IF IOS 8++ All VC is Potrait only except VideoDetail, LiveVideo, MPMoviePlayer, and WebViewCont
        if([self.topViewController isKindOfClass:[VideoDetailViewController class]] ||
           [self.topViewController isKindOfClass:[TVChannelDetailViewController class]] ||
           [self.topViewController isKindOfClass:[MPMoviePlayerViewController class]] ||
           [self.topViewController isKindOfClass:[WebViewController class]] ||
           [self.topViewController isKindOfClass:[LiveChatDetailViewController class]] ||
           [self.topViewController isKindOfClass:[EventDetailViewController class]]){
            return UIInterfaceOrientationMaskAllButUpsideDown;
        }else{
            return UIInterfaceOrientationMaskPortrait;
        }
    }else{
        //IF below iOS 8 Only LiveVideoVC can have all orientation
        if([self.topViewController isKindOfClass:[TVChannelDetailViewController class]] ){
            return UIInterfaceOrientationMaskAllButUpsideDown;
        }else{
            return UIInterfaceOrientationMaskPortrait;
        }
    }
}


- (BOOL)shouldAutorotate
{
    return YES;
}


@end
