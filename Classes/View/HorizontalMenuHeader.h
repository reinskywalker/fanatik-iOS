//
//  HorizontalMenuHeader.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/30/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeView.h"

@protocol HorizontalMenuHeaderDelegate <NSObject>

-(void)didSelectButtonAtIndex:(int)idx;

@end

@interface HorizontalMenuHeader : UITableViewHeaderFooterView


@property (weak,nonatomic) id <HorizontalMenuHeaderDelegate> delegate;
@property(nonatomic, assign)int selectedIndex;
@property (strong, nonatomic) IBOutlet SwipeView *horizontalMenu;

-(void)setupMenuWithArray:(NSArray *)menuArr;
+(NSString *)reuseIdentifier;

@end
