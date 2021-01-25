//
//  DMKeyboardView.h
//  DMMoviePlayer
//
//  Created by Teguh Hidayatullah on 10/22/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeView.h"
#import "StickerCollectionViewCell.h"
#import "TLTagsControl.h"
#import "MintAnnotationChatView.h"

@class DMKeyboardView;
@protocol DMKeyboardViewDelegate <NSObject>
-(void)DMKeyboardViewDelegateStickerTapped:(DMKeyboardView *)chatView;
-(void)DMKeyboardViewDelegateNeedToLogin:(DMKeyboardView *)chatView;
-(void)DMKeyboardViewDelegateSendComment:(DMKeyboardView *)chatView WithContent:(NSString *)content andTaggedUser:(NSArray *)userArray;
-(void)DMKeyboardViewDelegateSendComment:(DMKeyboardView *)chatView WithStickerId:(NSString *)stickerId;
-(void)DMKeyboardViewDelegateAutoComplete:(DMKeyboardView *)chatView withArray:(NSArray *)userArray;
-(void)DMKeyboardViewDelegateResizeTextBox:(DMKeyboardView *)chatView withHeight:(CGFloat)boxHeight;
@end

@interface DMKeyboardView : UIView<SwipeViewDataSource, SwipeViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, SRWebSocketDelegate, UITextViewDelegate>

@property (assign, nonatomic) IBOutlet id <DMKeyboardViewDelegate> delegate;
-(void)initializeView;

@property(nonatomic, assign) float stickerBoxHeight;
@property(nonatomic, assign) int stickerVisibleItems;
@property(nonatomic, assign) int stickerMenuSelectedIndex;

@property(nonatomic, retain) NSMutableArray *stickerCategoryArray;
@property(nonatomic, assign) float chatBoxHeight;
@property(nonatomic, assign) BOOL isStickerPresent;
//@property(nonatomic, strong) TLTagsControl *chatTagTF;
@property(nonatomic, retain) MintAnnotationChatView *chatTextView;

@property(nonatomic, retain) UIButton *forceLoginButton;
@property(nonatomic, assign) BOOL canTagging;

@property(nonatomic, retain) SRWebSocket *webSocket;
@property(nonatomic, retain) NSMutableDictionary *webSocketParameter;
@property(nonatomic, retain) NSString *visitorId;
@property(nonatomic, retain) UIButton *stickerButton;

- (void)connectWebSocket;
- (void)disconnectWebSocket;
- (void)addTagWithUser:(User *)user;
@end
