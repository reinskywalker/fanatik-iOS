//
//  DMChatView.m
//  DMMoviePlayer
//
//  Created by Teguh Hidayatullah on 10/22/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "DMChatView.h"
#import "UIView+SDCAutoLayout.h"
#import "Sticker.h"
#import "TopUpView.h"
#import "Balance.h"
#import "UIView+RNActivityView.h"
#import "StatusTextTableViewCell.h"

typedef enum{
    ConnectingStatusIdle = 0,
    ConnectingStatusTryingToConnect = 1,
    ConnectingStatusConnected = 2,
    ConnectingStatusDisconnected = 3
} ConnectingStatus;

@interface DMChatView()<UITextFieldDelegate, OtherTableViewCellDelegate, UIGestureRecognizerDelegate>
@property(nonatomic, retain) IBOutlet UICollectionView *stickerCollectionView;
@property(nonatomic, retain) CustomBoldLabel *remainingBalanceLabel;
@property(nonatomic, retain) SwipeView *headerMenu;
@property(nonatomic, retain) SwipeView *stickerMenu;
@property(nonatomic, retain) NSLayoutConstraint *chatBoxBottomConstraint;
@property(nonatomic, retain) UIView *stickerView;
@property(nonatomic, retain) UIView *balanceView;
@property(nonatomic, retain) UIButton *stickerButton;
@property(nonatomic, retain) UIButton *sendButton;
@property(nonatomic, assign) int unreadMessageCounter;
@property(nonatomic, retain) TopUpView *topUpView;
@property(nonatomic, assign) BOOL isBalanceViewShown;
@property(nonatomic, retain) UIView *chatBoxContainer;
@property(nonatomic, assign) ConnectingStatus connectingStatus;
@end

@implementation DMChatView
@synthesize chatPublicTableView, chatWhisperTableView;
@synthesize headerMenu, headerHeight, headerVisibleItems, chatBoxHeight, chatTF, messageArray, stickerBoxHeight, stickerView, stickerVisibleItems, stickerMenu, isStickerPresent, whisperChatUserArray, currentWhisperChatUser, remainingBalanceLabel, sendButton;
@synthesize stickerButton, webSocket, webSocketParameter, currentBroadcaster;
@synthesize visitorId, unreadMessageCounter, whisperMessageArray, stickerCategoryArray;
@synthesize emojiType, balanceView, topUpView;
@synthesize isBalanceViewShown, chatPagingView, chatBoxContainer, forceLoginButton;
@synthesize connectingStatus;

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        self.whisperChatUserArray = [NSMutableArray array];
        self.messageArray = [NSMutableArray array];
        self.whisperMessageArray = [NSMutableArray array];
        self.unreadMessageCounter = 0;
        self.emojiType = EmojiKeyboardTypeInitiate;
        self.isBalanceViewShown = NO;
        self.isStickerPresent = NO;
        self.stickerMenuSelectedIndex = 0;
        self.connectingStatus = ConnectingStatusIdle;
    }
    return self;
}

