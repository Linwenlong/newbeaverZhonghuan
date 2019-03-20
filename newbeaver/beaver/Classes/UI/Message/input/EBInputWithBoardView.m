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

#import "INTULocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "EBInputWithBoardView.h"
#import "JSDismissiveTextView.h"
#import "EBMessageInputView.h"
#import "EBEmojiBoardView.h"
#import "EBMoreBoardView.h"
#import "EBRecordingHUD.h"
#import "EBController.h"
#import "UIImage+Resize.h"
#import "EBRecorderPlayer.h"
#import "JSMessageInputView.h"
#import "EBAlert.h"
#import "EBRecordingButton.h"
#import "EBAMapLocation.h"
#import "EBMapService.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "EBStyle.h"

@interface EBInputWithBoardView ()  <EBEmojiBoardViewDelegate, EBMoreBoardViewDelegate,
        UITextViewDelegate, JSDismissiveTextViewDelegate>

@property (nonatomic, strong, readonly) NSMutableArray *emoijiArray;
@property (assign, nonatomic) CGFloat previousTextViewContentHeight;
@property (assign, nonatomic) UIView *lineView;

@end


@implementation EBInputWithBoardView

@synthesize emoijiArray;

#pragma mark - Initialization


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithWhite:0xeb/255.0f alpha:1.0];
        EBMessageInputView *inputView = [[EBMessageInputView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 45)
        delegate:self panGestureRecognizer:nil];
        [self addSubview:inputView];
        _messageInputView = inputView;

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 45, [EBStyle screenWidth], 1)];
        line.backgroundColor = [UIColor colorWithRed:0xac/255.0f green:0xba/255.0f blue:0xd4/255.f alpha:1.0];
        [self addSubview:line];
        _lineView = line;

        EBEmojiBoardView *emojiBoardView = [[EBEmojiBoardView alloc] initWithFrame:CGRectMake(0, 46, [EBStyle screenWidth], 215)];
        [self addSubview:emojiBoardView];
        _emojiBoardView = emojiBoardView;
        _emojiBoardView.clipsToBounds = NO;
        _emojiBoardView.delegate = self;
        _emojiBoardView.hidden = YES;
        _emojiBoardView.backgroundColor = self.backgroundColor;

        EBMoreBoardView *moreBoardView = [[EBMoreBoardView alloc] initWithFrame:CGRectMake(0, 46, [EBStyle screenWidth], 215)];
        [self addSubview:moreBoardView];
        _moreBoardView = moreBoardView;
        _moreBoardView.delgate = self;
        _moreBoardView.hidden = YES;
        _moreBoardView.backgroundColor = self.backgroundColor;

        [_messageInputView.moreButton addTarget:self action:@selector(showMoreBoard:) forControlEvents:UIControlEventTouchUpInside];
        [_messageInputView.faceButton addTarget:self action:@selector(showEmojiBoard:) forControlEvents:UIControlEventTouchUpInside];
        [_messageInputView.audioSwitchButton addTarget:self action:@selector(showRecording:) forControlEvents:UIControlEventTouchUpInside];

        [self bindRecordingEvent];

        _messageInputView.textView.delegate = self;
        _messageInputView.textView.keyboardDelegate = self;

        [self textChanged];
        [self bringSubviewToFront:emojiBoardView];
    }

    return self;
}

- (void)sendPressed
{
    NSString *content = _messageInputView.textView.text;
    if (content && content.length > 0)
    {
        [self.delegate inputWithBoardView:self sendText:_messageInputView.textView.text];
        _messageInputView.textView.text = nil;
        emoijiArray = nil;
        _messageInputView.textView.enablesReturnKeyAutomatically = YES;
//    [self resignFirstResponder];
        [self textChanged];
    }
}

