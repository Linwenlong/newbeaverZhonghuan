//
//  ECMessageBoardView.h
//  chowAgent
//
//  Created by LiuLian on 11/6/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EBMessageInputbar, EBEmojiBoardView, EBMoreBoardView;
@protocol EBMessageBoardViewDelegate;

@interface EBMessageBoardView : UIView

@property (nonatomic, weak) id<EBMessageBoardViewDelegate>delegate;
@property (nonatomic, strong) EBMessageInputbar *messageInputbar;
@property (nonatomic, strong) EBEmojiBoardView *emojiBoardView;
@property (nonatomic, strong) EBMoreBoardView *moreBoardView;

- (void)registerNotifications;
- (void)removeNotifications;
@end

@protocol EBMessageBoardViewDelegate<NSObject>

- (void)messageBoardView:(EBMessageBoardView *)boardView boardFrameChange:(CGRect)frame;

- (void)messageBoardView:(EBMessageBoardView *)boardView sendText:(NSString *)text;
- (void)messageBoardView:(EBMessageBoardView *)boardView sendImage:(UIImage *)image;

- (void)messageBoardView:(EBMessageBoardView *)boardView shareLocation:(NSDictionary *)poiInfo;
- (void)messageBoardView:(EBMessageBoardView *)boardView reportLocation:(NSDictionary *)poiInfo;

- (void)messageBoardView:(EBMessageBoardView *)boardView sendAudio:(NSDictionary *)audioInfo length:(NSTimeInterval)length;

@end