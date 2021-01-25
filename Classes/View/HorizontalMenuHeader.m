//
//  HorizontalMenuHeader.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/30/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "HorizontalMenuHeader.h"

@interface HorizontalMenuHeader ()<SwipeViewDataSource, SwipeViewDelegate>
@property(nonatomic, retain) NSArray *menuArray;
@property(nonatomic, assign) int visibleItems;

@end

@implementation HorizontalMenuHeader

@synthesize delegate, selectedIndex, menuArray, horizontalMenu, visibleItems;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

-(void)setupMenuWithArray:(NSArray *)menuArr{
    self.horizontalMenu.delegate = self;
    self.horizontalMenu.dataSource = self;
//    self.horizontalMenu.currentItemIndex = self.selectedIndex;
    self.horizontalMenu.alignment = SwipeViewAlignmentEdge;
    self.horizontalMenu.pagingEnabled = NO;
    self.horizontalMenu.itemsPerPage  = self.visibleItems = menuArr.count;
    self.horizontalMenu.truncateFinalPage = YES;
//    self.selectedIndex = 0;
    self.menuArray = menuArr;
}

- (void)awakeFromNib {
    // Initialization code
}

#pragma mark -
#pragma mark SwipeHorizontalMenu methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    //return the total number of items in the carousel
    return [menuArray count];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ceilf(horizontalMenu.frame.size.width)/visibleItems, horizontalMenu.frame.size.height)];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.backgroundColor = [UIColor clearColor];
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:InterfaceStr(@"default_font_bold") size:12.0];
        label.textColor = index == selectedIndex ? HEXCOLOR(0x333333FF) : HEXCOLOR(0x3333337F);
        label.tag = 1;
        [view addSubview:label];
        
        UIView *sideSeparator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.frame)-1, 0, 1.0, CGRectGetHeight(view.frame))];
        sideSeparator.backgroundColor = HEXCOLOR(0xD6D6D6FF);
        
      
        if(index < visibleItems-1)
            [view addSubview:sideSeparator];
        
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    label.textColor = index == selectedIndex ? HEXCOLOR(0x333333FF) : HEXCOLOR(0x3333337F);
    label.text =  [menuArray[index] uppercaseString];
    
    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return CGSizeMake(ceilf(horizontalMenu.frame.size.width)/visibleItems, horizontalMenu.frame.size.height);
}

-(void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index{
    self.selectedIndex = (int)index;
    [self.horizontalMenu reloadData];
    [delegate didSelectButtonAtIndex:(int)index];
}



@end