- (BOOL)backspacePressed
{
   NSString *currentText = _messageInputView.textView.text;
   NSString *lastEmotion;

   BOOL shouldChangeText = YES;
   if (currentText && emoijiArray && emoijiArray.count > 0
           && (lastEmotion = [emoijiArray firstObject])
           && [currentText rangeOfString:lastEmotion].location == currentText.length - lastEmotion.length)
   {
       _messageInputView.textView.text = [currentText substringToIndex:currentText.length - lastEmotion.length];
       [emoijiArray removeObjectAtIndex:0];
       shouldChangeText = NO;
   }

   [self textChanged];

   return shouldChangeText;
}

- (void)textChanged
{
    _emojiBoardView.sendButton.enabled = _messageInputView.textView.text && _messageInputView.textView.text.length > 0;
}

-(NSMutableArray *)emoijiArray
{
    if (!emoijiArray)
    {
        emoijiArray = [[NSMutableArray alloc] init];
    }

    return emoijiArray;
}

#pragma mark -recording

- (void)showMoreBoard:(UIButton *)btn
{
    if (btn.isSelected)
    {
        [self showBoardView:_moreBoardView completion:^(BOOL finished)
        {
            _emojiBoardView.hidden = YES;
        }];
    }
}

- (void)showEmojiBoard:(UIButton *)btn
{
    if (btn.isSelected)
    {
       [self showBoardView:_emojiBoardView completion:^(BOOL finished)
       {
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
    [UIView animateWithDuration:0.30 animations:^
    {
        boardView.center = CGPointMake(boardView.center.x, originCenterY);
    } completion:completion];
}

- (void)showRecording:(UIButton *)btn
{
    if (btn.isSelected)
    {
        [self resignFirstResponder];
    }
    else
    {

    }
}

- (void)bindRecordingEvent
{
    static BOOL isRecording = NO;
    self.messageInputView.recordingButton.eventBlock = ^(ERecordingButtonEvent event){
       if (ERecordingButtonEventTouchesBegin == event)
       {
           isRecording = NO;
           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / 10), dispatch_get_main_queue(), ^
           {
               if (_messageInputView.recordingButton.stillTouching)
               {
                   isRecording = YES;
                   [[EBRecorderPlayer sharedInstance] startRecording:^(BOOL success, NSDictionary *result)
                   {
                       if (success)
                       {
                           [self.delegate inputWithBoardView:self sendAudio:result length:[result[@"length"] integerValue]];
                       }
                       else
                       {
                           if ([result[@"error"] isEqualToString:@"wav to amr failed"])
                           {

                           }
                           else
                           {
                               [EBAlert alertError:NSLocalizedString(result[@"error"], nil)];
                           }
                       }
                   }];

                   [EBRecordingHUD showWithAmpBlock:^NSInteger
                   {
                       return [[EBRecorderPlayer sharedInstance] recordingAmp];
                   }];

                   if (_messageInputView.recordingButton.touchOutside)
                   {
                       [EBRecordingHUD showReleaseHint];
                       [[EBRecorderPlayer sharedInstance] pauseRecording];
                   }
               }
           });
       }

       switch (event)
       {
           case ERecordingButtonEventTouchesMoveIn:
               [EBRecordingHUD showRecording];
               [[EBRecorderPlayer sharedInstance] resumeRecording];
               break;
           case ERecordingButtonEventTouchesMoveOut:
               [EBRecordingHUD showReleaseHint];
               [[EBRecorderPlayer sharedInstance] pauseRecording];
               break;
           case ERecordingButtonEventTouchesEnd:
               if (isRecording)
               {
                   [EBRecordingHUD dismiss];
                   [[EBRecorderPlayer sharedInstance] finishRecording];
               }
               else
               {
                   [EBAlert alertError:NSLocalizedString(@"recording too short", nil) length:0.5];
               }
               isRecording = NO;
               break;
           case ERecordingButtonEventTouchesCanceled:
               if (isRecording)
               {
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
    CGRect frame = CGRectMake(0, superView.frame.size.height - _messageInputView.frame.size.height,
            self.frame.size.width, self.frame.size.height);
    [_messageInputView resignFirstResponder];

    if (frame.origin.y != self.frame.origin.y && self.delegate)
    {
        [self.delegate inputWithBoardView:self boardFrameChange:frame];
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

    [self.delegate inputWithBoardView:self boardFrameChange:frame];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:
            ^{
                self.frame = frame;
            } completion:nil];

    return [super becomeFirstResponder];
}

- (BOOL)anyBoardVisible
{
    return _messageInputView.faceButton.isSelected || _messageInputView.moreButton.isSelected;
}

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight
{
    [self.messageInputView adjustTextViewHeightBy:changeInHeight];
    _messageInputView.frame = CGRectMake(0, 0, self.bounds.size.width, _messageInputView.frame.size.height + changeInHeight);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _messageInputView.frame = CGRectMake(0, 0, self.bounds.size.width, _messageInputView.frame.size.height);

    _lineView.frame = CGRectMake(0, _messageInputView.frame.size.height, self.bounds.size.width, 1);

    CGRect boardFrame = _emojiBoardView.frame;
    boardFrame.origin.y = _messageInputView.frame.size.height + 1;

    _emojiBoardView.frame = boardFrame;
    _moreBoardView.frame = boardFrame;
}

- (void)emojiBoardView:(EBEmojiBoardView *)boardView didSelect:(NSString *)faceStr
{
    NSString *currentText = _messageInputView.textView.text;
    if (currentText.length > 0)
    {
        _messageInputView.textView.text = [currentText stringByAppendingString:faceStr];
    }
    else
    {
        _messageInputView.textView.text = faceStr;
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
                                                                   [self.delegate inputWithBoardView:self sendImage:sendImage];
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
           [self.delegate inputWithBoardView:self shareLocation:poiInfo];
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
                [strongSelf.delegate inputWithBoardView:self reportLocation:@{@"lat":@(loc.coordinate.latitude), @"lon":@(loc.coordinate.longitude), @"address":[(AMapReGeocode *)regeocode formattedAddress]}];

            }];
        } superview:weakSelf];
        
//        MKMapView *_mapView = [[MKMapView alloc] initWithFrame:self.bounds];
//        _mapView.showsUserLocation = YES;
////        _mapView.delegate = self;
//        static id addressRequest = nil;
//        [[EBAMapLocation sharedInstance] requestLocationWithTimeout:2
//                                                     completion:^(BOOL success, CGFloat lat, CGFloat lon)
//        {
//            [EBAlert hideLoading];
//            if (success)
//            {
//               addressRequest = [[EBAMapLocation sharedInstance] requestAddressWithLatitude:lat longitude:lon
//                                                            completion:^(id request, NSString *name, NSString *address)
//               {
//                   if (request == addressRequest)
//                   {
//                       [self.delegate inputWithBoardView:self reportLocation:@{@"lat":@(lat),
//                               @"lon":@(lon), @"address":address}];
//                   }
//               }];
//            }
//            else
//            {
//                [EBAlert alertError:NSLocalizedString(@"location_fetch_error", nil)];
//            }
//        }];
    }
}

