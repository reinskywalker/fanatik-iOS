//
//  CategoryPickerViewController.m
//  Fanatik
//
//  Created by Erick Martin on 6/3/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "CategoryPickerViewController.h"

@implementation CategoryPickerViewController

@synthesize categoryArray, categoryTableView, delegate, selectedSubCategorySet;

-(id)init{

    if(self=[super init]){
        self.categoryArray = [NSMutableArray array];
        self.selectedSubCategorySet = [NSMutableSet set];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self configureView];
    
    [self getDataFromServer];
}

-(void)getDataFromServer{

    [ClipCategory getAllClipCategoriesModelWithAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *resultArray) {
        [self.categoryArray removeAllObjects];
        [self.categoryArray addObjectsFromArray:resultArray];
        [categoryTableView reloadData];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
        }
    }];
}

-(void)configureView{
    
    [self.categoryTableView registerNib:[UINib nibWithNibName:[CategoryPickerTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[CategoryPickerTableViewCell reuseIdentifier]];
    self.categoryTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationController.navigationBar.barTintColor = [TheInterfaceManager headerBGColor];
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:nil imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
    [lButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;
    self.title = @"Category";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:InterfaceStr(@"default_font_bold") size:17]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
-(void)backButtonTapped:(id)sender{
//    [self.delegate didSelectSubCategoryArray:selectedSubCategorySet.allObjects];
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - UITableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.categoryArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    ClipCategoryModel *catModel = categoryArray[section];
    return catModel.clip_sub_category_array.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ClipCategoryModel *theClipGroup = categoryArray[indexPath.section];
    NSArray *clipsArray = theClipGroup.clip_sub_category_array;
    ClipSubCategoryModel *clipSubModel = [clipsArray objectAtIndex:indexPath.row];
    
    CategoryPickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CategoryPickerTableViewCell reuseIdentifier]];
//    cell.selectionStyle = UITableViewCellSelectionStyleGray;
//    UIView *selectedBackgroundView = [[UIView alloc] init];
//    selectedBackgroundView.backgroundColor = [UIColor redColor];
//    cell.selectedBackgroundView = selectedBackgroundView;
    [cell setItem:clipSubModel];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClipCategoryModel *theClipGroup = categoryArray[indexPath.section];
    NSArray *clipsArray = theClipGroup.clip_sub_category_array;
    ClipSubCategoryModel *clipSubModel = [clipsArray objectAtIndex:indexPath.row];
 
    CategoryPickerTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = HEXCOLOR(0xEEEEEEFF);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.delegate didSelectSubCategory:clipSubModel];
    [self.navigationController popViewControllerAnimated:YES];
    /*
    if([selectedSubCategorySet containsObject:clipSubModel.clip_subcategory_id]){
        [selectedSubCategorySet removeObject:clipSubModel.clip_subcategory_id];
    }else{
        [selectedSubCategorySet addObject:clipSubModel.clip_subcategory_id];
    }
    
    [categoryTableView reloadData];
     */
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(CategoryPickerTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ClipCategoryModel *theClipGroup = categoryArray[indexPath.section];
    NSArray *clipsArray = theClipGroup.clip_sub_category_array;
    ClipSubCategoryModel *clipSubModel = [clipsArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if([selectedSubCategorySet containsObject:clipSubModel.clip_subcategory_id]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [cell.titleLabel setTextColor:HEXCOLOR(0x0079ffFF)];
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.titleLabel setTextColor:HEXCOLOR(0x333333FF)];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectHeaderView = [UIView new];
    sectHeaderView.frame = CGRectMake(0, 0, self.categoryTableView.frame.size.width, 40.0);
    ClipCategoryModel *theClipCatModel = [categoryArray objectAtIndex:section];
    sectHeaderView.backgroundColor = [UIColor clearColor];
    
    CustomSemiBoldButton *titleButton = [CustomSemiBoldButton buttonWithType:UIButtonTypeCustom];
    [titleButton addTarget:self action:@selector(didSelectCatModel:) forControlEvents:UIControlEventTouchUpInside];
    [titleButton addTarget:self action:@selector(didFeedbackEffect:) forControlEvents:UIControlEventTouchDown];
    [titleButton setTitle:theClipCatModel.clip_category_name forState:UIControlStateNormal];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    titleButton.frame = CGRectMake(0, 0, screenRect.size.width, 40.0);
    [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 20)];
    [titleButton setTitleColor:HEXCOLOR(0x333333ff) forState:UIControlStateNormal];
    titleButton.titleLabel.font = [UIFont fontWithName:InterfaceStr(@"default_font_semi_bold") size:15.0];
    titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    titleButton.backgroundColor = [UIColor clearColor];
    titleButton.tag = section;
    [sectHeaderView addSubview:titleButton];
    return sectHeaderView;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    CategoryPickerTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = HEXCOLOR(0xEEEEEEFF);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 40.0;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

-(IBAction)didFeedbackEffect:(UIButton *)sender{
    sender.backgroundColor = HEXCOLOR(0xEEEEEEFF);
}

-(void)didSelectCatModel:(UIButton *)butt{
    ClipCategoryModel *myCat = [categoryArray objectAtIndex:butt.tag];
    [self.delegate didSelectCategory:myCat];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
