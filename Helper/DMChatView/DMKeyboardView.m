//
//  DMKeyboardView.m
//  DMMoviePlayer
//
//  Created by Teguh Hidayatullah on 10/22/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "DMKeyboardView.h"
#import "UIView+SDCAutoLayout.h"
#import "NSString+Mutable.h"
#import "Sticker.h"
#import "TopUpView.h"
#import "Balance.h"

@interface DMKeyboardView()<UITextFieldDelegate, UIGestureRecognizerDelegate, TLTagsControlDelegate>

@property(nonatomic, retain) IBOutlet UICollectionView *stickerCollectionView;
@property(nonatomic, retain) CustomBoldLabel *remainingBalanceLabel;
@property(nonatomic, retain) SwipeView *stickerMenu;
@property(nonatomic, retain) UIView *stickerView;
@property(nonatomic, retain) UIView *balanceView;
@property(nonatomic, retain) UIButton *sendButton;
@property(nonatomic, retain) TopUpView *topUpView;
@property(nonatomic, assign) BOOL isBalanceViewShown;
@property(nonatomic, retain) UIView *chatBoxContainer;
@property(nonatomic, retain) NSAttributedString *tempAttributedString;
@property(nonatomic, retain) NSLayoutConstraint *chatTextViewHeightConstraint;
@property(nonatomic, retain) NSLayoutConstraint *chatBoxContainerHeightConstraint;
@end

@implementation DMKeyboardView
@synthesize chatBoxHeight, stickerBoxHeight, stickerView, stickerVisibleItems, stickerMenu, isStickerPresent, remainingBalanceLabel, sendButton;
@synthesize stickerButton, stickerCategoryArray;
@synthesize balanceView, topUpView;
@synthesize isBalanceViewShown, chatBoxContainer, forceLoginButton;
@synthesize webSocket, webSocketParameter, visitorId;
@synthesize chatTextView, tempAttributedString, chatTextViewHeightConstraint;
@synthesize chatBoxContainerHeightConstraint;

