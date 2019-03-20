//
// Created by 何 义 on 14-4-1.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBBubbleMessageCell.h"
#import "EBStyle.h"
#import "EBViewFactory.h"
#import "EBBubbleView.h"
#import "EBContentBaseView.h"
#import "EBController.h"
#import "EBContact.h"
#import "EBPreferences.h"
#import "EBViewFactory.h"
#import "EBHouse.h"
#import "EBWebViewController.h"

static const CGFloat kEBLabelPadding = 5.0f;
static const CGFloat kEBCellMarginTop = 10.0f;
static const CGFloat kEBTimeStampLabelHeight = 12.0f;
static const CGFloat kEBTimestampLabelMarginBottom = 10.0f;
static const CGFloat kEBCellMarginBottom = 10.0f;
static const CGFloat kEBSubtitleLabelHeight = 15.0f;
static const CGFloat kEBAvatarImageSize = 30.0f;
static const CGFloat kEBAvatarImageLeftMargin = 10.0f;

@implementation EBBubbleMessageCell

#pragma mark - Setup

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;

    self.imageView.image = nil;
    self.imageView.hidden = YES;
    self.textLabel.text = nil;
    self.textLabel.hidden = YES;
    self.detailTextLabel.text = nil;
    self.detailTextLabel.hidden = YES;
}

- (void)configureTimestampLabel
{
    UILabel *label = [EBViewFactory timestampLabel];

    [self.contentView addSubview:label];
    [self.contentView bringSubviewToFront:label];
    _timestampLabel = label;
}

- (void)configureAvatarImageView:(UIImageView *)imageView forMessageType:(JSBubbleMessageType)type
{
    CGFloat avatarX = kEBAvatarImageLeftMargin;
    if (type == JSBubbleMessageTypeOutgoing)
    {
        avatarX = ([EBStyle screenWidth] - kEBAvatarImageSize - kEBAvatarImageLeftMargin);
    }

    CGFloat avatarY = kEBCellMarginTop;
    if (_timestampLabel)
    {
        avatarY += _timestampLabel.frame.size.height + kEBTimestampLabelMarginBottom;
    }

    imageView.frame = CGRectMake(avatarX, avatarY, kEBAvatarImageSize, kEBAvatarImageSize);
//    imageView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin
//            | UIViewAutoresizingFlexibleLeftMargin
//            | UIViewAutoresizingFlexibleRightMargin);

    [self.contentView addSubview:imageView];
    _avatarImageView = imageView;

    _avatarImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarClicked)];
    [_avatarImageView addGestureRecognizer:tapGestureRecognizer];
}

- (void)avatarClicked
{
   if (!_message.sender.special && ![_message.sender.userId isEqualToString:[EBPreferences sharedInstance].userId])
   {
       NSRange range = [_message.sender.userId rangeOfString:@"@"];
       if (range.location == NSNotFound) {
           [[EBController sharedInstance] showProfile:_message.sender];
       }
   }
}

- (void)configureNameLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [EBStyle blackTextColor];
    label.font = [UIFont systemFontOfSize:12.f];

    [self.contentView addSubview:label];
    _nameLabel = label;
}

