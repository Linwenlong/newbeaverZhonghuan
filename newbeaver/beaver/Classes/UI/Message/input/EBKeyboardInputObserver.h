//
// Created by 何 义 on 14-4-1.
// Copyright (c) 2014 eall. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "JSDismissiveTextView.h"

@class ChatViewController;


@interface EBKeyboardInputObserver : NSObject<UITextViewDelegate, JSDismissiveTextViewDelegate>

@property (weak, nonatomic) ChatViewController *chatViewController;

- (void)doInitialize;
- (void)scrollToBottomAnimated:(BOOL)animated;

- (void)viewWillAppear;
- (void)viewWillDisappear;

- (void)pullDownInputBoard;

@end