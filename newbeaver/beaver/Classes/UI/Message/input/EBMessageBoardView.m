//
//  ECMessageBoardView.m
//  chowAgent
//
//  Created by LiuLian on 11/6/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#import "EBMessageBoardView.h"
#import "EBMessageInputbar.h"
#import "EBEmojiBoardView.h"
#import "EBMoreBoardView.h"
#import "EBMessageTextView.h"
#import "EBRecordingButton.h"
#import "EBRecorderPlayer.h"
#import "EBRecordingHUD.h"
#import "EBAlert.h"
#import "EBController.h"
#import "UIImage+Resize.h"
#import "EBMapService.h"
#import <CoreLocation/CoreLocation.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@interface EBMessageBoardView() <EBEmojiBoardViewDelegate, EBMoreBoardViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong, readonly) NSMutableArray *emoijiArray;

@end

@implementation EBMessageBoardView
@synthesize emoijiArray;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithWhite:0xef/255.0f alpha:1.0];
        _messageInputbar = [[EBMessageInputbar alloc] initWithFrame:CGRectMake(0, 0, self.width, 44)];
        [self addSubview:_messageInputbar];
        _messageInputbar.backgroundColor = self.backgroundColor;
        _messageInputbar.textView.delegate = self;
        
        EBEmojiBoardView *emojiBoardView = [[EBEmojiBoardView alloc] initWithFrame:CGRectMake(0, _messageInputbar.bottom, self.width, self.height-_messageInputbar.height)];
        [self addSubview:emojiBoardView];
        _emojiBoardView = emojiBoardView;
        _emojiBoardView.clipsToBounds = NO;
        _emojiBoardView.delegate = self;
        _emojiBoardView.hidden = YES;
        _emojiBoardView.backgroundColor = self.backgroundColor;
        
        EBMoreBoardView *moreBoardView = [[EBMoreBoardView alloc] initWithFrame:CGRectMake(0, _messageInputbar.bottom, self.width, self.height-_messageInputbar.height)];
        [self addSubview:moreBoardView];
        _moreBoardView = moreBoardView;
        _moreBoardView.delgate = self;
        _moreBoardView.hidden = YES;
        _moreBoardView.backgroundColor = self.backgroundColor;
        
        [_messageInputbar.moreButton addTarget:self action:@selector(showMoreBoard:) forControlEvents:UIControlEventTouchUpInside];
        [_messageInputbar.faceButton addTarget:self action:@selector(showEmojiBoard:) forControlEvents:UIControlEventTouchUpInside];
        [_messageInputbar.audioButton addTarget:self action:@selector(showRecording:) forControlEvents:UIControlEventTouchUpInside];
        
        [self bindRecordingEvent];
        [self textChanged];
//        [self bringSubviewToFront:emojiBoardView];
    }
    
    return self;
}

-(NSMutableArray *)emoijiArray
{
    if (!emoijiArray) {
        emoijiArray = [[NSMutableArray alloc] init];
    }
    
    return emoijiArray;
}

#pragma mark -recording

- (void)showMoreBoard:(UIButton *)btn
{
    if (btn.isSelected) {
        [self showBoardView:_moreBoardView completion:^(BOOL finished){
            _emojiBoardView.hidden = YES;
        }];
    }
}

- (void)showEmojiBoard:(UIButton *)btn
{
    if (btn.isSelected) {
        [self showBoardView:_emojiBoardView completion:^(BOOL finished){
            _moreBoardView.hidden = YES;
        }];
    }
}

- (void)showBoardView:(UIView *)boardView completion:(void (^)(BOOL finished))completion
{
    [self becomeFirstResponder];
    
    [self bringSubviewToFront:boardView];
    CGFloat originCenterY = boardView.center.y;
    boardView.center = CGPointMake(boardView.center.x, originCenterY + boardView.frame.size.height);
    boardView.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        boardView.center = CGPointMake(boardView.center.x, originCenterY);
    } completion:completion];
}

