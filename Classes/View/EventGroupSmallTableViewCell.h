//
//  EventGroupSmallTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/12/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventCollectionViewCell.h"

@protocol EventGroupSmallTableViewCellDelegate <NSObject>

-(void)didSelectEvent:(Event *)aEvent;

@end

@interface EventGroupSmallTableViewCell : UITableViewCell<UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic, weak) id <EventGroupSmallTableViewCellDelegate> delegate;

@property(nonatomic, retain) IBOutlet UICollectionView *eventCollectionView;
@property(nonatomic, retain) EventGroup *currentEventGroup;
@property(nonatomic, retain) NSArray *eventsArray;
@property(nonatomic, assign) NSInteger currentIndexSection;

+(NSString *)reuseIdentifier;

-(void)fillWithEventGroup:(EventGroup *)group;

@end
