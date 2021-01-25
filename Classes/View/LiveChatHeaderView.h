//
//  Fanatik
//
//  Created by Teguh Hidayatullah on 11/16/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveChatHeaderView : UICollectionReusableView

@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
+(NSString *)reuseIdentifier;
@end