-(void)initializeView{
    [self addKeyboardbserver];
    
    //initialize host user

    //initialize sticker view
    self.stickerCategoryArray = [NSMutableArray arrayWithArray:[TheDatabaseManager getAllStickerCategorys]];
    
    [TheServerManager getAllStickersWithCompletion:^(NSArray *stickersArray) {
        self.stickerCategoryArray = [NSMutableArray arrayWithArray:[TheDatabaseManager getAllStickerCategorys]];
        [self.stickerCollectionView reloadData];
    } andFailure:nil];
    
    //Chat Public table view
    self.chatPublicTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.chatPublicTableView.delegate = self;
    self.chatPublicTableView.dataSource = self;
    self.chatPublicTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatPublicTableView.rowHeight = UITableViewAutomaticDimension;
    self.chatPublicTableView.estimatedRowHeight = 70.0;

    //Chat Whisper table view
    self.chatWhisperTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.chatWhisperTableView.delegate = self;
    self.chatWhisperTableView.dataSource = self;
    self.chatWhisperTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatWhisperTableView.rowHeight = UITableViewAutomaticDimension;
    self.chatWhisperTableView.estimatedRowHeight = 70.0;
        
    //register cell
    [self.chatPublicTableView registerNib:[UINib nibWithNibName:NSStringFromClass([MeTableViewCell class]) bundle:nil] forCellReuseIdentifier:[MeTableViewCell reuseIdentifier]];
    [self.chatPublicTableView registerNib:[UINib nibWithNibName:NSStringFromClass([OtherTableViewCell class]) bundle:nil] forCellReuseIdentifier:[OtherTableViewCell reuseIdentifier]];
    [self.chatPublicTableView registerNib:[UINib nibWithNibName:NSStringFromClass([StatusTextTableViewCell class]) bundle:nil] forCellReuseIdentifier:[StatusTextTableViewCell reuseIdentifier]];
    
    [self.chatWhisperTableView registerNib:[UINib nibWithNibName:NSStringFromClass([MeTableViewCell class]) bundle:nil] forCellReuseIdentifier:[MeTableViewCell reuseIdentifier]];
    [self.chatWhisperTableView registerNib:[UINib nibWithNibName:NSStringFromClass([OtherTableViewCell class]) bundle:nil] forCellReuseIdentifier:[OtherTableViewCell reuseIdentifier]];
        
    //Chat ATPagingView
    self.chatPagingView = [[ATPagingView alloc]initWithFrame:CGRectMake(0, 0, TheAppDelegate.deviceWidth, 300)];
    self.chatPagingView.delegate = self;
    self.chatPagingView.backgroundColor = [UIColor whiteColor];
    self.chatPagingView.currentPageIndex = ChatTypePublic;
    [self addSubview:chatPagingView];
    self.chatPagingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.chatPagingView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.chatPagingView sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:self];
    [self.chatPagingView sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:self];
    [self.chatPagingView reloadData];

    //Chat Header SwipeView
    self.headerMenu = [[SwipeView alloc] initWithFrame:CGRectMake(0, 0, self.chatPagingView.frame.size.width, self.headerHeight)];
    self.headerMenu.delegate = self;
    self.headerMenu.dataSource = self;
    self.headerMenu.alignment = SwipeViewAlignmentEdge;
    self.headerMenu.pagingEnabled = NO;
    self.headerMenu.itemsPerPage = self.headerVisibleItems;
    self.headerMenu.truncateFinalPage = YES;
    [self addSubview:self.headerMenu];
    [self.headerMenu setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.headerMenu sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:self];
    [self.headerMenu sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:self];
    [self.headerMenu sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:self];
    [self.headerMenu sdc_alignEdge:UIRectEdgeBottom withEdge:UIRectEdgeTop ofView:self.chatPagingView];
    [self.headerMenu sdc_pinHeight:self.headerHeight];
    
    //chat box
    chatBoxContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-self.chatBoxHeight, self.chatPagingView.frame.size.width, self.chatBoxHeight)];
    chatBoxContainer.backgroundColor = [UIColor colorWithRed:252/255.0 green:252/255.0 blue:252/255.0 alpha:1.0];
    [self addSubview:chatBoxContainer];
    [chatBoxContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
    [chatBoxContainer sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:self];
    [chatBoxContainer sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:self];
    self.chatBoxBottomConstraint = [chatBoxContainer sdc_alignEdge:UIRectEdgeBottom withEdge:UIRectEdgeBottom ofView:self];
    [chatBoxContainer sdc_pinHeight:self.chatBoxHeight];
    [self.chatPagingView sdc_alignEdge:UIRectEdgeBottom withEdge:UIRectEdgeTop ofView:chatBoxContainer];
    
    //chatbox top border
    UIView *chatBoxTopBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, chatBoxContainer.frame.size.width, 1)];
    chatBoxTopBorder.backgroundColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0];
    [chatBoxContainer addSubview:chatBoxTopBorder];
    [chatBoxTopBorder setTranslatesAutoresizingMaskIntoConstraints:NO];
    [chatBoxTopBorder sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:[chatBoxTopBorder superview]];
    [chatBoxTopBorder sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:[chatBoxTopBorder superview]];
    [chatBoxTopBorder sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:[chatBoxTopBorder superview]];
    [chatBoxTopBorder sdc_pinHeight:1.0];
    
    //chatbox sticker button
    self.stickerButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [stickerButton setImage:[UIImage imageNamed:@"stickerBtn"] forState:UIControlStateNormal];
    [stickerButton setImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateSelected];
    [stickerButton addTarget:self action:@selector(stickerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [chatBoxContainer addSubview:stickerButton];
    [stickerButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [stickerButton sdc_pinHeight:40.0];
    
    User *currentUser = [User fetchLoginUser];
    float widthValue = 0;
    ApplicationSettingModel *appSetting = TheSettingsManager.currentApplicationSetting;
    if(currentUser.user_tester || appSetting.settingStickersComment){
        widthValue = 40.0;
    }
    [stickerButton sdc_pinWidth:widthValue];
    [stickerButton sdc_verticallyCenterInSuperview];
    [stickerButton sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:[stickerButton superview] inset:5.0];
    
    //chatbox send button
    sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    [sendButton setTitleColor:[UIColor colorWithRed:142/255.0 green:142/255.0 blue:147/255.0 alpha:1.0] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [chatBoxContainer addSubview:sendButton];
    [sendButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [sendButton sdc_pinHeight:40.0];
    [sendButton sdc_pinWidth:40.0];
    [sendButton sdc_verticallyCenterInSuperview];
    [sendButton sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:[sendButton superview] inset:-8.0];
    
    //chatbox textfield
    self.chatTF = [[UITextField alloc] initWithFrame:CGRectZero];
    self.chatTF.delegate = self;
    [chatBoxContainer addSubview:self.chatTF];
    chatTF.borderStyle = UITextBorderStyleRoundedRect;
    [chatTF setTranslatesAutoresizingMaskIntoConstraints:NO];
    [chatTF sdc_verticallyCenterInSuperview];
    [chatTF sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeRight ofView:stickerButton inset:0.0];
    [chatTF sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeLeft ofView:sendButton inset:-10.0];
    [chatTF addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.headerMenu reloadData];
    
    //button to force login
    forceLoginButton = [[UIButton alloc] initWithFrame:chatBoxContainer.bounds];
    [forceLoginButton addTarget:self action:@selector(loginFirst) forControlEvents:UIControlEventTouchUpInside];
    [chatBoxContainer addSubview:forceLoginButton];
    
    //sticker view
    self.stickerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:stickerView];
    [stickerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [stickerView sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeBottom ofView:chatBoxContainer];
    [stickerView sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:self];
    [stickerView sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:self];
    [stickerView sdc_pinHeight:self.stickerBoxHeight];
    
    //line on top
    UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
    line.backgroundColor = HEXCOLOR(0xd5d5d5FF);
    [stickerView addSubview:line];
    [line setTranslatesAutoresizingMaskIntoConstraints:NO];
    [line sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:stickerView];
    [line sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:stickerView];
    [line sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:stickerView];
    [line sdc_pinHeight:1.0];
    
    //balance view
    balanceView = [[UIView alloc] initWithFrame:CGRectZero];
    balanceView.backgroundColor = HEXCOLOR(0x404040FF);
    [stickerView addSubview:balanceView];
    [balanceView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [balanceView sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:stickerView];
    [balanceView sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:line];
    [balanceView sdc_pinHeight:34.0];
    [balanceView sdc_pinWidth:68.0];
    
    //coin and balance label on balanceView
    UIImageView *coinImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coin"]];
    coinImg.contentMode = UIViewContentModeCenter;
    [balanceView addSubview:coinImg];
    [coinImg setTranslatesAutoresizingMaskIntoConstraints:NO];
    [coinImg sdc_pinHeight:34.0];
    [coinImg sdc_pinWidth:14.0];
    [coinImg sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:balanceView];
    [coinImg sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:balanceView inset:10.0];
    self.remainingBalanceLabel = [[CustomBoldLabel alloc] initWithFrame:CGRectZero];
    self.remainingBalanceLabel.text = @"0";
    self.remainingBalanceLabel.font = [UIFont fontWithName:InterfaceStr(@"default_font_bold") size:12.0];
    self.remainingBalanceLabel.textColor = HEXCOLOR(0xFFFFFFFF);
    self.remainingBalanceLabel.textAlignment = NSTextAlignmentCenter;
    [balanceView addSubview:remainingBalanceLabel];
    [self.remainingBalanceLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.remainingBalanceLabel sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:balanceView];
    [self.remainingBalanceLabel sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeRight ofView:coinImg inset:-3.0];
    [self.remainingBalanceLabel sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:self.balanceView];
    [self.remainingBalanceLabel sdc_pinHeight:34.0];
    
    //balanceButton on balanceView
    UIButton *balanceButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [balanceButton setTitle:@"" forState:UIControlStateNormal];
    [balanceButton addTarget:self action:@selector(balanceTapped) forControlEvents:UIControlEventTouchUpInside];
    [balanceView addSubview:balanceButton];
    [balanceButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [balanceButton sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:stickerView];
    [balanceButton sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:line];
    [balanceButton sdc_pinHeight:34.0];
    [balanceButton sdc_pinWidth:68.0];
    
    //sticker menu
    self.stickerMenu = [[SwipeView alloc] initWithFrame:CGRectMake(0, 0, self.chatPagingView.frame.size.width, 34.0)];
    self.stickerMenu.delegate = self;
    self.stickerMenu.dataSource = self;
    self.stickerMenu.alignment = SwipeViewAlignmentEdge;
    self.stickerMenu.pagingEnabled = NO;
    self.stickerMenu.itemsPerPage = self.stickerVisibleItems;
    self.stickerMenu.truncateFinalPage = YES;
    [stickerView addSubview:self.stickerMenu];
    [self.stickerMenu setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.stickerMenu sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeBottom ofView:line];
    [self.stickerMenu sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeRight ofView:balanceView];
    [self.stickerMenu sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:stickerView];
    [self.stickerMenu sdc_pinHeight:34.0];
    
    //bottomView
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectZero];
    bottomView.backgroundColor = HEXCOLOR(0xf0f3f3FF);
    [stickerView addSubview:bottomView];
    [bottomView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [bottomView sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:stickerView];
    [bottomView sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeBottom ofView:stickerMenu];
    [bottomView sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:stickerView];
    [bottomView sdc_alignEdge:UIRectEdgeBottom withEdge:UIRectEdgeBottom ofView:stickerView];
    
    //topUp View
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TopUpView class]) owner:self options:nil];
    topUpView = [subviewArray objectAtIndex:0];
    [bottomView addSubview:topUpView];
    [topUpView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [topUpView sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:bottomView];
    [topUpView sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:bottomView];
    [topUpView sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:bottomView];
    [topUpView sdc_alignEdge:UIRectEdgeBottom withEdge:UIRectEdgeBottom ofView:bottomView];
    
    //sticker collection view
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake (10, 10, 0, 10);
    layout.minimumInteritemSpacing = 5.0f;
    layout.minimumLineSpacing = 10.0f;
    self.stickerCollectionView = [[UICollectionView alloc] initWithFrame:stickerView.frame collectionViewLayout:layout];
    self.stickerCollectionView.hidden = isBalanceViewShown;
    [self.stickerCollectionView setDataSource:self];
    [self.stickerCollectionView setDelegate:self];
    self.stickerCollectionView.backgroundColor = HEXCOLOR(0xf0f3f3FF);
    [self.stickerCollectionView registerClass:[StickerCollectionViewCell class] forCellWithReuseIdentifier:[StickerCollectionViewCell reuseIdentifier]];
    
    [self.stickerCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([StickerCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:[StickerCollectionViewCell reuseIdentifier]];
    
    [bottomView addSubview:self.stickerCollectionView];
    [self.stickerCollectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.stickerCollectionView sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:bottomView];
    [self.stickerCollectionView sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:bottomView];
    [self.stickerCollectionView sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:bottomView];
    [self.stickerCollectionView sdc_alignEdge:UIRectEdgeBottom withEdge:UIRectEdgeBottom ofView:bottomView];

    //add background touch to dismsiss keyboard
    UITapGestureRecognizer *gesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackgroundTouch:)]; // Declare the Gesture.
    gesRecognizer.delegate = self;
    [self.chatPagingView addGestureRecognizer:gesRecognizer]; // Add Gesture to your view.

    [self reloadChatData];
}

-(void)reloadChatData{
    
    if (self.currentChatType == ChatTypePublic) {
        [self.chatPublicTableView reloadData];
    }else{
        [self.chatWhisperTableView reloadData];
    }
    
    [self.chatPagingView reloadData];
}

-(void)addedUserToWhisper{
    [self swipeView:self.headerMenu didSelectItemAtIndex:1];
}

#pragma mark - ATPagingViewDelegate methods
- (NSInteger)numberOfPagesInPagingView:(ATPagingView *)apagingView {
    return 2;
}

- (UIView *)viewForPageInPagingView:(ATPagingView *)apagingView atIndex:(NSInteger)index {
    
    UIView *returnView = [[UIView alloc] initWithFrame:apagingView.bounds];
    returnView.backgroundColor = [UIColor whiteColor];
    
    //empty state image
    UIImageView *emptyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"empty-state-chat"]];
    emptyImage.contentMode = UIViewContentModeCenter;
    [returnView addSubview:emptyImage];
    [emptyImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    [emptyImage sdc_pinHeight:64.0];
    [emptyImage sdc_pinWidth:62.0];
    [emptyImage sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:returnView inset:90.0];
    [emptyImage sdc_horizontallyCenterInSuperview];
    
    //empty state label
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [emptyLabel setFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:15.0]];
    emptyLabel.textColor = HEXCOLOR(0xb0b0b0FF);
    emptyLabel.backgroundColor = [UIColor clearColor];
    [emptyLabel setTextAlignment:NSTextAlignmentCenter];
    [returnView addSubview:emptyLabel];
    [emptyLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [emptyLabel sdc_pinHeight:40.0];
    [emptyLabel sdc_pinWidth:300.0];
    [emptyLabel sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:returnView inset:150];
    [emptyLabel sdc_horizontallyCenterInSuperview];

    if(index == ChatTypePublic){
        
        if(messageArray.count > 0){
            returnView = chatPublicTableView;
            
            returnView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [returnView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [returnView sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:self];
            [returnView sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:self];
            
        }else{
            emptyLabel.text = @"Type something to start chatting.";
        }
        
    }else if(index == ChatTypeWhisper){
        
        if(whisperMessageArray.count > 0){
            returnView = chatWhisperTableView;
            
            returnView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [returnView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [returnView sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:self];
            [returnView sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:self];
            
        }else{
            emptyLabel.text = @"Start chat with broadcaster.";
        }
    }
    
    returnView.frame = chatPagingView.bounds;
    return returnView;
}

- (void)pagingViewWillBeginMoving:(ATPagingView *)apagingView{
    
}

- (void)pagingViewDidEndMoving:(ATPagingView *)apagingView{
    [self swipeView:self.headerMenu didSelectItemAtIndex:apagingView.currentPageIndex];
}

#pragma mark - SRWebSocket Delegate
- (void)disconnectWebSocket{
    [webSocket close];
    webSocket.delegate = nil;
    webSocket = nil;
}

- (void)connectWebSocket{

    if(self.connectingStatus == ConnectingStatusDisconnected || self.connectingStatus == ConnectingStatusIdle){
        [self showActivityViewWithLabel:@"Connecting"];
    }

    self.connectingStatus = ConnectingStatusTryingToConnect;
    
    webSocket.delegate = nil;
    webSocket = nil;

    [webSocket close];
    
    webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:TheConstantsManager.chatURL]]];
    webSocket.delegate = self;
    [webSocket open];
}

- (void)webSocketDidOpen:(SRWebSocket *)newWebSocket {
    webSocket = newWebSocket;
    [webSocket send:[self convertDictToJSON:webSocketParameter]];
    
    self.connectingStatus = ConnectingStatusConnected;
    [self hideActivityView];
}

- (void)webSocket:(SRWebSocket *)wbSocket didFailWithError:(NSError *)error {
    
    if(self.connectingStatus == ConnectingStatusConnected){
        Message *dcMessage = [[Message alloc] init];
        dcMessage.messageContent = @"Disconnect";
        dcMessage.messageUserName = @"";
        dcMessage.messageType = MessageTypeDisconnected;

        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];
        dcMessage.dateString = [dateFormat stringFromDate:today];
        
        [self.chatTF resignFirstResponder];
        [self.messageArray addObject:dcMessage];
        [self.chatPublicTableView reloadData];
        self.connectingStatus = ConnectingStatusDisconnected;
    }
    
    [self connectWebSocket];

}

- (void)webSocket:(SRWebSocket *)wbSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    self.webSocketParameter[@"params"][@"initial_join"] = @(0);

    [self connectWebSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)jsonString {
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    ChatType receivedChat;
    
    NSString *eventType = json[@"message"][@"event"];
    Balance *currentBalance = nil;
    Message *msg = nil;
    
    if([eventType isEqualToString:@"userBalance"]){
        //data balance
        currentBalance = [[Balance alloc] initWithDictionary:json[@"message"][@"data"]];
    }else if(eventType && ![eventType isEqualToString:@"updateMemberList"] && ![eventType isEqualToString:@"userBalance"]){
        //data message
        msg = [[Message alloc] initWithJSON:json];
    }

    if(msg){
        if([msg.messageEvent isEqualToString:@"directChat"]){
            [self.whisperMessageArray addObject:msg];
            receivedChat = ChatTypeWhisper;
            if (self.currentChatType == ChatTypePublic) {
                unreadMessageCounter += 1;
            }
        }else{
            [self.messageArray addObject:msg];
            receivedChat = ChatTypePublic;
        }
        [self reloadChatData];
        [self.headerMenu reloadData];

        CGFloat currentOffset = chatPublicTableView.contentOffset.y;
        CGFloat maximumOffset = chatPublicTableView.contentSize.height - chatPublicTableView.frame.size.height;
        
        if(self.currentChatType == receivedChat && [msg.messageUserId isEqualToString:webSocketParameter[@"params"][@"id"]]){

            //if user is the one who type
            [self tableViewScrollToBottom];
            
        }else if(self.currentChatType == receivedChat && maximumOffset - currentOffset <= self.chatBoxHeight + 70.0){
            // add chat box height toleration cell height 70px to make sure it's scrolled
            // if user already on the bottom auto scroll
            
            [self tableViewScrollToBottom];
        }
    }else if(currentBalance){
        [topUpView reloadDataWithBalance:currentBalance];
        self.remainingBalanceLabel.text = currentBalance.balanceAmountText;
    }else if(json[@"error"]){
        
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
        [UIAlertView showWithTitle:appName message:json[@"error"] cancelButtonTitle:@"Close" otherButtonTitles:@[@"Top Up"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            if(buttonIndex != alertView.cancelButtonIndex){
                if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Top Up"]){
                    [topUpView topUpButtonTapped:nil];
                }
            }
        }];
    }
}