-(id)init{
    if (self = [super init]) {
        self.isBalanceViewShown = NO;
        self.isStickerPresent = NO;
        self.stickerMenuSelectedIndex = 0;
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

-(void)initializeView{

    //initialize sticker view
    self.stickerCategoryArray = [NSMutableArray arrayWithArray:[TheDatabaseManager getAllStickerCategorys]];
    
    [TheServerManager getAllStickersWithCompletion:^(NSArray *stickersArray) {
        self.stickerCategoryArray = [NSMutableArray arrayWithArray:[TheDatabaseManager getAllStickerCategorys]];
        [self.stickerCollectionView reloadData];
    } andFailure:nil];

    //chat box
    chatBoxContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.chatBoxHeight)];
    chatBoxContainer.backgroundColor = [UIColor colorWithRed:252/255.0 green:252/255.0 blue:252/255.0 alpha:1.0];
    [self addSubview:chatBoxContainer];
    [chatBoxContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
    [chatBoxContainer sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:self];
    [chatBoxContainer sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:self];
    [chatBoxContainer sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:self];
//    self.chatBoxBottomConstraint = [chatBoxContainer sdc_alignEdge:UIRectEdgeBottom withEdge:UIRectEdgeBottom ofView:self];
    self.chatBoxContainerHeightConstraint = [chatBoxContainer sdc_pinHeight:self.chatBoxHeight];
    
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
    [stickerButton sdc_alignEdge:UIRectEdgeBottom withEdge:UIRectEdgeBottom ofView:[stickerButton superview]];
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
    [sendButton sdc_alignEdge:UIRectEdgeBottom withEdge:UIRectEdgeBottom ofView:[sendButton superview]];
    [sendButton sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:[sendButton superview] inset:-8.0];
    
    //chatbox textfield
//    self.chatTF = [[UITextField alloc] initWithFrame:CGRectZero];
//    self.chatTF.delegate = self;
//    [chatBoxContainer addSubview:self.chatTF];
//    chatTF.borderStyle = UITextBorderStyleRoundedRect;
//    [chatTF setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [chatTF sdc_verticallyCenterInSuperview];
//    [chatTF sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeRight ofView:stickerButton inset:0.0];
//    [chatTF sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeLeft ofView:sendButton inset:-10.0];
//    [chatTF addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    
    //chatAnnotationTextView
    self.chatTextView = [[MintAnnotationChatView alloc] initWithFrame:CGRectZero]; //CGRectMake(45, 5, TheAppDelegate.deviceWidth-100 , 35)];
    self.chatTextView.delegate = self;
    chatTextView.layer.borderColor = [TheInterfaceManager.borderColor CGColor];
    chatTextView.font = [UIFont fontWithName:InterfaceStr(@"default_font_regular") size:15.0];
    chatTextView.layer.borderWidth = 1.0;
    chatTextView.layer.cornerRadius = 5;
    chatTextView.clipsToBounds = YES;
    chatTextView.nameTagImage = [[UIImage imageNamed:@"tagImage"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    chatTextView.nameTagColor = [UIColor blackColor];//[UIColor colorWithRed:0.00 green:0.54 blue:0.50 alpha:1.0];
    [chatBoxContainer addSubview:self.chatTextView];
    [chatTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [chatTextView sdc_alignEdge:UIRectEdgeBottom withEdge:UIRectEdgeBottom ofView:[chatTextView superview] inset:-5.0];
    [chatTextView sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeRight ofView:stickerButton inset:0.0];
    [chatTextView sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeLeft ofView:sendButton inset:-5.0];
    self.chatTextViewHeightConstraint = [chatTextView sdc_pinHeight:35];
    [chatTextView addConstraint:self.chatTextViewHeightConstraint];
    
//    [chatTextView addTarget:self action:@selector(textView:shouldChangeTextInRange:replacementText:) forControlEvents:UIControlEventEditingChanged];
    
    //chatTagBox TLTagsControl
//    self.chatTagTF = [[TLTagsControl alloc] initWithFrame:CGRectMake(45, 5, TheAppDelegate.deviceWidth-95 , 35) andTags:@[] withTagsControlMode:TLTagsControlModeEdit];
//    self.chatTagTF.tagsBackgroundColor = [UIColor clearColor];
//    self.chatTagTF.tagsTextColor = [UIColor blackColor];
//    self.chatTagTF.tagsDeleteButtonColor = [UIColor blackColor];
//    self.chatTagTF.tagPlaceholder = @"";
//    chatTagTF.layer.borderColor = [TheInterfaceManager.borderColor CGColor];
//    chatTagTF.layer.borderWidth = 1.0f;
//    [chatTagTF reloadTagSubviews];
//    [chatTagTF setTapDelegate:self];
//    [chatBoxContainer addSubview:self.chatTagTF];
    
    //button to force login
    forceLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [forceLoginButton addTarget:self action:@selector(loginFirst) forControlEvents:UIControlEventTouchUpInside];
    forceLoginButton.frame = chatBoxContainer.bounds;
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
    self.stickerMenu = [[SwipeView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 34.0)];
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
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 0, 10);
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
}

#pragma mark - SRWebSocket Delegate
- (void)disconnectWebSocket{
    [webSocket close];
    webSocket.delegate = nil;
    webSocket = nil;
}

- (void)connectWebSocket{
    
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
}

- (void)webSocket:(SRWebSocket *)wbSocket didFailWithError:(NSError *)error {
    [self connectWebSocket];
}

- (void)webSocket:(SRWebSocket *)wbSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    self.webSocketParameter[@"params"][@"initial_join"] = @(0);
    
    [self connectWebSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)jsonString {
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSString *eventType = json[@"message"][@"event"];
    Balance *currentBalance = nil;
    
    if([eventType isEqualToString:@"userBalance"]){
        //data balance
        currentBalance = [[Balance alloc] initWithDictionary:json[@"message"][@"data"]];
    }
    
    if(currentBalance){
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
    cell.contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];//HEXCOLOR(0xf0f9f9FF);
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
        if([self.delegate respondsToSelector:@selector(DMKeyboardViewDelegateNeedToLogin:)]){
            [self.delegate DMKeyboardViewDelegateNeedToLogin:self];
        }
    }else{
        
        if([self.delegate respondsToSelector:@selector(DMKeyboardViewDelegateSendComment:WithStickerId:)]){
            
            [self stickerButtonTapped];
            [self.chatTextView resignFirstResponder];
            
            StickerCategory *cat = self.stickerCategoryArray[self.stickerMenuSelectedIndex];
            Sticker *stick = [cat.stickerArray objectAtIndex:indexPath.row];
            [self.delegate DMKeyboardViewDelegateSendComment:self WithStickerId:[NSString stringWithFormat:@"%d",stick.stickerId]];
        }
    }
}

#pragma mark -
#pragma mark SwipeheaderMenu methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    //return the total number of items in the carousel
    return self.stickerCategoryArray.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *textLabel = nil;
    UIView *bottomSeparator = nil;
    UIView *selectedBottomSeparator = nil;
    UIView *verticalSeparator = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        CGRect modifiedRect = CGRectZero;
        CGFloat width = ceilf(stickerView.frame.size.width - balanceView.frame.size.width)/self.stickerVisibleItems;
        
        if(self.stickerCategoryArray.count > 2){
            width = ceilf(stickerView.frame.size.width - balanceView.frame.size.width - 30.0)/self.stickerVisibleItems;
        }
        modifiedRect.size.width = width;
        modifiedRect.size.height = stickerView.frame.size.height;
        
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, modifiedRect.size.width, modifiedRect.size.height)];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.backgroundColor = [UIColor clearColor];
        textLabel = [[UILabel alloc] initWithFrame:view.bounds];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        
        textLabel.tag = 1;
        [view addSubview:textLabel];
        
        CGRect bottomRect = CGRectZero;
        bottomRect.origin.y = CGRectGetHeight(stickerMenu.frame);
        
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
    }
    else
    {
        //get a reference to the label in the recycled view
        textLabel = (UILabel *)[view viewWithTag:1];
        bottomSeparator = [view viewWithTag:2];
        selectedBottomSeparator = [view viewWithTag:3];
        verticalSeparator = [view viewWithTag:5];
    }
    
    
    UIColor *textSelectedColor = [UIColor colorWithRed:217/255.0 green:180/255.0 blue:52/255.0 alpha:1.0];
    UIColor *textNormalColor = HEXCOLOR(0x8E8E93FF);
    //swipeview sticker
    StickerCategory *cat = self.stickerCategoryArray[index];
    textLabel.text = [cat.name uppercaseString];

    if(index == self.stickerMenuSelectedIndex && !isBalanceViewShown){
        bottomSeparator.hidden = YES;
        selectedBottomSeparator.hidden = NO;
        view.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
        textLabel.textColor = textSelectedColor;
    }else{
        bottomSeparator.hidden = NO;
        selectedBottomSeparator.hidden = YES;
        view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        textLabel.textColor = textNormalColor;
    }
    
    
    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    CGFloat width = ceilf(stickerView.frame.size.width - balanceView.frame.size.width)/self.stickerVisibleItems;
    
    if(self.stickerCategoryArray.count > 2){
        width = ceilf(stickerView.frame.size.width - balanceView.frame.size.width - 30.0)/self.stickerVisibleItems;
    }
    return CGSizeMake(width, stickerMenu.frame.size.height);
}

