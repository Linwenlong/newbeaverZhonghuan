//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSMessagesViewController
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//  http://opensource.org/licenses/MIT
//

#import "EBBubbleView.h"

#import "EBIMMessage.h"
#import "EBContentTextView.h"
#import "EBContentImageView.h"
#import "EBContentAudioView.h"
#import "EBContentHouseView.h"
#import "EBContentClientView.h"
#import "EBContentBaseView.h"
#import "UIImage+Alpha.h"
#import "EBIMManager.h"
#import "UIAlertView+Blocks.h"
#import "UIActionSheet+Blocks.h"
#import "EBController.h"
#import "MainTabViewController.h"
#import "EBContentLocationShareView.h"
#import "EBContentLocationReportView.h"

#define kEBBubbleMarginTop 0.0f
#define kEBBubblePaddingTop 10.0f
#define kEBBubblePaddingBottom 10.0f
#define kEBBubblePaddingRight 10.0f
#define kEBBubblePaddingLeft 10.0f
#define kEBBubbleCornerWidth 8.0f

@interface EBBubbleView()
{
    UILongPressGestureRecognizer *_longPressGestureRecognizer;
    UITapGestureRecognizer *_tapGestureRecognizer;
}

@end

@implementation EBBubbleView

#pragma mark - Setup

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
//    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
                   bubbleType:(JSBubbleMessageType)bubleType
              bubbleImageView:(UIImageView *)bubbleImageView
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];

        _type = bubleType;
        
        bubbleImageView.userInteractionEnabled = YES;
        [self addSubview:bubbleImageView];
        _bubbleImageView = bubbleImageView;

        [self setupGestureRecognizer];
    }
    return self;
}

- (void)dealloc
{
    _bubbleImageView = nil;
}

#pragma mark - Getters

- (CGRect)bubbleFrame
{
    CGSize bubbleSize = _message.bubbleSize;
    return CGRectIntegral(CGRectMake((self.type == JSBubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width: 0.0f),
                                     kEBBubbleMarginTop,
                                     bubbleSize.width,
                                     bubbleSize.height + kEBBubbleMarginTop));
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bubbleFrame = [self bubbleFrame];
    self.bubbleImageView.frame = bubbleFrame;
    CGFloat textX;

    if (self.message.isIncoming)
    {
        textX = kEBBubblePaddingLeft +kEBBubbleCornerWidth;
    }
    else
    {
        textX = self.frame.size.width - bubbleFrame.size.width + kEBBubblePaddingLeft;

        if (_failureButton)
        {
            _failureButton.frame = CGRectOffset(_failureButton.bounds, bubbleFrame.origin.x - _failureButton.bounds.size.width + 5,
                    (self.bounds.size.height - _failureButton.bounds.size.height) / 2);
        }

        if (_processingView)
        {
            _processingView.frame = CGRectOffset(_processingView.bounds, bubbleFrame.origin.x - _processingView.bounds.size.width - 10,
                    (self.bounds.size.height - _processingView.bounds.size.height) / 2);
        }
    }

    if (_contentView)
    {
        CGRect contentFrame = CGRectMake(textX,
                bubbleFrame.origin.y + kEBBubblePaddingTop,
                bubbleFrame.size.width - kEBBubblePaddingLeft - kEBBubblePaddingRight - kEBBubbleCornerWidth,
                bubbleFrame.size.height - kEBBubblePaddingTop - kEBBubblePaddingBottom);

        _contentView.frame = CGRectIntegral(contentFrame);
    }
}

- (void)setMessage:(EBIMMessage *)message
{
    _message = message;
    if (!_contentView)
    {
        _contentView = [EBBubbleView contentViewForMessage:message];
        [self addSubview:_contentView];
    }
    [_contentView updateContent:message];

    if (!message.isIncoming)
    {
        [self updateDisplayByStatus];
    }

    [self setNeedsLayout];
}

- (void)handleTapEvent:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (_contentView)
    {
        CGPoint pt = [tapGestureRecognizer locationInView:self.bubbleImageView];
        CGRect bFrame = self.bubbleImageView.bounds;

        if (CGRectContainsPoint(bFrame, pt))
        {
            [_contentView handleTapEvent];
        }
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state != UIGestureRecognizerStateBegan
            || ![self becomeFirstResponder]
            || _message.type != EMessageContentTypeText)
    {
        return;
    }

    UIMenuController *menu = [UIMenuController sharedMenuController];
    CGRect targetRect = [self convertRect:self.bubbleFrame fromView:self];

    [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];

    self.bubbleImageView.highlighted = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillShowNotification:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
    [menu setMenuVisible:YES animated:YES];
}