#pragma mark - UICollectionView Delegate
-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];// HEXCOLOR(0xf0f9f9FF);
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(self.stickerCategoryArray.count > 0){
        StickerCategory *cat = self.stickerCategoryArray[self.stickerMenuSelectedIndex];
        return cat.stickerArray.count;
    }else{
        return 0;
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StickerCollectionViewCell *cell= (StickerCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:[StickerCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    
    cell.layer.cornerRadius = 4.0f;
    cell.layer.borderWidth = 1.0f;
    cell.layer.borderColor = [UIColor clearColor].CGColor;
    cell.layer.masksToBounds = YES;
    
    StickerCategory *cat = self.stickerCategoryArray[self.stickerMenuSelectedIndex];
    Sticker *stick = [cat.stickerArray objectAtIndex:indexPath.row];
    [cell fillCellWithSticker:stick];
    
    return cell;

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(52, 62);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //select sticker
    
    if(![User fetchLoginUser]){
        if([self.delegate respondsToSelector:@selector(DMChatViewDelegateNeedToLogin:)]){
            [self.delegate DMChatViewDelegateNeedToLogin:self];
        }
    }else{

        if(webSocket.readyState == SR_OPEN){
            [collectionView deselectItemAtIndexPath:indexPath animated:YES];
            
            [chatTF resignFirstResponder];
            StickerCategory *cat = self.stickerCategoryArray[self.stickerMenuSelectedIndex];
            Sticker *stick = [cat.stickerArray objectAtIndex:indexPath.row];
            
            NSMutableDictionary *dictParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              @"sendMessage", @"action",
                                              [NSString stringWithFormat:@"broadcaster_%@", currentBroadcaster.broadon_user_id], @"roomName",
                                              [stick getDictionary], @"message",
                                              nil];
            
            if(self.currentChatType == ChatTypeWhisper){
                dictParam[@"recipientId"] = self.currentBroadcaster.broadon_user_id;
            }
            NSDictionary *dictResult = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"action", @"event",
                                        dictParam, @"params",
                                        nil];
            
            [webSocket send:[self convertDictToJSON:dictResult]];
            
            [self textFieldChanged:self.chatTF];
        }
    }
}

