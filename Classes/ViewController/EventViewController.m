//
//  EventViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 11/16/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "EventViewController.h"
#import "EventSmallTableViewCell.h"
#import "EventBigTableViewCell.h"
#import "EventDetailViewController.h"

@interface EventViewController ()

@property(nonatomic, retain) NSMutableArray *eventGroupArray;

@end

@implementation EventViewController
@synthesize myTableView, eventGroupArray;

-(instancetype)init{
    if(self = [super init]){
        self.eventGroupArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureView];

}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)configureView{
    
    self.currentPageCode = MenuPageEventList;
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.myTableView registerNib:[UINib nibWithNibName:[EventSmallTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[EventSmallTableViewCell reuseIdentifier]];
    [self.myTableView registerNib:[UINib nibWithNibName:[EventBigTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[EventBigTableViewCell reuseIdentifier]];
    [self.myTableView registerNib:[UINib nibWithNibName:[EventGroupSmallTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[EventGroupSmallTableViewCell reuseIdentifier]];
    
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    __weak typeof(self) weakSelf = self;
    
    // refresh new data when pull the table list
    [self.myTableView addPullToRefreshWithActionHandler:^{
        [weakSelf.eventGroupArray removeAllObjects]; // remove all data
        [weakSelf.myTableView reloadData]; // before load new content, clear the existing table list
        [weakSelf getDataFromServer]; // load new data
        [weakSelf.myTableView.pullToRefreshView stopAnimating]; // clear the animation
    }];
    
    [self getDataFromServer];
}

-(void)getDataFromServer{
    [self.eventGroupArray removeAllObjects];
    
    [self.view startLoader:YES disableUI:NO];
    [EventGroup getAllEventGroupsWithAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation * _Nonnull operation, NSArray * _Nonnull evGrArray) {
        self.eventGroupArray = [NSMutableArray arrayWithArray:evGrArray];
        [self.view startLoader:NO disableUI:NO];
        [self.myTableView reloadData];
    } failure:^(RKObjectRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        [self.view startLoader:NO disableUI:NO];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            return 204.0;
        }else{
            return 90.0;
        }
    }else{
        return 151.0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return eventGroupArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    EventGroup *eventGr = [self.eventGroupArray objectAtIndex:section];
    if(section == 0){
        return [eventGr.event_group_events array].count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            EventBigTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[EventBigTableViewCell reuseIdentifier]];
            EventGroup *aGroup = [self.eventGroupArray objectAtIndex:indexPath.section];
            Event *aEvent = [aGroup.event_group_events array][0];
            [cell fillWithEvent:aEvent];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            EventSmallTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[EventSmallTableViewCell reuseIdentifier]];
            EventGroup *aGroup = [self.eventGroupArray objectAtIndex:indexPath.section];
            Event *aEvent = [aGroup.event_group_events array][indexPath.row];
            [cell fillWithEvent:aEvent];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }else{
        EventGroupSmallTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[EventGroupSmallTableViewCell reuseIdentifier]];
        EventGroup *aGroup = [self.eventGroupArray objectAtIndex:indexPath.section];
        cell.delegate = self;
        [cell fillWithEventGroup:aGroup];
        return cell;
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section ==0)
        return 0.0;
    else
        return 40.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectHeaderView = [UIView new];
    sectHeaderView.frame = CGRectMake(0, 0, self.myTableView.frame.size.width,40.0);
    EventGroup *evGroup = [eventGroupArray objectAtIndex:section];
    if(section !=0){
        sectHeaderView.backgroundColor = [UIColor whiteColor];
        CustomSemiBoldLabel *titleLabel = [[CustomSemiBoldLabel alloc] initWithFrame:CGRectMake(10, 0, 320-15, 40)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = [UIFont fontWithName:InterfaceStr(@"default_font_semi_bold") size:14.0];
        titleLabel.textColor = HEXCOLOR(0x333333ff);
        titleLabel.text = evGroup.event_group_name;
        [sectHeaderView addSubview:titleLabel];
        
    }
    return sectHeaderView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0){
        EventGroup *evGroup = self.eventGroupArray[indexPath.section];
        [self.navigationController pushViewController:[[EventDetailViewController alloc] initWithEvent:evGroup.event_group_events[indexPath.row]] animated:YES];
    }else{
        return;
    }
}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = HEXCOLOR(0xEEEEEEFF);
}

-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];

}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)didSelectEvent:(Event *)aEvent{
    [self.navigationController pushViewController:[[EventDetailViewController alloc] initWithEvent:aEvent] animated:YES];
}

@end