- (void)configureWithType:(JSBubbleMessageType)type
          bubbleImageView:(UIImageView *)bubbleImageView
                  message:(EBIMMessage *)message
        displaysTimestamp:(BOOL)displaysTimestamp
{
    CGFloat bubbleY = kEBCellMarginTop;
    if (displaysTimestamp)
    {
        [self configureTimestampLabel];
        bubbleY += _timestampLabel.frame.size.height + kEBTimestampLabelMarginBottom;
    }

    [self configureAvatarImageView:[EBViewFactory avatarImageView:kEBAvatarImageSize] forMessageType:type];

    CGFloat offsetX = 0.0f;
    CGFloat bubbleX = kEBAvatarImageSize + kEBAvatarImageLeftMargin + 5.0;
    if (type == JSBubbleMessageTypeOutgoing)
    {
        offsetX = kEBAvatarImageLeftMargin + kEBAvatarImageSize + 5.0f;
    }

    if (message.conversationType == EConversationTypeGroup && message.isIncoming)
    {
        [self configureNameLabel];

        _nameLabel.frame = CGRectMake(bubbleX, bubbleY, 190, 12);
        bubbleY += _nameLabel.frame.size.height + 5;
    }

    CGRect frame = CGRectMake(bubbleX - offsetX,
            bubbleY,
            [EBStyle screenWidth] - bubbleX,
            message.bubbleSize.height);

    EBBubbleView *bubbleView = [[EBBubbleView alloc] initWithFrame:frame
                                                        bubbleType:type
                                                   bubbleImageView:bubbleImageView];

//    [EBDebug showFrame:self.contentView withColor:[UIColor blueColor]];
//    [EBDebug showFrame:bubbleView withColor:[UIColor yellowColor]];

    [self.contentView addSubview:bubbleView];
    [self.contentView sendSubviewToBack:bubbleView];
    _bubbleView = bubbleView;
    
    bubbleY += bubbleView.height + 5;
    NSString *extra = message.content[@"extra"];
    if (extra && extra.length > 0) {
        CGSize actualSize = [EBViewFactory textSize:extra font:[UIFont systemFontOfSize:12.0] bounding:CGSizeMake([EBStyle screenWidth] - 20, 28)];
        actualSize = CGSizeMake(actualSize.width + 20, actualSize.height);
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake([EBStyle screenWidth]/2-actualSize.width/2, bubbleY, actualSize.width, actualSize.height + 13)];
        view.backgroundColor = [UIColor colorWithRed:0xb7/255.0 green:0xb7/255.0 blue:0xb8/255.0 alpha:1.0];
        view.layer.cornerRadius = 2;
        view.layer.masksToBounds = YES;
        [self.contentView addSubview:view];
        _extraView = view;
        
        //        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, view.frame.size.height/2-7, actualSize.width, 14)];
        //        btn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        //        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        //        [btn setTitleColor:[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.0] forState:UIControlStateNormal];
        //        [btn setTitleColor:[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.4] forState:UIControlStateHighlighted];
        //        [btn addTarget:self action:@selector(extraAction) forControlEvents:UIControlEventTouchUpInside];
        
        RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectMake(0, view.frame.size.height/2-7, actualSize.width, 14)];
        label.text = [NSString stringWithFormat:@"<u><a href='http://'>%@</a></u>",extra];
        label.linkAttributes = @{@"color":@"#ffffff"};
        label.selectedLinkAttributes = @{@"color":@"#ffffff44"};
        label.font = [UIFont systemFontOfSize:12.0];
        label.delegate = self;
        label.textAlignment = RTTextAlignmentCenter;
        
        [view addSubview:label];
        _extraLabel = label;
        bubbleY += view.height + 5;
    }
    
    if (message.sourcePlatType == EMessageSourceTypeFang) {
        CGSize textSize = [EBViewFactory textSize:NSLocalizedString(@"message_from_fangshixiong", nil) font:[UIFont systemFontOfSize:12.0] bounding:CGSizeMake([EBStyle screenWidth] - _bubbleView.left, 20)];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(_bubbleView.left, bubbleY, textSize.width, 20)];
        btn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn setTitleColor:[EBStyle grayTextColor] forState:UIControlStateNormal];
        [btn setTitleColor:[EBStyle grayClickLineColor] forState:UIControlStateHighlighted];
        btn.titleLabel.text = NSLocalizedString(@"message_from_fangshixiong", nil);
        [btn setTitle:NSLocalizedString(@"message_from_fangshixiong", nil) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(sourceAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btn];
        _sourceBtn = btn;
    }
}

