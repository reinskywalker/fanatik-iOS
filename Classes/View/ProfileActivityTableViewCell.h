//
//  ProfileActivityTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/29/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProfileActivityTableViewCell : UITableViewCell

+(NSString *)reuseIdentifier;
-(void)fillWithActivity:(Activity *)obj;

@end