- (void)showRecording:(UIButton *)btn
{
    if (btn.isSelected){
        [self resignFirstResponder];
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGFloat dy = self.superview.frame.size.height - (self.frame.origin.y + 44);
            self.frame = CGRectOffset(self.frame, 0, dy);
            [self.delegate messageBoardView:self boardFrameChange:self.frame];
        } completion:nil];
    }
    else
    {
        
    }
}

- (void)bindRecordingEvent
{
    __weak EBMessageBoardView *weakSelf = self;
    static BOOL isRecording = NO;
    _messageInputbar.recordingButton.eventBlock = ^(ERecordingButtonEvent event) {
        if (ERecordingButtonEventTouchesBegin == event) {
            isRecording = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / 10), dispatch_get_main_queue(), ^{
                if (weakSelf.messageInputbar.recordingButton.stillTouching) {
                    isRecording = YES;
                    [[EBRecorderPlayer sharedInstance] startRecording:^(BOOL success, NSDictionary *result) {
                        if (success) {
                            [weakSelf.delegate messageBoardView:weakSelf sendAudio:result length:[result[@"length"] integerValue]];
                        } else {
                            if ([result[@"error"] isEqualToString:@"wav to amr failed"]) {
                            
                            } else {
                                [EBAlert alertError:NSLocalizedString(result[@"error"], nil)];
                            }
                        }
                    }];
                    [EBRecordingHUD showWithAmpBlock:^NSInteger{
                        return [[EBRecorderPlayer sharedInstance] recordingAmp];
                    }];
                    if (weakSelf.messageInputbar.recordingButton.touchOutside) {
                        [EBRecordingHUD showReleaseHint];
                        [[EBRecorderPlayer sharedInstance] pauseRecording];
                    }
                }
            });
        }
        
        switch (event) {
            case ERecordingButtonEventTouchesMoveIn:
                [EBRecordingHUD showRecording];
                [[EBRecorderPlayer sharedInstance] resumeRecording];
                break;
            case ERecordingButtonEventTouchesMoveOut:
                [EBRecordingHUD showReleaseHint];
                [[EBRecorderPlayer sharedInstance] pauseRecording];
                break;
            case ERecordingButtonEventTouchesEnd:
                if (isRecording) {
                    [EBRecordingHUD dismiss];
                    [[EBRecorderPlayer sharedInstance] finishRecording];
                } else {
                    [EBAlert alertError:NSLocalizedString(@"im_recording_too_short", nil) length:0.5];
                }
                isRecording = NO;
                break;
            case ERecordingButtonEventTouchesCanceled:
                if (isRecording) {
                    [EBRecordingHUD dismiss];
                    [[EBRecorderPlayer sharedInstance] cancelRecording];
                }
                isRecording = NO;
                break;
            default:
                break;
        }
    };
}

- (BOOL)resignFirstResponder
{
    UIView *superView = [self superview];
    CGRect frame = CGRectMake(0, superView.frame.size.height - _messageInputbar.frame.size.height, self.frame.size.width, self.frame.size.height);
    [_messageInputbar resignFirstResponder];
    
    if (frame.origin.y != self.frame.origin.y && self.delegate) {
        [self.delegate messageBoardView:self boardFrameChange:frame];
    }
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:
     ^{
         self.frame = frame;
     } completion:nil];
    
    return [super resignFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    UIView *superView = [self superview];
    CGRect frame = CGRectMake(0, superView.frame.size.height - self.frame.size.height,
                              self.frame.size.width, self.frame.size.height);
    
    [self.delegate messageBoardView:self boardFrameChange:frame];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:
     ^{
         self.frame = frame;
     } completion:nil];
    
    return [super becomeFirstResponder];
}

#pragma mark - Text view delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@""]){
        return [self backspacePressed];
    }
    
    if ([text isEqualToString:@"\n"]){
        [self sendPressed];
        return NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _messageInputbar.moreButton.selected = NO;
    _messageInputbar.faceButton.selected = NO;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self textChanged];
}

