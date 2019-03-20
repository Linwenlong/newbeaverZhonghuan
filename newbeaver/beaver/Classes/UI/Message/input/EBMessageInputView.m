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

#import "EBMessageInputView.h"

#import "NSString+JSMessagesView.h"
#import "UIImage+Alpha.h"
#import "EBStyle.h"
#import "EBRecordingButton.h"

@interface EBMessageInputView ()
{
    UIImageView *_inputBackground;
    CGFloat _lastFrameHeight;
    CGFloat _originY;
}



@end



@implementation EBMessageInputView

#pragma mark - Initialization

- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    self.userInteractionEnabled = YES;
}

- (void)configureInputBar
{
    _inputBackground = [[UIImageView alloc] initWithFrame:CGRectMake(47.0f, 7.5f, 189, 30)];
    _inputBackground.image = [[UIImage imageNamed:@"im_bg_textfield"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 5, 15, 5)];
    [self addSubview:_inputBackground];

    JSMessageTextView *textView = [[JSMessageTextView  alloc] initWithFrame:CGRectZero];
    [self addSubview:textView];
	_textView = textView;

    _textView.frame = CGRectOffset(_inputBackground.frame, 0, 2);
    _textView.backgroundColor = [UIColor clearColor];
    _textView.returnKeyType = UIReturnKeySend;
    _textView.enablesReturnKeyAutomatically = YES;

    self.image = [[UIImage imageNamed:@"im_bg_input"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)];
}

- (void)configureInputButtons
{
    [self configureFaceButton];
    [self configureAudioButton];
    [self configureMoreButton];
    [self configureRecordingButton];
}

- (void)configureRecordingButton
{
    EBRecordingButton *btn = [[EBRecordingButton alloc] initWithFrame:CGRectInset(_inputBackground.frame, 0, -20)];

    [self addSubview:btn];

    _recordingButton = btn;

    _recordingButton.hidden = YES;
//    [self updateAudioButtonState:NO];
}

- (void)configureFaceButton
{
    _faceButton = [self buttonWithX:_inputBackground.frame.origin.x + _inputBackground.frame.size.width + 10
                              image:[UIImage imageNamed:@"im_btn_face"]];
    [_faceButton addTarget:self action:@selector(updateButtonState:) forControlEvents:UIControlEventTouchUpInside];
//    [_audioSwitchButton setImage:[UIImage imageNamed:@"im_btn_keyboard"] forState:UIControlStateSelected];
//    [_audioSwitchButton addTarget:self action:@selector(switchAudio:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureMoreButton
{
    _moreButton = [self buttonWithX:_faceButton.frame.origin.x + _faceButton.frame.size.width +10 image:[UIImage imageNamed:@"im_btn_more"]];
    [_moreButton addTarget:self action:@selector(updateButtonState:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureAudioButton
{
    _audioSwitchButton = [self buttonWithX:10 image:[UIImage imageNamed:@"im_btn_micphone"]];
    [_audioSwitchButton addTarget:self action:@selector(switchAudio:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)switchAudio:(UIButton *)btn
{
    [btn setSelected:!btn.isSelected];
    [self updateAudioButtonState:btn.isSelected];
}

- (void)updateButtonState:(UIButton *)btn
{
    [btn setSelected:!btn.isSelected];
    if (btn.isSelected)
    {
        if (_audioSwitchButton.isSelected)
        {
            _recordingButton.hidden = YES;
            _inputBackground.hidden = NO;
            _textView.hidden = NO;
            [_audioSwitchButton setSelected:NO];
        }
        else
        {
             if (btn == _faceButton)
             {
                 [_moreButton setSelected:NO];
             }
             else if (btn == _moreButton)
             {
                 [_faceButton setSelected:NO];
             }
        }

        [_textView resignFirstResponder];
    }
    else
    {
        [_textView becomeFirstResponder];
    }
}

- (void)updateAudioButtonState:(BOOL)audioShow
{
    if (audioShow)
    {
        _recordingButton.hidden = NO;
        _inputBackground.hidden = YES;
        _textView.hidden = YES;

        [_faceButton setSelected:NO];
        [_moreButton setSelected:NO];

        [_textView resignFirstResponder];
    }
    else
    {
        _recordingButton.hidden = YES;
        _inputBackground.hidden = NO;
        _textView.hidden = NO;
        [_textView becomeFirstResponder];
    }
}

- (UIButton *)buttonWithX:(CGFloat)xOffset image:(UIImage *)image
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(xOffset, 9, 27, 27)];

    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:[image imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];

    [btn setImage:[UIImage imageNamed:@"im_btn_keyboard"] forState:UIControlStateSelected];
    [btn setImage:[[UIImage imageNamed:@"im_btn_keyboard"] imageByApplyingAlpha:0.4]
                        forState:UIControlStateHighlighted | UIControlStateSelected];
//    [btn addTarget:self action:@selector(switchAudio:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:btn];

    return btn;
}

- (instancetype)initWithFrame:(CGRect)frame
                     delegate:(id<UITextViewDelegate, JSDismissiveTextViewDelegate>)delegate
         panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{
    self = [super initWithFrame:frame];
    if (self) {
        _originY = frame.origin.y;
        _lastFrameHeight = frame.size.height;
        [self setup];
        [self configureInputBar];
        [self configureInputButtons];
        _textView.delegate = delegate;
        _textView.keyboardDelegate = delegate;
        _textView.dismissivePanGestureRecognizer = panGestureRecognizer;
    }
    return self;
}

- (void)dealloc
{
    _textView = nil;
}

#pragma mark - UIView

- (BOOL)resignFirstResponder
{
    [_faceButton setSelected:NO];
    [_moreButton setSelected:NO];
    [self.textView resignFirstResponder];
    return [super resignFirstResponder];
}

#pragma mark - Message input view

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight
{
    CGRect prevFrame = self.textView.frame;
    
    NSUInteger numLines = MAX([self.textView numberOfLinesOfText],
                              [self.textView.text js_numberOfLines]);
    
    //  below iOS 7, if you set the text view frame programmatically, the KVO will continue notifying
    //  to avoid that, we are removing the observer before setting the frame and add the observer after setting frame here.
    [self.textView removeObserver:_textView.keyboardDelegate
                       forKeyPath:@"contentSize"];
    
    self.textView.frame = CGRectMake(prevFrame.origin.x,
                                     prevFrame.origin.y,
                                     prevFrame.size.width,
                                     prevFrame.size.height + changeInHeight);
    _inputBackground.frame = CGRectOffset(_textView.frame, 0, 2);
    
    [self.textView addObserver:_textView.keyboardDelegate
                    forKeyPath:@"contentSize"
                       options:NSKeyValueObservingOptionNew
                       context:nil];

    self.textView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f,
                                                  (numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f);
    
    // from iOS 7, the content size will be accurate only if the scrolling is enabled.
    self.textView.scrollEnabled = YES;
    
    if (numLines >= 6) {
        CGPoint bottomOffset = CGPointMake(0.0f, self.textView.contentSize.height - self.textView.bounds.size.height);
        [self.textView setContentOffset:bottomOffset animated:YES];
        [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length - 2, 1)];
    }
}

+ (CGFloat)textViewLineHeight
{
    return 36.0f; // for fontSize 16.0f
}

+ (CGFloat)maxLines
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 4.0f : 8.0f;
}

+ (CGFloat)maxHeight
{
    return ([EBMessageInputView maxLines] + 1.0f) * [EBMessageInputView textViewLineHeight];
}

@end
