//
//  VideoCategoryPickerViewController.h
//  Fanatik
//
//  Created by Erick Martin on 5/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"

@protocol VideoCategoryPickerViewControllerDelegate <NSObject>

-(void)didSelectCategory:(ClipCategory *)cat;

@end

@interface VideoCategoryPickerViewController : ParentViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;
@property (nonatomic, retain) NSMutableArray *categoryArray;
@property (nonatomic, weak) id <VideoCategoryPickerViewControllerDelegate> delegate;

- (IBAction)closeTapped:(id)sender;

-(id)initWithCategoryId:(NSString *)catId;

@end