- (void)sendPressed
{
    NSString *content = _messageInputbar.textView.text;
    if (content && content.length > 0)
    {
        [self.delegate messageBoardView:self sendText:content];
        _messageInputbar.textView.text = nil;
        emoijiArray = nil;
        _messageInputbar.textView.enablesReturnKeyAutomatically = YES;
        [self textChanged];
    }
}

- (BOOL)backspacePressed
{
    NSString *currentText = _messageInputbar.textView.text;
    NSString *lastEmotion;
    
    BOOL shouldChangeText = YES;
    if (currentText && emoijiArray && emoijiArray.count > 0
        && (lastEmotion = [emoijiArray firstObject])
        && [currentText rangeOfString:lastEmotion options:NSBackwardsSearch].location == currentText.length - lastEmotion.length)
    {
        _messageInputbar.textView.text = [currentText substringToIndex:currentText.length - lastEmotion.length];
        [emoijiArray removeObjectAtIndex:0];
        shouldChangeText = NO;
    }
    
    [self textChanged];
    
    return shouldChangeText;
}

- (void)textChanged
{
    _emojiBoardView.sendButton.enabled = _messageInputbar.textView.text && _messageInputbar.textView.text.length > 0;
}

- (void)emojiBoardView:(EBEmojiBoardView *)boardView didSelect:(NSString *)faceStr
{
    NSString *currentText = _messageInputbar.textView.text;
    if (currentText.length > 0) {
        _messageInputbar.textView.text = [currentText stringByAppendingString:faceStr];
    } else {
        _messageInputbar.textView.text = faceStr;
    }
    
    [self.emoijiArray insertObject:faceStr atIndex:0];
    [self textChanged];
}

- (void)emojiBoardView:(EBEmojiBoardView *)boardView didDelete:(NSString *)faceStr
{
    [self backspacePressed];
}

- (void)emojiBoardView:(EBEmojiBoardView *)boardView didSend:(NSString *)faceStr
{
    [self sendPressed];
}

- (void)moreBoardView:(EBMoreBoardView *)boardView itemClicked:(NSInteger)index
{
    if (index < 2)
    {
        [[EBController sharedInstance] pickImageWithSourceType:
         index == 0 ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeCamera
                                                       handler:^(UIImage *image)
         {
             [EBAlert showLoading:nil];
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 UIImage *sendImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:image.size
                                                    interpolationQuality:kCGInterpolationLow];
                 
                 dispatch_async(dispatch_get_main_queue(), ^
                                {
                                    [self.delegate messageBoardView:self sendImage:sendImage];
                                    [EBAlert hideLoading];
                                });
             });
         }];
        
        [EBTrack event:index == 0 ? EVENT_CLICK_IM_CONVERSATION_SEND_EXISTING_PHOTO : EVENT_CLICK_IM_CONVERSATION_SEND_NEW_PHOTO];
    }
    else if (index == 2)
    {
        [[EBController sharedInstance] pickLocationWithBlock:^(NSDictionary *poiInfo)
         {
             [self.delegate messageBoardView:self shareLocation:poiInfo];
         } pickBySend:YES];
    }
    else if (index == 3)
    {
        [EBAlert showLoading:nil];
        __weak typeof(self) weakSelf = self;
        [[EBMapService sharedInstance] requestUserLocation:^(id location) {
            __strong typeof(self) strongSelf = weakSelf;
            if ([location isKindOfClass:[NSError class]]) {
                [EBAlert alertError:NSLocalizedString(@"location_fetch_error", nil)];
                return;
            }
            
            CLLocation *loc = [(MAUserLocation *)location location];
            [[EBMapService sharedInstance] searchReGeocode:loc.coordinate.latitude longitude:loc.coordinate.longitude handler:^(id regeocode, BOOL success) {
                [EBAlert hideLoading];
                if (!success) {
                    [EBAlert alertError:NSLocalizedString(@"location_fetch_error", nil)];
                    return;
                }
                [strongSelf.delegate messageBoardView:self reportLocation:@{@"lat":@(loc.coordinate.latitude), @"lon":@(loc.coordinate.longitude), @"address":[(AMapReGeocode *)regeocode formattedAddress]}];
                
            }];
        } superview:weakSelf];
    }
}