- (void)registerEventObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboardNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [self.messageInputView.textView addObserver:self
                                    forKeyPath:@"contentSize"
                                       options:NSKeyValueObservingOptionNew
                                       context:nil];
}

- (void)removeEventObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self.messageInputView.textView removeObserver:self forKeyPath:@"contentSize"];
}

#pragma mark - Text view delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@""])
    {
        return [self backspacePressed];
    }

    if ([text isEqualToString:@"\n"])
    {
        [self sendPressed];
        return NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _messageInputView.moreButton.selected = NO;
    _messageInputView.faceButton.selected = NO;
    [self becomeFirstResponder];
    if (!self.previousTextViewContentHeight)
    {
        self.previousTextViewContentHeight = textView.contentSize.height;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self textChanged];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
//    [textView resignFirstResponder];
}

- (void)layoutAndAnimateMessageInputTextView:(UITextView *)textView
{
    CGFloat maxHeight = [JSMessageInputView maxHeight];

    BOOL isShrinking = textView.contentSize.height < self.previousTextViewContentHeight;
    CGFloat changeInHeight = textView.contentSize.height - self.previousTextViewContentHeight;

    if (!isShrinking && (self.previousTextViewContentHeight == maxHeight || textView.text.length == 0)) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
    }

    if (changeInHeight != 0.0f) {
        [UIView animateWithDuration:0.25f
                         animations:^{
//                             [self setTableViewInsetsWithBottomValue:_chatViewController.tableView.contentInset.bottom + changeInHeight];
//
//                             [self scrollToBottomAnimated:NO];

                             if (isShrinking)
                             {
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [self adjustTextViewHeightBy:changeInHeight];
                             }

                             CGRect inputViewFrame = self.frame;
                             self.frame = CGRectMake(0.0f,
                                     inputViewFrame.origin.y - changeInHeight,
                                     inputViewFrame.size.width,
                                     inputViewFrame.size.height + changeInHeight);

                             if (!isShrinking)
                             {
                                 // growing the view, animate the text view frame AFTER input view frame
                                 [self adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                         }];

        self.previousTextViewContentHeight = MIN(textView.contentSize.height, maxHeight);
    }

    // Once we reached the max height, we have to consider the bottom offset for the text view.
    // To make visible the last line, again we have to set the content offset.
    if (self.previousTextViewContentHeight == maxHeight)
    {
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime,
                dispatch_get_main_queue(),
                ^(void) {
                    CGPoint bottomOffset = CGPointMake(0.0f, textView.contentSize.height - textView.bounds.size.height);
                    [textView setContentOffset:bottomOffset animated:YES];
                });
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.messageInputView.textView && [keyPath isEqualToString:@"contentSize"]) {
        [self layoutAndAnimateMessageInputTextView:object];
    }
}

