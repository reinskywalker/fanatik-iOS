//
//  VideoCategoryPickerViewController.m
//  Fanatik
//
//  Created by Erick Martin on 5/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "VideoCategoryPickerViewController.h"
#import "VideoCategoryPickerCell.h"
#import "VideoSubCategoryViewController.h"

@interface VideoCategoryPickerViewController()
@property (nonatomic, copy) NSString *currentCategoryId;
@end

@implementation VideoCategoryPickerViewController
@synthesize categoryTableView, categoryArray, delegate, currentCategoryId;

-(id)initWithCategoryId:(NSString *)catId{

    if(self = [super init]){
        self.categoryArray = [NSMutableArray array];
        self.currentCategoryId = catId;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [categoryTableView registerNib:[UINib nibWithNibName:[VideoCategoryPickerCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[VideoCategoryPickerCell reuseIdentifier]];
    categoryTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self getClipCategoriesFromServer];
    
}

-(void)viewWillAppear:(BOOL)animated{
    //dont call super!
    self.navigationController.navigationBarHidden = YES;
}

-(void)getClipCategoriesFromServer{
    
    [ClipCategory getSubCategoryWithCategoryId:currentCategoryId andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *resultArray) {
        [self.categoryArray addObjectsFromArray:resultArray];
        [categoryTableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        WRITE_LOG(error.description);
    }];
}

#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.categoryArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    VideoCategoryPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:[VideoCategoryPickerCell reuseIdentifier]];

    [cell setItem:[self.categoryArray objectAtIndex:indexPath.row]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ClipCategory *cat = [self.categoryArray objectAtIndex:indexPath.row];
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        [delegate didSelectCategory:cat];
    }];

}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeTapped:(id)sender {
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}



@end
