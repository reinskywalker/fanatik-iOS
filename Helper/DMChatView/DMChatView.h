//
//  DMChatView.h
//  DMMoviePlayer
//
//  Created by Teguh Hidayatullah on 10/22/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeView.h"
#import "MeTableViewCell.h"
#import "OtherTableViewCell.h"
#import "StickerCollectionViewCell.h"
#import "Message.h"
#import "ATPagingView.h"

@class DMChatView;
@protocol DMChatViewDelegate <NSObject>

-(void)DMChatViewDelegateKeyboardWillShow:(DMChatView *)chatView;
-(void)DMChatViewDelegateKeyboardWillHide:(DMChatView *)chatView;
-(void)DMChatViewDelegate:(DMChatView *)chatView didSelectHorizontalMenuAtIndex:(NSInteger)idx;
-(void)DMChatViewDelegate:(DMChatView *)chatView didTapChatUser:(Message *)chat;
-(void)DMChatViewDelegateOpenWhisperListView:(DMChatView *)chatView;
-(void)DMChatViewDelegateNeedToLogin:(DMChatView *)chatView;
@end

typedef enum{
    ChatTypePublic = 0,
    ChatTypeWhisper = 1
}ChatType;

typedef enum{
    EmojiKeyboardTypeInitiate = 0,
    EmojiKeyboardTypeShown = 1,
    EmojiKeyboardTypeHide = 2,
    EmojiKeyboardTypeSticker = 3
} EmojiKeyboardType;

@interface DMChatView : UIView<UITableViewDataSource, UITableViewDelegate, SwipeViewDataSource, SwipeViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, SRWebSocketDelegate, ATPagingViewDelegate>


@property (assign, nonatomic) IBOutlet id <DMChatViewDelegate> delegate;
-(void)initializeView;

@property(nonatomic, assign) EmojiKeyboardType emojiType;
@property(nonatomic, assign) float headerHeight;
@property(nonatomic, assign) int headerVisibleItems;

@property(nonatomic, retain) NSArray *headerMenuTextArray;
@property(nonatomic, retain) UITableView *chatPublicTableView;
@property(nonatomic, retain) UITableView *chatWhisperTableView;

@property(nonatomic, retain) ATPagingView *chatPagingView;
@property(nonatomic, assign) float stickerBoxHeight;
@property(nonatomic, assign) int stickerVisibleItems;
@property(nonatomic, assign) int stickerMenuSelectedIndex;

@property(nonatomic, retain)NSMutableArray *messageArray;
@property(nonatomic, retain)NSMutableArray *whisperMessageArray;
@property(nonatomic, retain)NSMutableArray *stickerCategoryArray;
@property(nonatomic, assign) float chatBoxHeight;
@property(nonatomic, assign) BOOL isStickerPresent;
@property(nonatomic, assign) ChatType currentChatType;
@property(nonatomic, retain) NSMutableArray *whisperChatUserArray;
@property(nonatomic, retain) User *currentWhisperChatUser;
@property(nonatomic, retain) UITextField *chatTF;

@property(nonatomic, retain) SRWebSocket *webSocket;
@property(nonatomic, retain) NSMutableDictionary *webSocketParameter;
@property(nonatomic, retain) BroadcasterOnline *currentBroadcaster;
@property(nonatomic, retain) NSString *visitorId;
@property(nonatomic, retain) UIButton *forceLoginButton;

- (void)connectWebSocket;
- (void)disconnectWebSocket;
-(void)addedUserToWhisper;

@end
