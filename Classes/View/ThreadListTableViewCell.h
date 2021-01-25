//
//  ThreadListTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/13/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThreadListTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *myImageView;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *titleLabel;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *timeLabel;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *likeCountLabel;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *commentCountLabel;

-(void)fillWithDummyData;
-(void)fillWithThread:(Thread *)obj;
+(NSString *)reuseIdentifier;
@end
