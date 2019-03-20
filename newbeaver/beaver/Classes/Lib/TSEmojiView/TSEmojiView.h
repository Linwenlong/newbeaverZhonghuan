//
//  TSEmojiView.h
//  TSEmojiView
//
//  Created by Shawn Ma on 7/24/12.
//  Copyright (c) 2012 Telenav Software, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@protocol TSEmojiViewDelegate;
@interface TSEmojiView : UIView 

@property (assign, nonatomic) id<TSEmojiViewDelegate> delegate;
@property (nonatomic, strong) NSDictionary *faceMap;
@property (nonatomic, strong) NSArray *emojiKeys;

- (id)initWithFrame:(CGRect)frame;

@end

@protocol TSEmojiViewDelegate<NSObject>
@optional
- (void)didTouchEmojiView:(TSEmojiView*)emojiView touchedEmoji:(NSString*)string;
- (void)didTouchEmojiViewBackspace:(TSEmojiView*)emojiView;
@end