#pragma mark - Dismissive text view delegate
- (void)keyboardDidShow
{

}

- (void)keyboardDidScrollToPoint:(CGPoint)point
{
    CGRect inputViewFrame = self.frame;
    CGPoint keyboardOrigin = [self.superview convertPoint:point fromView:nil];
    inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height;

    if (inputViewFrame.origin.y != self.frame.origin.y)
    {
        [self.delegate inputWithBoardView:self boardFrameChange:inputViewFrame];
        self.frame = inputViewFrame;
    }
}

- (void)keyboardWillBeDismissed
{

}

- (void)keyboardWillSnapBackToPoint:(CGPoint)point
{

}

#pragma -mark keyboard
- (void)handleWillShowKeyboardNotification:(NSNotification *)notification
{
    [self keyboardWillShowHide:notification];
}

- (void)handleWillHideKeyboardNotification:(NSNotification *)notification
{
    [self keyboardWillShowHide:notification];
}

- (void)keyboardWillShowHide:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = (UIViewAnimationCurve)[[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    [UIView animateWithDuration:duration
                          delay:0.0
                        options:[self animationOptionsForCurve:curve]
                     animations:^{
                         CGFloat keyboardY = [self.superview convertRect:keyboardRect fromView:nil].origin.y;

                         CGRect inputViewFrame = self.messageInputView.frame;
                         CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;

                         // for ipad modal form presentations
//                         CGFloat messageViewFrameBottom = self.superview.frame.size.height - inputViewFrame.size.height;
//                         if (inputViewFrameY > messageViewFrameBottom)
//                             inputViewFrameY = messageViewFrameBottom;

                         if (inputViewFrameY > self.frame.origin.y && self.anyBoardVisible)
                         {

                         }
                         else
                         {
                             CGRect inputBoardFrame = self.frame;

                             CGRect newFrame = CGRectMake(inputBoardFrame.origin.x,
                                     inputViewFrameY,
                                     inputBoardFrame.size.width,
                                     inputBoardFrame.size.height);
                             [self.delegate inputWithBoardView:self boardFrameChange:newFrame];
                             self.frame = newFrame;
//                             [self setTableViewInsetsWithBottomValue:_chatViewController.view.frame.size.height
//                                     - _chatViewController.inputWithBoardView.frame.origin.y];
                         }
                     }
                     completion:nil];
}

- (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve
{
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;

        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;

        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;

        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;

        default:
            return kNilOptions;
    }
}


@end
