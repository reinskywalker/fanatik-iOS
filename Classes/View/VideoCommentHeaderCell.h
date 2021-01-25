//
//  VideoCommentTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCommentHeaderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet DTAttributedLabel *commentCountLabel;

+(NSString *)reuseIdentifier;
- (void)fillWithLive:(Live *)obj;
- (void)fillWithClip:(Clip*)obj;

@end
