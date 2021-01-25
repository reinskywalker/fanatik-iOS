//
//  ProfileCustomHeader.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/30/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "ProfileCustomHeader.h"

@interface ProfileCustomHeader ()



@end

@implementation ProfileCustomHeader

@synthesize delegate, selectedIndex;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)setupCellForModerate:(BOOL)moderate{
    self.threeTabsView.hidden = moderate;
    self.fourTabsView.hidden = !moderate;
    [self setUpCell];
}

-(void)setUpCell{

    [self.videoButton setTitleColor:HEXCOLOR(0x666666FF) forState:UIControlStateNormal];
    [self.videoButton2 setTitleColor:HEXCOLOR(0x666666FF) forState:UIControlStateNormal];
    [self.playlistButton setTitleColor:HEXCOLOR(0x666666FF) forState:UIControlStateNormal];
    [self.activityButton setTitleColor:HEXCOLOR(0x666666FF) forState:UIControlStateNormal];
    [self.playlistButton2 setTitleColor:HEXCOLOR(0x666666FF) forState:UIControlStateNormal];
    [self.activityButton2 setTitleColor:HEXCOLOR(0x666666FF) forState:UIControlStateNormal];
    [self.moderasiButton setTitleColor:HEXCOLOR(0x666666FF) forState:UIControlStateNormal];
    
    switch (self.selectedIndex) {
        case ProfileModeVideo:{
            [self.videoButton setTitleColor:HEXCOLOR(0x333333FF) forState:UIControlStateNormal];
            [self.videoButton2 setTitleColor:HEXCOLOR(0x333333FF) forState:UIControlStateNormal];
        }
            break;
            
        case ProfileModePlaylist:{
            [self.playlistButton setTitleColor:HEXCOLOR(0x333333FF) forState:UIControlStateNormal];
            [self.playlistButton2 setTitleColor:HEXCOLOR(0x333333FF) forState:UIControlStateNormal];
        }
            break;
            
        case ProfileModeActivity:{
            [self.activityButton setTitleColor:HEXCOLOR(0x333333FF) forState:UIControlStateNormal];
            [self.activityButton2 setTitleColor:HEXCOLOR(0x333333FF) forState:UIControlStateNormal];
        }
            break;
        case ProfileModeModerasi:{
            [self.moderasiButton setTitleColor:HEXCOLOR(0x333333FF) forState:UIControlStateNormal];
        }break;
            
        default:
            break;
    }

}

-(IBAction)videoButtonTapped:(id)sender{
    self.selectedIndex = ProfileModeVideo;
    [self callDelegate];
}

-(IBAction)playlistButtonTapped:(id)sender{
    self.selectedIndex = ProfileModePlaylist;
    [self callDelegate];
}

-(IBAction)activityButtonTapped:(id)sender{
    self.selectedIndex = ProfileModeActivity;
    [self callDelegate];
}

-(IBAction)moderasiButtonTapped:(id)sender{
    self.selectedIndex = ProfileModeModerasi;
    [self callDelegate];
}

-(void)callDelegate{
    [self setUpCell];
    
    if([delegate respondsToSelector:@selector(didSelectButtonAtIndex:)]){
        [delegate didSelectButtonAtIndex:self.selectedIndex];
    }
}

@end
