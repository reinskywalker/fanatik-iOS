//
//  TutorialViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/31/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "ParentViewController.h"

@interface TutorialViewController : ParentViewController
@property (weak, nonatomic) IBOutlet UIView *placeholderView;

@property (strong, nonatomic) IBOutlet UIView *page1View;
@property (strong, nonatomic) IBOutlet UIView *page2View;
@property (strong, nonatomic) IBOutlet UIView *page3View;
@property (strong, nonatomic) IBOutlet UIView *page4View;

- (id)initWithPage:(int)page;

@end
