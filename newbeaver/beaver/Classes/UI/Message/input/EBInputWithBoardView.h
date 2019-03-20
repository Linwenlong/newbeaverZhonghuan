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
@protocol JSDismissiveTextViewDelegate;
@class EBMessageInputView;
@class EBEmojiBoardView;
@class EBMoreBoardView;


@protocol EBInputWithBoardViewDelegate;
/**
 *  An instance of `EBInputWithBoardView` defines the input toolbar for composing a new message that is to be displayed above the keyboard.
 */
@interface EBInputWithBoardView : UIView

@property (nonatomic, assign)id<EBInputWithBoardViewDelegate> delegate;
@property (nonatomic, weak) EBMessageInputView *messageInputView;
@property (nonatomic, weak) EBEmojiBoardView *emojiBoardView;
@property (nonatomic, weak) EBMoreBoardView *moreBoardView;
@property (nonatomic, readonly) BOOL anyBoardVisible;

/**
 *  The send button for the input view. The default value is an initialized `UIButton` whose appearance is styled according to the value of style during initialization. 
 *  @see EBInputWithBoardViewStyle.
 */

#pragma mark - Initialization
- (instancetype)initWithFrame:(CGRect)frame;

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;
- (void)sendPressed;
- (void)textChanged;

- (void)registerEventObservers;
- (void)removeEventObservers;

@end

@protocol EBInputWithBoardViewDelegate<NSObject>

- (void)inputWithBoardView:(EBInputWithBoardView *)boardView boardFrameChange:(CGRect)frame;

- (void)inputWithBoardView:(EBInputWithBoardView *)boardView sendText:(NSString *)text;
- (void)inputWithBoardView:(EBInputWithBoardView *)boardView sendImage:(UIImage *)image;

- (void)inputWithBoardView:(EBInputWithBoardView *)boardView shareLocation:(NSDictionary *)poiInfo;
- (void)inputWithBoardView:(EBInputWithBoardView *)boardView reportLocation:(NSDictionary *)poiInfo;

- (void)inputWithBoardView:(EBInputWithBoardView *)boardView sendAudio:(NSDictionary *)audioInfo length:(NSTimeInterval)length;

@end