//
//  ECMessageInputbar.m
//  chowAgent
//
//  Created by LiuLian on 11/6/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#import "EBMessageInputbar.h"
#import "EBMessageTextView.h"
#import "EBRecordingButton.h"
#import "UIImage+Alpha.h"

@implementation EBMessageInputbar

- (id)init
{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _contentInset = UIEdgeInsetsMake(5.0, 8.0, 5.0, 8.0);
    
    [self addSubview:self.audioButton];
    [self addSubview:self.faceButton];
    [self addSubview:self.moreButton];
    [self addSubview:self.textView];
    
    [self setupViews];
}

- (void)setupViews
{
    self.audioButton.frame = CGRectOffset(self.audioButton.frame, _contentInset.left, _contentInset.top);
    self.moreButton.frame = CGRectMake(self.width-_contentInset.right-self.moreButton.width, _contentInset.top, self.moreButton.width, self.moreButton.height);
    self.faceButton.frame = CGRectMake(self.moreButton.left-_contentInset.right-self.moreButton.width, _contentInset.top, self.faceButton.width, self.faceButton.height);
    self.textView.frame = CGRectMake(self.audioButton.right+_contentInset.right, _contentInset.top, self.faceButton.left-self.audioButton.right-_contentInset.right*2, self.textView.intrinsicContentSize.height);
    [self addSubview:self.recordingButton];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - UIView Overrides

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, 44.0);
}

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (BOOL)resignFirstResponder
{
    [_faceButton setSelected:NO];
    [_moreButton setSelected:NO];
    [_textView resignFirstResponder];
    return [super resignFirstResponder];
}

#pragma mark - Getters

- (EBMessageTextView *)textView
{
    if (!_textView)
    {
        _textView = [[EBMessageTextView alloc] initWithFrame:self.bounds];
        _textView.maxNumberOfLines = 4;
        
//        _textView.autocorrectionType = UITextAutocorrectionTypeDefault;
//        _textView.spellCheckingType = UITextSpellCheckingTypeDefault;
//        _textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
//        _textView.keyboardType = UIKeyboardTypeTwitter;
        _textView.returnKeyType = UIReturnKeySend;
//        _textView.enablesReturnKeyAutomatically = YES;
        _textView.scrollIndicatorInsets = UIEdgeInsetsMake(0, -1, 0, 1);
        _textView.textContainerInset = UIEdgeInsetsMake(8.0, 3.5, 8.0, 0.0);
        _textView.layer.cornerRadius = 5.0;
        _textView.layer.borderWidth = 0.5;
        _textView.layer.borderColor =  [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:205.0/255.0 alpha:1.0].CGColor;
    }
    return _textView;
}

- (UIButton *)audioButton
{
    if (!_audioButton) {
        _audioButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
        
        UIImage *image = [UIImage imageNamed:@"im_btn_micphone"];
        [_audioButton setImage:image forState:UIControlStateNormal];
        [_audioButton setImage:[image imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
        
        [_audioButton setImage:[UIImage imageNamed:@"im_btn_keyboard"] forState:UIControlStateSelected];
        [_audioButton setImage:[[UIImage imageNamed:@"im_btn_keyboard"] imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted | UIControlStateSelected];
        
        [_audioButton addTarget:self action:@selector(switchAudio:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _audioButton;
}

- (UIButton *)faceButton
{
    if (!_faceButton) {
        _faceButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
        
        UIImage *image = [UIImage imageNamed:@"im_btn_face"];
        [_faceButton setImage:image forState:UIControlStateNormal];
        [_faceButton setImage:[image imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
        
        [_faceButton setImage:[UIImage imageNamed:@"im_btn_keyboard"] forState:UIControlStateSelected];
        [_faceButton setImage:[[UIImage imageNamed:@"im_btn_keyboard"] imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted | UIControlStateSelected];
        
        [_faceButton addTarget:self action:@selector(updateButtonState:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceButton;
}

- (UIButton *)moreButton
{
    if (!_moreButton) {
        _moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
        
        UIImage *image = [UIImage imageNamed:@"im_btn_more"];
        [_moreButton setImage:image forState:UIControlStateNormal];
        [_moreButton setImage:[image imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
        
        [_moreButton setImage:[UIImage imageNamed:@"im_btn_keyboard"] forState:UIControlStateSelected];
        [_moreButton setImage:[[UIImage imageNamed:@"im_btn_keyboard"] imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted | UIControlStateSelected];
        
        [_moreButton addTarget:self action:@selector(updateButtonState:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (EBRecordingButton *)recordingButton
{
    if (!_recordingButton) {
        _recordingButton = [[EBRecordingButton alloc] initWithFrame:self.textView.frame];
        
        _recordingButton.hidden = YES;
    }
    return _recordingButton;
}

- (void)switchAudio:(UIButton *)btn
{
    [btn setSelected:!btn.isSelected];
    [self updateAudioButtonState:btn.isSelected];
}

- (void)updateButtonState:(UIButton *)btn
{
    [btn setSelected:!btn.isSelected];
    if (btn.isSelected) {
        if (_audioButton.isSelected) {
            _recordingButton.hidden = YES;
            _textView.hidden = NO;
            [_audioButton setSelected:NO];
        } else {
            if (btn == _faceButton) {
                [_moreButton setSelected:NO];
            } else if (btn == _moreButton) {
                [_faceButton setSelected:NO];
            }
        }
        
        [_textView resignFirstResponder];
    } else {
        [_textView becomeFirstResponder];
    }
}

- (void)updateAudioButtonState:(BOOL)audioShow
{
    if (audioShow) {
        _recordingButton.hidden = NO;
        _textView.hidden = YES;
        
        [_faceButton setSelected:NO];
        [_moreButton setSelected:NO];
        
        [_textView resignFirstResponder];
    } else {
        _recordingButton.hidden = YES;
        _textView.hidden = NO;
        [_textView becomeFirstResponder];
    }
}

@end
