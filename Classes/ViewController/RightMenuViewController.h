//
//  RightMenuViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/17/14.
//  Copyright (c) 2014 Teguh Hidayatullah. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TheRightMenu ([RightMenuViewController sharedInstance])

@interface RightMenuViewController : ParentViewController


@property (weak, nonatomic) IBOutlet UITextView *debugTextView;
@property (weak, nonatomic) IBOutlet UITextField *serverURLTF;
@property (nonatomic, copy) NSString *debugURL;

- (void)writeToDebugScreen:(id)txt;

- (IBAction)clearScreen:(id)sender;
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(RightMenuViewController)


@end
