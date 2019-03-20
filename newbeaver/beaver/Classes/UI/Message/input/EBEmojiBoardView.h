//
//  EBEmojiBoardView.h
//
//  Created by jack on 13-10-19.
//  Copyright (c) 2013年 appkefu.com. All rights reserved.
//

#import "TSEmojiView.h"

@class EBEmojiBoardView;
@protocol EBEmojiBoardViewDelegate <NSObject>

-(void)emojiBoardView:(EBEmojiBoardView *)boardView didSelect:(NSString *)faceStr;
-(void)emojiBoardView:(EBEmojiBoardView *)boardView didDelete:(NSString *)faceStr;
-(void)emojiBoardView:(EBEmojiBoardView *)boardView didSend:(NSString *)faceStr;

@end


@interface EBEmojiBoardView : UIView<TSEmojiViewDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) id<EBEmojiBoardViewDelegate> delegate;

@property (nonatomic, strong) UIScrollView      *scrollView;
@property (nonatomic, strong) UIPageControl     *pageControl;

@property (nonatomic, strong) UIButton          *sendButton;

@end
