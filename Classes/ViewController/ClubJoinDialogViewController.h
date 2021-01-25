//
//  ClubJoinDialogViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/22/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"

@protocol ClubJoinDialogViewControllerDelegate <NSObject>

-(void)dialogDidClose:(Club *)currClub;


@end

@interface ClubJoinDialogViewController : ParentViewController


@property (nonatomic, retain) Club *currentClub;

@property (nonatomic, weak) id <ClubJoinDialogViewControllerDelegate> delegate;



-(id)initWithClub:(Club *)club;
@end