-(void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index{

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

#pragma mark - TopUp Button
-(void)balanceTapped{
    NSLog(@"balance tap:");
    isBalanceViewShown = YES;
    self.stickerCollectionView.hidden = isBalanceViewShown;
    
    balanceView.backgroundColor = HEXCOLOR(0xd5a611FF);
    [self.stickerCollectionView reloadData];
    [self.stickerMenu reloadData];
    
}

#pragma mark - ChatBox Action
-(void)stickerButtonTapped{
    
    self.isStickerPresent = !self.isStickerPresent;
    self.stickerButton.selected = self.isStickerPresent;
    
    if(self.isStickerPresent){
        [self.chatTextView resignFirstResponder];
    }else{
        [self.chatTextView becomeFirstResponder];
    }

    if([self.delegate respondsToSelector:@selector(DMKeyboardViewDelegateStickerTapped:)]){
        [self.delegate DMKeyboardViewDelegateStickerTapped:self];
    }
}

-(void)sendButtonTapped{
   
    chatBoxContainerHeightConstraint.constant = 45.0;
    chatTextViewHeightConstraint.constant = 35.0;
    [self.chatTextView resignFirstResponder];
    
    if([self.delegate respondsToSelector:@selector(DMKeyboardViewDelegateSendComment:WithContent:andTaggedUser:)]){
        NSMutableArray *userIdArray = [NSMutableArray array];
        
        for(MintAnnotation *annot in chatTextView.annotationList){
            [userIdArray addObject:annot.usr_id];
        }
        
        [self.delegate DMKeyboardViewDelegateSendComment:self WithContent:self.chatTextView.text andTaggedUser:userIdArray];
        
        [self.chatTextView clearAll];
        tempAttributedString = nil;
    }
    
    [self dismissAutoCompleteTableView];
    [self writeLogTaggedUser];
    
    /*
    [self.chatTagTF.tagInputField_ resignFirstResponder];
    
    NSString *contentText = @"";

    for(NSString *tagString in self.chatTagTF.tags){
        contentText = [contentText stringByAppendingString:[NSString stringWithFormat:@"%@ ",tagString]];
    }
    contentText = [contentText stringByAppendingString:self.chatTagTF.tagInputField_.text];
    
    if([self.delegate respondsToSelector:@selector(DMKeyboardViewDelegateSendComment:WithContent:andTaggedUser:)]){
        [self.delegate DMKeyboardViewDelegateSendComment:self WithContent:contentText andTaggedUser:[NSArray arrayWithArray:taggedUserArray]];
        
        [self.taggedUserArray removeAllObjects];
        [self.chatTagTF.tags removeAllObjects];
        [self.chatTagTF reloadTagSubviews];
        self.chatTagTF.tagInputField_.text = @"";
    }
    
    [self dismissAutoCompleteTableView];
    [self writeLogTaggedUser];
     */
}

-(void)loginFirst{

    if(![User fetchLoginUser]){
        if([self.delegate respondsToSelector:@selector(DMKeyboardViewDelegateNeedToLogin:)]){
            [self.delegate DMKeyboardViewDelegateNeedToLogin:self];
            stickerBoxHeight = 216.0;
        }
    }
}

#pragma mark - MintAnnotation Delegate
-(void)writeLogTaggedUser{
    for(MintAnnotation *annot in self.chatTextView.annotationList){
        NSLog(@"Tagged User : %@", annot.usr_name);
    }
}

- (void)addTagWithUser:(User *)user{
    
    self.chatTextView.text = @"";
    NSLog(@"fancy text : %@", tempAttributedString.string);
    [self.chatTextView setAttributedText:tempAttributedString];
    
    NSString *username = user.user_username;
    NSArray *usernameSeparated = [username componentsSeparatedByString:@"@"];
    MintAnnotation *newAnnoation = [[MintAnnotation alloc] init];
    newAnnoation.usr_id = user.user_id;
    newAnnoation.usr_name = usernameSeparated.count > 0 ? usernameSeparated[0]:user.user_username;
    [self.chatTextView addAnnotation:newAnnoation];

    [self dismissAutoCompleteTableView];
    [self writeLogTaggedUser];
    
    /*
    NSString *thisStr = chatTagTF.tagInputField_.text;
    
    thisStr = [@"@" stringByAppendingString:[thisStr stringAfterString:@"@" inString:thisStr]];
    self.chatTagTF.tagInputField_.text = [self.chatTagTF.tagInputField_.text stringByReplacingOccurrencesOfString:thisStr withString:@""];
    
    [self dismissAutoCompleteTableView];
    
    for (NSString *oldTag in chatTagTF.tags) {
        if ([oldTag isEqualToString:user.user_name]) {
            return;
        }
    }
    
    [self.chatTagTF addTag:user.user_name];
    [self.taggedUserArray addObject:user.user_id];
    
    [self writeLogTaggedUser];
     */
}

-(void)dismissAutoCompleteTableView{
    if([self.delegate respondsToSelector:@selector(DMKeyboardViewDelegateAutoComplete:withArray:)]){
        [self.delegate DMKeyboardViewDelegateAutoComplete:self withArray:[NSArray new]];
    }
}

/*
 
- (void)tagsControl:(TLTagsControl *)tagsControl tappedAtIndex:(NSInteger)index{
    [self writeLogTaggedUser];
}

- (void)tagsControl:(TLTagsControl *)tagsControl inputFieldChange:(UITextField *)textField{
    if (textField.text.length == 0) {
        [self.sendButton setTitleColor:HEXCOLOR(0x8E8E93FF) forState:UIControlStateNormal];
    }else{
        [self.sendButton setTitleColor:HEXCOLOR(0x1889e7FF) forState:UIControlStateNormal];
    }
    
    NSString *thisStr = textField.text;
    if ([thisStr rangeOfString:@"@"].location != NSNotFound && _canTagging) {
        NSString *queryStr = [thisStr stringAfterString:@"@" inString:thisStr];
        NSLog(@"query str : %@",queryStr);
        if(queryStr.length > 2){
            [User searchUserAutoCompleteWithQuery:queryStr withAccesToken:ACCESS_TOKEN() andPageNumber:@(0) success:^(RKObjectRequestOperation * _Nonnull operation, NSArray * _Nonnull objectArray) {
                
                if([self.delegate respondsToSelector:@selector(DMKeyboardViewDelegateAutoComplete:withArray:)]){
                    [self.delegate DMKeyboardViewDelegateAutoComplete:self withArray:objectArray];
                }
                
            } failure:^(RKObjectRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
//                    [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                }
            }];
        }
    }else{
        [self dismissAutoCompleteTableView];
    }
}

-(void)tagsControl:(TLTagsControl *)tagsControl sendMsg:(UITextField *)tf{
    [self sendButtonTapped];
}
*/

#pragma mark - UITextViewDelegate (Required)

- (void)textViewDidChange:(UITextView *)textView
{
    // Checking User trying to remove MintAnnotationView's annoatation
    [self.chatTextView textViewDidChange:textView];
    
    CGFloat fixedWidth = TheAppDelegate.deviceWidth-100;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    
    if(newSize.height <= 35.0){
        newSize.height = 35.0;
    }else if(newSize.height > 110.0) {
        newSize.height = 110.0;
    }
    
    chatTextViewHeightConstraint.constant = newSize.height;
    NSLog(@"chat height : %f\nchat text : %@", chatTextViewHeightConstraint.constant, chatTextView.text);
    chatBoxContainerHeightConstraint.constant = newSize.height + 10;
    
    
    [self.delegate DMKeyboardViewDelegateResizeTextBox:self withHeight:newSize.height + 10];
}

-(void)textViewDidEndEditing:(UITextView *)textView{
   [self.sendButton setTitleColor:HEXCOLOR(0x8E8E93FF) forState:UIControlStateNormal];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // Checking User trying to edit MintAnnotationView's annoatation
    if(textView.text.length > 0){
        [self.sendButton setTitleColor:HEXCOLOR(0x1889e7FF) forState:UIControlStateNormal];
    }else{
        [self.sendButton setTitleColor:HEXCOLOR(0x8E8E93FF) forState:UIControlStateNormal];
    }
    
    if([text isEqualToString:@"@"]){
        tempAttributedString = chatTextView.attributedText;
    }
    
    /*
    NSArray *atStringArray = [thisStr componentsSeparatedByString:@"@"];
    if(atStringArray.count > 1 && _canTagging){
        NSString *queryStr2 = atStringArray[atStringArray.count-1];
        NSLog(@"Sub str 2 : %@", queryStr2);
        
        if(queryStr2.length > 3){
            [User searchUserAutoCompleteWithQuery:queryStr2 withAccesToken:ACCESS_TOKEN() andPageNumber:@(0) success:^(RKObjectRequestOperation * _Nonnull operation, NSArray * _Nonnull objectArray) {
                
                if([self.delegate respondsToSelector:@selector(DMKeyboardViewDelegateAutoComplete:withArray:)]){
                    [self.delegate DMKeyboardViewDelegateAutoComplete:self withArray:objectArray];
                }
                
            } failure:^(RKObjectRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    //                    [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                }
            }];
        }
        
    }else{
        [self dismissAutoCompleteTableView];
    }
     */
    
    NSString *thisStr = textView.text;
    if ([thisStr rangeOfString:@"@"].location != NSNotFound && _canTagging) {
        
        NSString *queryStr = [thisStr stringAfterString:@"@" inString:thisStr];
        NSLog(@"Sub str : %@",queryStr);
        if(queryStr.length > 3){
            [User searchUserAutoCompleteWithQuery:queryStr withAccesToken:ACCESS_TOKEN() andPageNumber:@(0) success:^(RKObjectRequestOperation * _Nonnull operation, NSArray * _Nonnull objectArray) {
                
                if([self.delegate respondsToSelector:@selector(DMKeyboardViewDelegateAutoComplete:withArray:)]){
                    [self.delegate DMKeyboardViewDelegateAutoComplete:self withArray:objectArray];
                }
                
            } failure:^(RKObjectRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    //                    [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                }
            }];
        }
    }else{
        [self dismissAutoCompleteTableView];
    }
    
    return [self.chatTextView shouldChangeTextInRange:range replacementText:text];
}

#pragma mark - global variable
-(NSString *)convertDictToJSON:(NSDictionary *)dict{

    // This will be the json string in the preferred format
    NSData *json = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:0
                                                     error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];

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

@end
