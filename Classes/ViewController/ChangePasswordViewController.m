//
//  ChangePasswordViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/27/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "TextFieldTableViewCell.h"

@interface ChangePasswordViewController ()<UITableViewDataSource, UITableViewDelegate, TextFieldTableViewCellDelegate>

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPageCode = MenuPageChangePassword;
    [self configureView];
}

-(void)configureView{
    
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:nil imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
    [lButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *rButton = [TheAppDelegate createButtonWithTitle:@"Submit" imageName:nil highlightedImageName:nil forLeftButton:NO];
    [rButton addTarget:self action:@selector(changePassword) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithCustomView:rButton];
    self.navigationItem.rightBarButtonItem = saveButton;
    

    [self.myTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.myTableView registerNib:[UINib nibWithNibName:[TextFieldTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[TextFieldTableViewCell reuseIdentifier]];
    [self.myTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changePassword{
    TextFieldTableViewCell *tfCell1 = (TextFieldTableViewCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [tfCell1.myTextField resignFirstResponder];
    TextFieldTableViewCell *tfCell2 = (TextFieldTableViewCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [tfCell2.myTextField resignFirstResponder];
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     tfCell1.myTextField.text, @"password",
                                     tfCell2.myTextField.text, @"password_confirmation",
                                     nil];
    [User changePasswordWithUserDict:jsonDict success:^(NSString *message) {
        [self showAlertWithMessage:message];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSUInteger statusCode = operation.response.statusCode;
        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
            [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
        }

    }];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableView delegate
////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:{
            TextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TextFieldTableViewCell reuseIdentifier]];
            cell.isSecure = YES;
            cell.placeHolder = @"Password";
            cell.textLabel.text = @"Password";
            cell.myID = @"password";
            cell.delegate =self;
            [cell.myTextField becomeFirstResponder];
            return cell;
        }
            break;
            
        case 1:{
            TextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TextFieldTableViewCell reuseIdentifier]];
            cell.isSecure = YES;
            cell.placeHolder = @"Confirm Password";
            cell.textLabel.text = @"Confirm Password";
            cell.myID = @"confirm";
            cell.delegate =self;
            return cell;
        }
            break;
        default:
            break;
    }
    return nil;
}

@end
