//
//  WhisperListViewController.m
//  DMMoviePlayer
//
//  Created by Teguh Hidayatullah on 10/29/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "WhisperListViewController.h"
#import "WhisperListTableViewCell.h"

@interface WhisperListViewController ()
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *usersArray;
@end

@implementation WhisperListViewController

-(id)initWithUserArray:(NSMutableArray *)userArray{
    if(self=[super init]){
        self.usersArray = userArray;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.myTableView registerNib:[UINib nibWithNibName:NSStringFromClass([WhisperListTableViewCell class]) bundle:nil] forCellReuseIdentifier:[WhisperListTableViewCell reuseIdentifier]];
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.usersArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WhisperListTableViewCell *cell = (WhisperListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:[WhisperListTableViewCell reuseIdentifier]];
    User *aUser = self.usersArray[indexPath.row];
    [cell fillWithUserName:aUser.user_name];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}



@end