#pragma mark - action
- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL*)url
{
    NSString *houseId = _message.content[@"extra_hid"];
    if (houseId && houseId.length > 0) {
        EBHouse *house = [[EBHouse alloc] init];
        house.id = houseId;
        house.rentalState = EHouseRentalTypeSale;
        [[EBController sharedInstance] showHouseDetail:house];
    }
//    NSString *uid = [NSString stringWithFormat:@"%@",_message.content[@"extra_uid"]];
//    self.block(uid);
}

- (void)sourceAction
{
    EBWebViewController *webViewController = [[EBWebViewController alloc] init];
    webViewController.hidesBottomBarWhenPushed = YES;
    webViewController.request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:@"http://meiliwu.com"]];
    
    [[[EBController sharedInstance] currentNavigationController] pushViewController:webViewController animated:YES];
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithBubbleType:(JSBubbleMessageType)type
                   bubbleImageView:(UIImageView *)bubbleImageView
                           message:(EBIMMessage *)message
                   reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self configureWithType:type
                bubbleImageView:bubbleImageView
                        message:message
              displaysTimestamp:message.displayTimestamp];
    }
    return self;
}

- (void)dealloc
{
    _bubbleView = nil;
    _timestampLabel = nil;
    _avatarImageView = nil;
    _nameLabel = nil;
    _extraLabel = nil;
    _sourceBtn = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - TableViewCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.timestampLabel.text = nil;
    self.nameLabel.text = nil;
}

- (void)setBackgroundColor:(UIColor *)color
{
    [super setBackgroundColor:color];
    [self.contentView setBackgroundColor:color];
    [self.bubbleView setBackgroundColor:color];
}

- (void)setCellSendingStatus
{
    _bubbleView.failureButton.hidden = YES;
    _bubbleView.processingView.hidden = NO;
    [_bubbleView.processingView startAnimating];
}

#pragma mark - Setters

- (void)setMessage:(EBIMMessage *)message
{
    _message = message;
    CGRect frame = _bubbleView.frame;
    frame.size.height = message.bubbleSize.height;
//    frame.size.width = message.bubbleSize.width;
    _bubbleView.frame = frame;
    self.bubbleView.message = message;
}

#pragma mark - Getters

- (JSBubbleMessageType)messageType
{
    return _bubbleView.type;
}

#pragma mark - Class methods

+ (CGFloat)neededHeightForBubbleMessageCellWithMessage:(EBIMMessage *)message
{
    message.bubbleSize = [EBBubbleView bubbleSize:message];
    message.contentHeight = [self contentHeightForMessage:message];

    return message.contentHeight;
}

+ (CGFloat)contentHeightForMessage:(EBIMMessage *)message
{
    CGFloat nameLabelHeight = 0.0f;
    if (message.conversationType == EConversationTypeGroup
            && message.type != EMessageContentTypeHint
            && message.isIncoming)
    {
        nameLabelHeight = 17;
    }
    CGFloat extraHeight = 0.0f;
    NSString *extraStr = message.content[@"extra"];
    if (extraStr && extraStr.length > 0) {
        CGSize actualSize = [EBViewFactory textSize:message.content[@"extra"] font:[UIFont systemFontOfSize:12.0] bounding:CGSizeMake([EBStyle screenWidth] - 20, 28)];
        extraHeight = actualSize.height + 13 + 5;
    }
    CGFloat sourceBtnHeight = 0.0f;
    if (message.sourcePlatType == EMessageSourceTypeFang) {
        sourceBtnHeight = 20;
    }

    return message.bubbleSize.height + kEBCellMarginBottom + kEBCellMarginTop + nameLabelHeight + extraHeight + sourceBtnHeight;
}

#pragma mark - Layout

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//
//    if (self.nameLabel) {
//        self.nameLabel.frame = CGRectMake(kEBLabelPadding,
//                self.contentView.frame.size.height - kEBSubtitleLabelHeight,
//                [EBStyle screenWidth] - (kEBLabelPadding * 2.0f),
//                kEBSubtitleLabelHeight);
//    }
//}
@end