#pragma mark - events
- (void)didChangeTextViewText:(NSNotification *)notification
{
    EBMessageTextView *textView = (EBMessageTextView *)notification.object;
    
    // Skips this it's not the expected textView.
    if (![textView isEqual:self.messageInputbar.textView]) {
        return;
    }
    
    // Animated only if the view already appeared
    [self textDidUpdate];
}

- (void)didChangeTextViewContentSize:(NSNotification *)notification
{
    // Skips this it's not the expected textView.
    if (![self.messageInputbar.textView isEqual:notification.object]) {
        return;
    }
    
    // Animated only if the view already appeared
    [self textDidUpdate];
    [_messageInputbar.textView scrollRangeToVisible:NSMakeRange(_messageInputbar.textView.text.length - 2, 1)];
}

- (void)textDidUpdate
{
    CGFloat inputbarHeight = [self appropriateInputbarHeight];
    CGFloat dh = inputbarHeight - self.messageInputbar.height;
    
    if (dh != 0) {
        self.frame = CGRectMake(self.left, self.top-dh, self.width, self.height+dh);
        self.messageInputbar.frame = CGRectMake(self.messageInputbar.left, self.messageInputbar.top, self.messageInputbar.width, self.messageInputbar.height+dh);
        self.messageInputbar.textView.frame = CGRectMake(self.messageInputbar.textView.left, self.messageInputbar.textView.top, self.messageInputbar.textView.width, self.messageInputbar.textView.height+dh);
        self.emojiBoardView.frame = CGRectOffset(self.emojiBoardView.frame, 0, dh);
        self.moreBoardView.frame = CGRectOffset(self.moreBoardView.frame, 0, dh);
    }
}

- (CGFloat)deltaInputbarHeight
{
    return self.messageInputbar.textView.intrinsicContentSize.height-self.messageInputbar.textView.font.lineHeight;
}

- (CGFloat)minimumInputbarHeight
{
    return self.messageInputbar.intrinsicContentSize.height;
}

- (CGFloat)inputBarHeightForLines:(NSUInteger)numberOfLines
{
    CGFloat height = [self deltaInputbarHeight];
    
    height += roundf(self.messageInputbar.textView.font.lineHeight*numberOfLines);
    height += self.messageInputbar.contentInset.top+self.messageInputbar.contentInset.bottom;
    
    return height;
}

- (CGFloat)appropriateInputbarHeight
{
    CGFloat height = 0.0;
    
    if (self.messageInputbar.textView.numberOfLines == 1) {
        height = [self minimumInputbarHeight];
    }
    else if (self.messageInputbar.textView.numberOfLines < self.messageInputbar.textView.maxNumberOfLines) {
        height += [self inputBarHeightForLines:self.messageInputbar.textView.numberOfLines];
    }
    else {
        height += [self inputBarHeightForLines:self.messageInputbar.textView.maxNumberOfLines];
    }
    
    if (height < [self minimumInputbarHeight]) {
        height = [self minimumInputbarHeight];
    }
    
    return roundf(height);
}

#pragma mark - imagepickerview delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *sendImage = [selectedImage resizedImageWithContentMode: UIViewContentModeScaleAspectFit bounds:selectedImage.size interpolationQuality:kCGInterpolationLow];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self.delegate messageBoardView:self sendImage:sendImage];
        });
    });
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    
}

#pragma mark - register/unregister notifications
- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeTextViewText:) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeTextViewContentSize:) name:MessageTextViewContentSizeDidChangeNotification object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MessageTextViewContentSizeDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

@end
