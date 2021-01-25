//
//  WhisperListTableViewCell.h
//  DMMoviePlayer
//
//  Created by Teguh Hidayatullah on 10/29/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WhisperListTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

+(NSString *)reuseIdentifier;
-(void)fillWithUserName:(NSString *)name;
@end
