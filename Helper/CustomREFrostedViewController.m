//
//  CustomREFrostedViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/14/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "CustomREFrostedViewController.h"
#import "DashboardViewController.h"
#import "NSObject+DelayedBlock.h"
#import "UploadVideoViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoCategoryDashboardViewController.h"

@interface CustomREFrostedViewController ()
@property(nonatomic, retain) UIImagePickerController *imagePickerController;
@end

@implementation CustomREFrostedViewController
@synthesize imagePickerController;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.limitMenuViewSize  = YES;
    
    float widthSize = 320.0;
    
    if(!(IS_IPAD)){
        widthSize = [UIScreen mainScreen].bounds.size.width * 80 / 100;
    }
    
    self.menuViewSize = CGSizeMake(widthSize, [UIScreen mainScreen].bounds.size.height);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentViewControllerDidChange) name:kChangeCenterController object:nil];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.barTintColor = [TheInterfaceManager headerBGColor];
  
    //    self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *anchorLeftButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"btnMenu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"btnSearch"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(showRightMenu)];
    UIBarButtonItem *uploadButton = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"addButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(presentUploadMenu)];
    
    self.navigationItem.leftBarButtonItem  = anchorLeftButton;
    self.navigationItem.rightBarButtonItems = @[searchButton, uploadButton];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

-(void)contentViewControllerDidChange{
    UIBarButtonItem *anchorRightButton = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"btnSearch"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(showRightMenu)];
    if([self.contentViewController isKindOfClass:[VideoCategoryDashboardViewController class]]){
        anchorRightButton = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"listButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(presentSubCategoryPicker)];
    }
    self.navigationItem.rightBarButtonItem = anchorRightButton;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showMenu{
    [TheAppDelegate showLeftMenu];
}
-(void)showRightMenu{
    [TheAppDelegate showRightMenu];
}

-(void)presentUploadMenu{
    
    if([User fetchLoginUser] && TheSettingsManager.userUploadModelId == 0){
    
        [TheAppDelegate.slidingViewController hideMenuViewController];
        
        imagePickerController= [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeMovie, nil];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }];
        }
        else{
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
    }else if(TheSettingsManager.userUploadModelId){
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
        
        UIAlertView *resultAlertView = [[UIAlertView alloc] initWithTitle:appName message:@"Uploading masih dalam proses, harap menunggu sampai selesai" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [resultAlertView show];
        
    }else{
    
        [self presentViewController:[[HomeViewController alloc] initByPresenting] animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSLog(@"metadata : %@, type : %@",[info objectForKey:UIImagePickerControllerMediaMetadata], [info objectForKey:UIImagePickerControllerMediaType]);
    
    NSURL *urlvideo = [info objectForKey:UIImagePickerControllerMediaURL];
    NSLog(@"urlvideo is :::%@",urlvideo);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UploadVideoViewController *uploadVC = [[UploadVideoViewController alloc] initWithContest:nil andUserUploadsModel:nil];
    uploadVC.videoURL = urlvideo;
    uploadVC.fileFormat = [urlvideo pathExtension];
    
    CustomNavigationController *navCon = [[CustomNavigationController alloc]initWithRootViewController:uploadVC];
    [self presentViewController:navCon animated:YES completion:nil];

}

-(void)presentSubCategoryPicker{
    [(VideoCategoryDashboardViewController *)self.contentViewController showCategoryPicker];
    
}
@end