#pragma mark -
#pragma mark SwipeheaderMenu methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    //return the total number of items in the carousel
    
    if(swipeView == headerMenu){
        return self.headerMenuTextArray.count;
    }else{
        return self.stickerCategoryArray.count;
    }
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    UIView *bottomSeparator = nil;
    UIView *selectedBottomSeparator = nil;
    UILabel *messageCountLabel = nil;
    UIView *verticalSeparator = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        CGRect modifiedRect = CGRectZero;
        
        if(swipeView == headerMenu){
            modifiedRect.size.width = ceilf(headerMenu.frame.size.width)/self.headerVisibleItems;
            modifiedRect.size.height = headerMenu.frame.size.height;
        }else{
            
            CGFloat width = ceilf(stickerView.frame.size.width - balanceView.frame.size.width)/self.stickerVisibleItems;
            
            if(self.stickerCategoryArray.count > 2){
                width = ceilf(stickerView.frame.size.width - balanceView.frame.size.width - 30.0)/self.stickerVisibleItems;
            }
            modifiedRect.size.width = width;
            modifiedRect.size.height = stickerView.frame.size.height;
        }
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, modifiedRect.size.width, modifiedRect.size.height)];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.backgroundColor = [UIColor clearColor];
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:14.0];
        
        label.tag = 1;
        [view addSubview:label];
        
        CGRect bottomRect = CGRectZero;
        
        if(swipeView == headerMenu){
            bottomRect.origin.y = CGRectGetHeight(headerMenu.frame);
        }else{
            bottomRect.origin.y = CGRectGetHeight(stickerMenu.frame);
        }
        
        bottomSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, bottomRect.origin.y-1, CGRectGetWidth(view.frame), 1.0)];
        bottomSeparator.tag = 2;
        bottomSeparator.backgroundColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0];
        [view addSubview:bottomSeparator];
        
        verticalSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1.0, CGRectGetHeight(view.frame))];
        verticalSeparator.tag = 5;
        verticalSeparator.backgroundColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0];
        [view addSubview:verticalSeparator];
        
        selectedBottomSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, bottomRect.origin.y - 2, CGRectGetWidth(view.frame), 2.0)];
        selectedBottomSeparator.tag = 3;
        selectedBottomSeparator.backgroundColor = [UIColor colorWithRed:248/255.0 green:207/255.0 blue:63/255.0 alpha:1.0];
        [view addSubview:selectedBottomSeparator];

        messageCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(modifiedRect.size.width - 10, ceilf(modifiedRect.size.height / 2.0)-7.5, 24, 15)];