- (void)setupGestureRecognizer
{
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapEvent:)];
    _tapGestureRecognizer.cancelsTouchesInView = NO;
//    _longPressGestureRecognizer.cancelsTouchesInView = NO;
    [_longPressGestureRecognizer setMinimumPressDuration:0.5f];

    [self addGestureRecognizer:_longPressGestureRecognizer];
    [self addGestureRecognizer:_tapGestureRecognizer];
}

#pragma mark - Notifications

- (void)handleMenuWillHideNotification:(NSNotification *)notification
{
    self.bubbleImageView.highlighted = NO;

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillHideMenuNotification
                                                  object:nil];
}

- (void)handleMenuWillShowNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillHideNotification:)
                                                 name:UIMenuControllerWillHideMenuNotification
                                               object:nil];
}

#pragma mark - GestureRecognizer

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _longPressGestureRecognizer || gestureRecognizer == _tapGestureRecognizer)
    {
        CGPoint pt = [gestureRecognizer locationInView:self];
//    CGPoint bubblePt = [self.bubbleImageView convertPoint:pt toView:self.bubbleImageView];
        return CGRectContainsPoint(self.bubbleFrame, pt);
    }
    else
    {
        return YES;
    }
}

#pragma mark - Copying

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:[self.contentView toPasteboard]];
    [self resignFirstResponder];
}


#pragma mark - Bubble view

+ (CGSize)bubbleSize:(EBIMMessage *)message
{
    CGSize contentSize = [EBBubbleView contentSizeForMessage:message];

//    textSize.height = MAX(textSize.height, 40.0);
    
	return [self bubbleSizeWithContentSize:contentSize];
}

+ (CGSize)bubbleSizeWithContentSize:(CGSize)contentSize
{
    return CGSizeMake(contentSize.width + kEBBubblePaddingRight + kEBBubblePaddingLeft + kEBBubbleCornerWidth,
            contentSize.height + kEBBubblePaddingTop + kEBBubblePaddingBottom);
}

+ (EBContentBaseView *)contentViewForMessage:(EBIMMessage *)message
{
    Class cls = [self viewClassFromContentType:message.type];

    return [[cls alloc] init];
}

- (void)updateDisplayByStatus
{
    EMessageStatus status = self.message.status;
    if (status == EMessageStatusUploading || status == EMessageStatusGenerating
            || status == EMessageStatusSending)
    {
        self.processingView.hidden = NO;
        [self.processingView startAnimating];
        if (_failureButton)
        {
            _failureButton.hidden = YES;
        }
    }
    else if (status == EMessageStatusSendError || status == EMessageStatusUploadingError)
    {
        self.failureButton.hidden = NO;
        if (_processingView)
        {
            _processingView.hidden = YES;
            [_processingView stopAnimating];
        }
    }
    else
    {
        if (_processingView)
        {
            _processingView.hidden = YES;
            [_processingView stopAnimating];
        }
        if (_failureButton)
        {
            _failureButton.hidden = YES;
        }
    }
}

- (UIActivityIndicatorView *)processingView
{
    if (_processingView == nil)
    {
        _processingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _processingView.frame = CGRectMake(0, 0, 20, 20);
        _processingView.hidesWhenStopped = YES;
        [self addSubview:_processingView];
    }

    return _processingView;
}

- (UIButton *)failureButton
{
    if (_failureButton == nil)
    {
        _failureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];

        UIImage *btnImg = [UIImage imageNamed:@"im_failure"];

        [_failureButton setImage:btnImg forState:UIControlStateNormal];
        [_failureButton setImage:[btnImg imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];

        [_failureButton addTarget:self action:@selector(resendMessage) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_failureButton];
    }

    return _failureButton;
}

- (void)resendMessage
{
//    [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_MESSAGE_FAILURE_HANDLE object:self.message]];
    self.failure(_message);
}

+ (CGSize)contentSizeForMessage:(EBIMMessage *)message
{
    Class cls = [self viewClassFromContentType:message.type];
    return [cls neededContentSize:message];
}

+ (Class)viewClassFromContentType:(EMessageContentType)contentType
{
    if (contentType == EMessageContentTypeNewHouse)
    {
        contentType = EMessageContentTypeHouse;
    }
    NSArray *viewClasses = @[@"Text", @"House",  @"Client", @"Image",  @"Audio", @"LocationShare", @"LocationReport", @"Text"];
    if (contentType >= EMessageContentTypeText && contentType <= EMessageContentTypeLink)
    {
        NSString *className = [NSString stringWithFormat:@"EBContent%@View", viewClasses[contentType]];
        return NSClassFromString(className);
    }

    return [EBContentBaseView class];
}

@end