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

#import <UIKit/UIKit.h>
#import "JSBubbleImageViewFactory.h"

@class EBIMMessage;
@class EBContentBaseView;

@interface EBBubbleView : UIView

@property (assign, nonatomic, readonly) JSBubbleMessageType type;
@property (weak, nonatomic, readonly) UIImageView *bubbleImageView;
@property (nonatomic, strong) UIActivityIndicatorView *processingView;
@property (nonatomic, strong) UIButton *failureButton;

@property (strong, nonatomic) EBIMMessage *message;

@property (strong, nonatomic) EBContentBaseView *contentView;
@property (copy, nonatomic) void (^failure)(EBIMMessage *message);

- (instancetype)initWithFrame:(CGRect)frame
                   bubbleType:(JSBubbleMessageType)bubleType
              bubbleImageView:(UIImageView *)bubbleImageView;

- (CGRect)bubbleFrame;

+ (CGSize)bubbleSize:(EBIMMessage *)message;
+ (CGSize)bubbleSizeWithContentSize:(CGSize)sz;

@end