//        messageCountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        messageCountLabel.backgroundColor = HEXCOLOR(0xf85154ff);
        messageCountLabel.textColor = [UIColor whiteColor];
        messageCountLabel.font = [UIFont fontWithName:InterfaceStr(@"default_font_bold") size:12];
        messageCountLabel.text = [NSString stringWithFormat:@"%@",unreadMessageCounter<100?@(unreadMessageCounter).stringValue:@"99+"];
        messageCountLabel.textAlignment = NSTextAlignmentCenter;
        messageCountLabel.tag = 4;
        messageCountLabel.layer.cornerRadius = 2.0;
        messageCountLabel.layer.masksToBounds = YES;
        if (swipeView == headerMenu && index == 1) {
            [view addSubview:messageCountLabel];
            [messageCountLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [messageCountLabel sdc_pinHeight:15];
            [messageCountLabel sdc_pinWidth:24];
            [messageCountLabel sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:view inset:-10];
            [messageCountLabel sdc_verticallyCenterInSuperview];
        }
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
        bottomSeparator = [view viewWithTag:2];
        selectedBottomSeparator = [view viewWithTag:3];
        messageCountLabel = (UILabel *)[view viewWithTag:4];
        verticalSeparator = [view viewWithTag:5];
    }
    
    
    UIColor *textSelectedColor = [UIColor colorWithRed:217/255.0 green:180/255.0 blue:52/255.0 alpha:1.0];
    UIColor *textNormalColor = HEXCOLOR(0x8E8E93FF);
    
    //swipeview header
    if(swipeView == headerMenu){
        label.text =  [self.headerMenuTextArray[index] uppercaseString];
        label.textColor = index == self.currentChatType ? textSelectedColor : textNormalColor;
        
        if(index == self.currentChatType){
            bottomSeparator.hidden = YES;
            selectedBottomSeparator.hidden = NO;
            view.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
        }else{
            bottomSeparator.hidden = NO;
            selectedBottomSeparator.hidden = YES;
            view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        }
        messageCountLabel.hidden = unreadMessageCounter < 1;
        
    }else{
        
        //swipeview sticker
        StickerCategory *cat = self.stickerCategoryArray[index];
        label.text = [cat.name uppercaseString];

        if(index == self.stickerMenuSelectedIndex && !isBalanceViewShown){
            bottomSeparator.hidden = YES;
            selectedBottomSeparator.hidden = NO;
            view.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
            label.textColor = textSelectedColor;
        }else{
            bottomSeparator.hidden = NO;
            selectedBottomSeparator.hidden = YES;
            view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
            label.textColor = textNormalColor;
        }
    }
    
    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    if(swipeView == headerMenu){
        return CGSizeMake(ceilf(headerMenu.frame.size.width)/self.headerVisibleItems, headerMenu.frame.size.height);
    }else{
        
        CGFloat width = ceilf(stickerView.frame.size.width - balanceView.frame.size.width)/self.stickerVisibleItems;
        
        if(self.stickerCategoryArray.count > 2){
            width = ceilf(stickerView.frame.size.width - balanceView.frame.size.width - 30.0)/self.stickerVisibleItems;
        }
        return CGSizeMake(width, stickerMenu.frame.size.height);
    }
}

