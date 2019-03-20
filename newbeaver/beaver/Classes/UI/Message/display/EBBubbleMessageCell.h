//
// Created by 何 义 on 14-4-1.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "JSBubbleMessageCell.h"
#import "EBIMMessage.h"
#import "RTLabel.h"

@class EBBubbleView;


@interface EBBubbleMessageCell : UITableViewCell<RTLabelDelegate>

@property (weak, nonatomic, readonly) EBBubbleView *bubbleView;

@property (nonatomic, strong) EBIMMessage *message;

@property (weak, nonatomic, readonly) UILabel *timestampLabel;

@property (weak, nonatomic, readonly) UIImageView *avatarImageView;

@property (weak, nonatomic, readonly) UILabel *nameLabel;

@property (weak, nonatomic, readonly) UIView *extraView;

@property (weak, nonatomic, readonly) RTLabel *extraLabel;

@property (weak, nonatomic, readonly) UIButton *sourceBtn;

- (instancetype)initWithBubbleType:(JSBubbleMessageType)type
                   bubbleImageView:(UIImageView *)bubbleImageView
                           message:(EBIMMessage *)message
                   reuseIdentifier:(NSString *)reuseIdentifier;

- (JSBubbleMessageType)messageType;

+ (CGFloat)neededHeightForBubbleMessageCellWithMessage:(EBIMMessage *)message;
+ (CGFloat)contentHeightForMessage:(EBIMMessage *)message;

- (void)setCellSendingStatus;

@end