//
//  Fanatik
//
//  Created by Teguh Hidayatullah on 11/16/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "LiveChatViewController.h"
#import "LiveChatCollectionViewCell.h"
#import "LiveChatHeaderView.h"
#import "LiveChatFooterView.h"
#import "LiveChatDetailViewController.h"
#import "BroadcasterOfflineModel.h"

@interface LiveChatViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, retain) NSMutableArray *liveBroadcasterArray;
@property(nonatomic, retain) NSMutableArray *offlineBroadcasterArray;

@end


@implementation LiveChatViewController
@synthesize myCollectionView;

-(instancetype)init{
    if(self = [super init]){
        self.liveBroadcasterArray = [NSMutableArray array];
        self.offlineBroadcasterArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *cellNib = [UINib nibWithNibName:[LiveChatCollectionViewCell reuseIdentifier] bundle:nil];
    [self.myCollectionView registerNib:cellNib forCellWithReuseIdentifier:[LiveChatCollectionViewCell reuseIdentifier]];
    
    UINib *headerNib = [UINib nibWithNibName:[LiveChatHeaderView reuseIdentifier] bundle:nil];
    [self.myCollectionView registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[LiveChatHeaderView reuseIdentifier]];
    
    UINib *footerNib = [UINib nibWithNibName:[LiveChatFooterView reuseIdentifier] bundle:nil];
    [self.myCollectionView registerNib:footerNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[LiveChatFooterView reuseIdentifier]];

    [self getDataFromServer];
}

-(void)getDataFromServer{
    
    [self.liveBroadcasterArray removeAllObjects];
    [self.offlineBroadcasterArray removeAllObjects];
    
    [BroadcasterOnline getHistoryBroadcastersListWithAccessToken:ACCESS_TOKEN() pageNumber:@(0) success:^(RKObjectRequestOperation *operation, NSArray *resultsArray) {
        
        NSData *responseData = operation.HTTPRequestOperation.responseData;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
        
        [self.liveBroadcasterArray addObjectsFromArray:resultsArray];
        
        NSArray *broadcasterOfflineArray = json[@"broadcasters"];
        for(NSDictionary *broadOffDict in broadcasterOfflineArray){
            BroadcasterOfflineModel *broadOffMod = [[BroadcasterOfflineModel alloc] initWithDictionary:broadOffDict];
            [self.offlineBroadcasterArray addObject:broadOffMod];
        }
        
        self.blankLabel.hidden = resultsArray.count>0 || broadcasterOfflineArray.count>0?YES:NO;
        self.myCollectionView.hidden = !self.blankLabel.hidden;
        [self.myCollectionView reloadData];
        
    } failure:^(RKObjectRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        self.blankLabel.hidden = NO;
        self.myCollectionView.hidden = YES;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark – UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        
        BroadcasterOnline *br = [self.liveBroadcasterArray objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:[[LiveChatDetailViewController alloc]initWithBroadcaster:br] animated:YES];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = HEXCOLOR(0xEEEEEEFF);
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = HEXCOLOR(0xFFFFFFFF);
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return section==0?[self.liveBroadcasterArray count]:[self.offlineBroadcasterArray count];
    
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    if(!(IS_IPAD)){
        
        float cellWidth = (screenWidth-30) / 2.0; //Replace the divisor with the column count requirement. Make sure to have it in float.
        CGSize size = CGSizeMake(cellWidth, 135.0);
        return size;
    }else{
        int cellWidth = (screenWidth-40) / 3; //Replace the divisor with the column count requirement. Make sure to have it in float.
        CGSize size = CGSizeMake(cellWidth, 135.0);
        return size;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LiveChatCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:[LiveChatCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    
    if(indexPath.section == 0){
        BroadcasterOnline *broadOnline = self.liveBroadcasterArray[indexPath.row];
        [cell setBroadcasterOnline:broadOnline];
    }else{
        BroadcasterOfflineModel *broadOffline = self.offlineBroadcasterArray[indexPath.row];
        [cell setBroadcasterOffline:broadOffline];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds), 30.0);
    }else {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds), 54.0);
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if (kind == UICollectionElementKindSectionHeader) {
    
        LiveChatHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[LiveChatHeaderView reuseIdentifier] forIndexPath:indexPath];
        NSString *title = indexPath.section==0?@"":@"Offline";
        headerView.titleLabel.text = title;

        return headerView;
        
    }else if(kind == UICollectionElementKindSectionFooter){
        LiveChatFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[LiveChatFooterView reuseIdentifier] forIndexPath:indexPath];
        
        return footerView;
    }
    return nil;
}

@end