-(void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index{
    
    //Chat Header Menu
    if(swipeView == headerMenu){
        self.currentChatType = (int)index;
        
        NSLog(@"%@ %@", currentBroadcaster.broadon_user_id, CURRENT_USER_ID());
        NSString *broadcasterId = [NSString stringWithFormat:@"%@", currentBroadcaster.broadon_user_id];
        
        if(self.currentChatType == ChatTypeWhisper && [broadcasterId isEqualToString:CURRENT_USER_ID()]){
            [self handleBackgroundTouch:nil];
            forceLoginButton.hidden = NO;
        }else if(self.currentChatType == ChatTypePublic && CURRENT_USER_ID()){
            forceLoginButton.hidden = YES;
        }
        
        [self.headerMenu reloadData];
        //for now user can only whisper with broadcaster (host)
        if (self.currentChatType == ChatTypeWhisper) {
            self.unreadMessageCounter = 0;
        }
        [self reloadChatData];
        [self.chatPagingView setCurrentPageIndexAnimated:self.currentChatType];
        
        if([self.delegate respondsToSelector:@selector(DMChatViewDelegate:didSelectHorizontalMenuAtIndex:)]){
            [self.delegate DMChatViewDelegate:self didSelectHorizontalMenuAtIndex:index];
        }
    }else{
        
        CGFloat width = ceilf(stickerView.frame.size.width - balanceView.frame.size.width)/self.stickerVisibleItems;
        
        if(self.stickerCategoryArray.count > 2){
            width = ceilf(stickerView.frame.size.width - balanceView.frame.size.width - 30.0)/self.stickerVisibleItems;
        }
    
        if(index == 0 && isBalanceViewShown){
            [self.stickerMenu.scrollView scrollRectToVisible:CGRectMake(-1 * balanceView.frame.size.width, 0, self.stickerMenu.frame.size.width, self.stickerMenu.frame.size.height) animated:YES];
        }else{
            
            [self.stickerMenu.scrollView scrollRectToVisible:CGRectMake(width * index, 0, self.stickerMenu.frame.size.width, self.stickerMenu.frame.size.height) animated:YES];
        }
        
        //Sticker Menu
        isBalanceViewShown = NO;
        self.stickerCollectionView.hidden = isBalanceViewShown;
        self.balanceView.backgroundColor = HEXCOLOR(0x404040FF);
        self.stickerMenuSelectedIndex = (int)index;
        
        [self.stickerCollectionView reloadData];
        [self.stickerMenu reloadData];
    }
}

#pragma mark - UITableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Message *aMes = nil;
    if(self.currentChatType == ChatTypePublic && tableView == chatPublicTableView){
        aMes = [self.messageArray objectAtIndex:indexPath.row];
    }else if(self.currentChatType == ChatTypeWhisper && tableView == chatWhisperTableView){
        aMes = [self.whisperMessageArray objectAtIndex:indexPath.row];
    }

    if(aMes){
        if([aMes.messageType isEqualToString:MessageTypeSticker]){
            return 125.0;
        }else if([aMes.messageType isEqualToString:MessageTypeDisconnected]){
            return 70.0;
        }else{
            MeTableViewCell *cell = (MeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[MeTableViewCell reuseIdentifier]];

            [cell fillCellWithMessage:aMes];
            cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
            [cell setNeedsLayout];
            [cell layoutIfNeeded];
            return [cell cellHeight];
        }
    }
    return 1.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(tableView == chatPublicTableView){
        return self.messageArray.count;
    }else if(tableView == chatWhisperTableView){
        return self.whisperMessageArray.count;
    }

    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Message *aMes = nil;
    if(tableView == chatPublicTableView){
        aMes = [self.messageArray objectAtIndex:indexPath.row];
    }else if(tableView == chatWhisperTableView){
        aMes = [self.whisperMessageArray objectAtIndex:indexPath.row];
    }
    
    if([aMes.messageType isEqualToString:MessageTypeDisconnected]){
        StatusTextTableViewCell *cell = (StatusTextTableViewCell*)[tableView dequeueReusableCellWithIdentifier:[StatusTextTableViewCell reuseIdentifier]];
        [cell fillCellWithMessage:aMes];
        return cell;
    }
    
    if([aMes.messageUserId isEqualToString:CURRENT_USER_ID()] || [self.visitorId isEqualToString:aMes.messageUserId]){
        MeTableViewCell *cell = (MeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:[MeTableViewCell reuseIdentifier]];
        [cell fillCellWithMessage:aMes];
        return cell;
    }else{
        OtherTableViewCell *cell = (OtherTableViewCell*)[tableView dequeueReusableCellWithIdentifier:[OtherTableViewCell reuseIdentifier]];
        cell.delegate = self;
        [cell fillCellWithMessage:aMes];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(self.currentChatType == ChatTypeWhisper){
        UIView *whisperUserView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.chatPagingView.frame.size.width, 30)];
        whisperUserView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        UIView *bottomBorderView = [[UIView alloc] initWithFrame:CGRectMake(0, 29, self.chatPagingView.frame.size.width, 1)];
        bottomBorderView.backgroundColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0];
        [whisperUserView addSubview:bottomBorderView];
        [bottomBorderView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [bottomBorderView sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:whisperUserView];
        [bottomBorderView sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:whisperUserView];
        [bottomBorderView sdc_alignEdge:UIRectEdgeBottom withEdge:UIRectEdgeBottom ofView:whisperUserView];
        [bottomBorderView sdc_pinHeight:1.0];

        UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.chatPagingView.frame.size.width, 30)];
        userNameLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
        userNameLabel.font = [UIFont systemFontOfSize:13.0];
        userNameLabel.text = self.currentWhisperChatUser.user_name;
        [whisperUserView addSubview:userNameLabel];
        
        [userNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [userNameLabel sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:whisperUserView inset:20.0];
        [userNameLabel sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:whisperUserView inset:-40.0];
        [userNameLabel sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:whisperUserView];
        [userNameLabel sdc_pinHeight:30.0];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        arrowImageView.image = [UIImage imageNamed:@"leftArrow"];
        [arrowImageView setContentMode:UIViewContentModeScaleAspectFit];
        [whisperUserView addSubview:arrowImageView];
        [arrowImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [arrowImageView sdc_pinHeight: 11];
        [arrowImageView sdc_pinWidth:6];
        [arrowImageView sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:whisperUserView inset:-10];
        [arrowImageView sdc_verticallyCenterInSuperview];
        
        UIButton *whisperButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [whisperButton setTitle:@"" forState:UIControlStateNormal];
        whisperButton.backgroundColor = [UIColor clearColor];
        [whisperButton addTarget:self action:@selector(openWhisperListView) forControlEvents:UIControlEventTouchUpInside];
        [whisperUserView addSubview: whisperButton];
        [whisperButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [whisperButton sdc_alignEdges:UIRectEdgeAll withView:whisperUserView];
        
        return whisperUserView;

    }else{
        return nil;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)openWhisperListView{
    if([self.delegate respondsToSelector:@selector(DMChatViewDelegateOpenWhisperListView:)]){
        [self.delegate DMChatViewDelegateOpenWhisperListView:self];
    }
}

-(void)tableViewScrollToBottom{
 
    NSIndexPath *ipath = nil;
    
    if(self.currentChatType == ChatTypeWhisper){
        ipath = [NSIndexPath indexPathForRow:self.whisperMessageArray.count-1 inSection:0];
        [self.chatWhisperTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }else{
        ipath = [NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0];
        [self.chatPublicTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
    

}

#pragma mark - TopUp Button
-(void)balanceTapped{
    NSLog(@"balance tap:");
    isBalanceViewShown = YES;
    self.stickerCollectionView.hidden = isBalanceViewShown;
    
    balanceView.backgroundColor = HEXCOLOR(0xd5a611FF);
    [self.stickerCollectionView reloadData];
    [self.stickerMenu reloadData];
    
}

#pragma mark - ChatCell Delegate
-(void)OtherTableViewCell:(OtherTableViewCell *)cell didTapUserButton:(Message *)chat{
    if([self.delegate respondsToSelector:@selector(DMChatViewDelegate:didTapChatUser:)]){
//        [self.delegate DMChatViewDelegate:self didTapChatUser:chat];
    }
}

#pragma mark - ChatBox Action
-(void)stickerButtonTapped{
    
    emojiType = EmojiKeyboardTypeSticker;
    self.isStickerPresent = !self.isStickerPresent;
    self.stickerButton.selected = self.isStickerPresent;
    
    if(self.isStickerPresent){
        [self.chatTF resignFirstResponder];
    }else{
        [self.chatTF becomeFirstResponder];
    }
    
    self.chatBoxBottomConstraint.constant = -self.stickerBoxHeight;
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
    if([self.delegate respondsToSelector:@selector(DMChatViewDelegateKeyboardWillShow:)]){
        [self.delegate DMChatViewDelegateKeyboardWillShow:self];
    }
}


-(void)sendButtonTapped{

    if(![[chatTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] && webSocket.readyState == SR_OPEN)
    {
        NSMutableDictionary *dictParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"sendMessage", @"action",
                                   [NSString stringWithFormat:@"broadcaster_%@", currentBroadcaster.broadon_user_id], @"roomName",
                                   chatTF.text, @"message",
                                   nil];
        if(self.currentChatType == ChatTypeWhisper){
            dictParam[@"recipientId"] = self.currentBroadcaster.broadon_user_id;
        }
        NSDictionary *dictResult = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"action", @"event",
                                    dictParam, @"params",
                                    nil];
        
        [webSocket send:[self convertDictToJSON:dictResult]];

        chatTF.text = @"";
        [self textFieldChanged:self.chatTF];
    }
}

#pragma mark - ChatBox TF delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self sendButtonTapped];
    return YES;
}

- (void)textFieldChanged:(UITextField *)textField
{
    if (textField.text.length == 0) {
        [self.sendButton setTitleColor:HEXCOLOR(0x8E8E93FF) forState:UIControlStateNormal];
    }else{
        [self.sendButton setTitleColor:HEXCOLOR(0x1889e7FF) forState:UIControlStateNormal];
    }
}

#pragma mark - UIKeyboard observer
- (void)addKeyboardbserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
}
- (void)removeKeyboardbserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

#pragma mark - keyboard action

-(void)handleBackgroundTouch:(UIGestureRecognizer *)gesture{
    [chatTF resignFirstResponder];
    
    emojiType = EmojiKeyboardTypeSticker;
    self.isStickerPresent = NO;
    self.stickerButton.selected = isStickerPresent;
    self.chatBoxBottomConstraint.constant = 0;
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
    
    if([self.delegate respondsToSelector:@selector(DMChatViewDelegateKeyboardWillHide:)]){
        [self.delegate DMChatViewDelegateKeyboardWillHide:self];
    }
}

-(void)loginFirst{
    
    NSString *broadcasterId = [NSString stringWithFormat:@"%@", currentBroadcaster.broadon_user_id];
    if(![broadcasterId isEqualToString:CURRENT_USER_ID()]){
        if([self.delegate respondsToSelector:@selector(DMChatViewDelegateNeedToLogin:)]){
            [self.delegate DMChatViewDelegateNeedToLogin:self];
            stickerBoxHeight = 216.0;
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notification{

    self.isStickerPresent = NO;
    self.stickerButton.selected = self.isStickerPresent;
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    if (emojiType == EmojiKeyboardTypeInitiate && stickerBoxHeight == keyboardSize.height){
        
        emojiType = EmojiKeyboardTypeShown;
        
    }else if(emojiType == EmojiKeyboardTypeHide && keyboardSize.height < 253.0){
        
        emojiType = EmojiKeyboardTypeShown;
        
    }else if(emojiType == EmojiKeyboardTypeShown && !(IS_IPAD)){
        
        emojiType = EmojiKeyboardTypeHide;
        
        
    }else if(emojiType == EmojiKeyboardTypeSticker){
        
        emojiType = EmojiKeyboardTypeInitiate;
    }

//    self.chatPublicTableView.contentInset = UIEdgeInsetsZero;
//    self.chatPublicTableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    self.stickerBoxHeight = keyboardSize.height;
    self.chatBoxBottomConstraint.constant = -self.stickerBoxHeight;

    if(emojiType == EmojiKeyboardTypeShown && !(IS_IPAD)){
        self.chatBoxBottomConstraint.constant = -254.0;
    }else if(emojiType == EmojiKeyboardTypeHide && !(IS_IPAD)){
        self.chatBoxBottomConstraint.constant = -215.0;
    }

    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
    
    if([self.delegate respondsToSelector:@selector(DMChatViewDelegateKeyboardWillShow:)]){
        [self.delegate DMChatViewDelegateKeyboardWillShow:self];
    }

}

- (void)keyboardWillHide:(NSNotification *)notification{
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if([self.delegate respondsToSelector:@selector(DMChatViewDelegateKeyboardWillHide:)]){
        [self.delegate DMChatViewDelegateKeyboardWillHide:self];
    }
    
    self.chatPublicTableView.contentInset = UIEdgeInsetsZero;
    self.chatPublicTableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    if(!self.isStickerPresent){
        self.chatBoxBottomConstraint.constant = 0;
        [self setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.3 animations:^{
            [self layoutIfNeeded];
        }];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification{
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

}


- (void)keyboardDidHide:(NSNotification *)notification{
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification{
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

}

#pragma mark - global variable
-(NSString *)convertDictToJSON:(NSDictionary *)dict{

    // This will be the json string in the preferred format
    NSData *json = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:0
                                                     error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    
    // This is handshake
//    NSLog(@"%@",[NSString stringWithFormat:@"%@", jsonString]);
    
    return jsonString;

}

-(float)stickerBoxHeight{
    if (stickerBoxHeight > 0 && stickerBoxHeight < 226) {
        return stickerBoxHeight;
    }
    //default value
    if(IS_IPAD){
        return 264;
    }else{
        return 225;
    }
}

-(float)headerHeight{
    if (headerHeight > 0) {
        return headerHeight;
    }
    //default value
    return 35.0;

}

-(int)headerVisibleItems{
    if(headerVisibleItems > 0){
        return headerVisibleItems;
    }
    return 2;
}

-(float)chatBoxHeight{
    if(chatBoxHeight > 0){
        return chatBoxHeight;
    }
    return 45.0;
}

-(int)stickerVisibleItems{
    if(stickerVisibleItems > 0){
        return stickerVisibleItems;
    }
    return 2;
}

-(void)dealloc{
    [self removeKeyboardbserver];
}
@end
