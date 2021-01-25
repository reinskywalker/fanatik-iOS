//
//  TutorialViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/31/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()

@property (nonatomic, assign) int currentPage;

@end

@implementation TutorialViewController

@synthesize page1View, page2View, page3View, placeholderView, currentPage, page4View;

- (id)initWithPage:(int)page
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.currentPage = page;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view sdc_pinSize:[UIScreen mainScreen].bounds.size];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.view.superview){
        [self.view sdc_alignEdges:UIRectEdgeAll withView:self.view.superview];
    }
    
    if(currentPage==1)  {
        [placeholderView addSubview:page1View];
        if(page1View.superview){
            [page1View sdc_alignEdges:UIRectEdgeAll withView:page1View.superview];
        }
    } else if(currentPage==2)   {
        [placeholderView addSubview:page2View];
        if(page2View.superview){
            [page2View sdc_alignEdges:UIRectEdgeAll withView:page2View.superview];
        }
        NSLog(@"%@",NSStringFromCGRect(page2View.frame));
    } else if(currentPage==3)   {
        [placeholderView addSubview:page3View];
        if(page3View.superview){
            [page3View sdc_alignEdges:UIRectEdgeAll withView:page3View.superview];
        }
        NSLog(@"%@",NSStringFromCGRect(page3View.frame));
    }else if(currentPage==4)   {
        [placeholderView addSubview:page4View];
        if(page4View.superview){
            [page4View sdc_alignEdges:UIRectEdgeAll withView:page4View.superview];
        }
        NSLog(@"%@",NSStringFromCGRect(page4View.frame));
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
