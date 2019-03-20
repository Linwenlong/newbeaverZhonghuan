//
// Created by 何 义 on 14-4-1.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBKeyboardInputObserver.h"
#import "ChatViewController.h"
#import "EBMessageInputView.h"
#import "EBInputWithBoardView.h"
#import "EBRecorderPlayer.h"

@interface EBKeyboardInputObserver()

@property (assign, nonatomic) CGFloat previousTextViewContentHeight;

@end


@implementation EBKeyboardInputObserver

//
//- (void)doInitialize
//{
//    [self setTableViewInsetsWithBottomValue:45];
//
//}
////
////- (void)showEmojiBoard:(UIButton *)btn
////{
////    UIView *keyboard = _chatViewController.messageInputView.inputAccessoryView.superview;
////
////    [UIView animateWithDuration:0.25
////                          delay:0.0
////                        options:[self animationOptionsForCurve:UIViewAnimationOptionCurveEaseInOut]
////                     animations:^{
////                        CGRect boardRect = _chatViewController.emojiBoardView.frame;
////                        boardRect.origin.y = _chatViewController.view.frame.size.height - 216;
////                        _chatViewController.emojiBoardView.frame = boardRect;
////                     }
////                     completion:nil];
////
////    [_chatViewController.messageInputView resignFirstResponder];
////}
//
//- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom
//{
//    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
//    _chatViewController.tableView.contentInset = insets;
//    _chatViewController.tableView.scrollIndicatorInsets = insets;
//}
//
//- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom
//{
//    UIEdgeInsets insets = UIEdgeInsetsZero;
//
//    if ([_chatViewController respondsToSelector:@selector(topLayoutGuide)])
//    {
//        insets.top = _chatViewController.topLayoutGuide.length;
//    }
//
//    insets.bottom = bottom;
//
//    return insets;
//}
//
//#pragma mark - Keyboard notifications
//
//- (void)handleWillShowKeyboardNotification:(NSNotification *)notification
//{
//    [self keyboardWillShowHide:notification];
//}
//
//- (void)handleWillHideKeyboardNotification:(NSNotification *)notification
//{
//    [self keyboardWillShowHide:notification];
//}
//
//- (void)keyboardWillShowHide:(NSNotification *)notification
//{
//    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    UIViewAnimationCurve curve = (UIViewAnimationCurve)[[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
//    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//
//    [UIView animateWithDuration:duration
//                          delay:0.0
//                        options:[self animationOptionsForCurve:curve]
//                     animations:^{
//                         CGFloat keyboardY = [_chatViewController.view convertRect:keyboardRect fromView:nil].origin.y;
//
//                         CGRect inputViewFrame = _chatViewController.messageInputView.frame;
//                         CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
//
//                         // for ipad modal form presentations
//                         CGFloat messageViewFrameBottom = _chatViewController.view.frame.size.height - inputViewFrame.size.height;
//                         if (inputViewFrameY > messageViewFrameBottom)
//                             inputViewFrameY = messageViewFrameBottom;
//
//                         if (inputViewFrameY > inputViewFrame.origin.y && _chatViewController.inputWithBoardView.anyBoardVisible)
//                         {
//
//                         }
//                         else
//                         {
//                             CGRect inputBoardFrame = _chatViewController.inputWithBoardView.frame;
//                             _chatViewController.inputWithBoardView.frame = CGRectMake(inputBoardFrame.origin.x,
//                                     inputViewFrameY,
//                                     inputBoardFrame.size.width,
//                                     inputBoardFrame.size.height);
//
//                             [self setTableViewInsetsWithBottomValue:_chatViewController.view.frame.size.height
//                                     - _chatViewController.inputWithBoardView.frame.origin.y];
//                         }
//                     }
//                     completion:nil];
//}
//
//#pragma mark - Utilities
//
//- (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve
//{
//    switch (curve) {
//        case UIViewAnimationCurveEaseInOut:
//            return UIViewAnimationOptionCurveEaseInOut;
//
//        case UIViewAnimationCurveEaseIn:
//            return UIViewAnimationOptionCurveEaseIn;
//
//        case UIViewAnimationCurveEaseOut:
//            return UIViewAnimationOptionCurveEaseOut;
//
//        case UIViewAnimationCurveLinear:
//            return UIViewAnimationOptionCurveLinear;
//
//        default:
//            return kNilOptions;
//    }
//}
//
//- (void)layoutAndAnimateMessageInputTextView:(UITextView *)textView
//{
//    CGFloat maxHeight = [JSMessageInputView maxHeight];
//
//    BOOL isShrinking = textView.contentSize.height < self.previousTextViewContentHeight;
//    CGFloat changeInHeight = textView.contentSize.height - self.previousTextViewContentHeight;
//
//    if (!isShrinking && (self.previousTextViewContentHeight == maxHeight || textView.text.length == 0)) {
//        changeInHeight = 0;
//    }
//    else {
//        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
//    }
//
//    if (changeInHeight != 0.0f) {
//        [UIView animateWithDuration:0.25f
//                         animations:^{
//                             [self setTableViewInsetsWithBottomValue:_chatViewController.tableView.contentInset.bottom + changeInHeight];
//
//                             [self scrollToBottomAnimated:NO];
//
//                             if (isShrinking) {
//                                 // if shrinking the view, animate text view frame BEFORE input view frame
//                                 [_chatViewController.inputWithBoardView adjustTextViewHeightBy:changeInHeight];
//                             }
//
//                             CGRect inputViewFrame = _chatViewController.inputWithBoardView.frame;
//                             _chatViewController.inputWithBoardView.frame = CGRectMake(0.0f,
//                                     inputViewFrame.origin.y - changeInHeight,
//                                     inputViewFrame.size.width,
//                                     inputViewFrame.size.height + changeInHeight);
//
//                             if (!isShrinking) {
//                                 // growing the view, animate the text view frame AFTER input view frame
//                                 [_chatViewController.inputWithBoardView adjustTextViewHeightBy:changeInHeight];
//                             }
//                         }
//                         completion:^(BOOL finished) {
//                         }];
//
//        self.previousTextViewContentHeight = MIN(textView.contentSize.height, maxHeight);
//    }
//
//    // Once we reached the max height, we have to consider the bottom offset for the text view.
//    // To make visible the last line, again we have to set the content offset.
//    if (self.previousTextViewContentHeight == maxHeight) {
//        double delayInSeconds = 0.01;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime,
//                dispatch_get_main_queue(),
//                ^(void) {
//                    CGPoint bottomOffset = CGPointMake(0.0f, textView.contentSize.height - textView.bounds.size.height);
//                    [textView setContentOffset:bottomOffset animated:YES];
//                });
//    }
//}
//
//- (void)scrollToBottomAnimated:(BOOL)animated
//{
//    if (_chatViewController.isUserScrolling)
//        return;
//
//    NSInteger rows = [_chatViewController.tableView numberOfRowsInSection:0];
//
//    if (rows > 0)
//    {
//        [_chatViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
//                          atScrollPosition:UITableViewScrollPositionBottom
//                                  animated:animated];
//    }
//}
//
//- (void)viewWillAppear
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(handleWillShowKeyboardNotification:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(handleWillHideKeyboardNotification:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
//
//    [_chatViewController.messageInputView.textView addObserver:self
//                                 forKeyPath:@"contentSize"
//                                    options:NSKeyValueObservingOptionNew
//                                    context:nil];
//
////    [self scrollToBottomAnimated:NO];
//}
//
//- (void)pullDownInputBoard
//{
//    [_chatViewController.inputWithBoardView resignFirstResponder];
//    [self setTableViewInsetsWithBottomValue:_chatViewController.messageInputView.frame.size.height];
//}
//
//- (void)viewWillDisappear
//{
//
//    [_chatViewController.messageInputView resignFirstResponder];
////    [self setEditing:NO animated:YES];
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
//
//    [_chatViewController.messageInputView.textView removeObserver:self forKeyPath:@"contentSize"];
//
//    [[EBRecorderPlayer sharedInstance] stopPlaying];
//}
//
//
//#pragma mark - Key-value observing
//
//- (void)observeValueForKeyPath:(NSString *)keyPath
//                      ofObject:(id)object
//                        change:(NSDictionary *)change
//                       context:(void *)context
//{
//    if (object == _chatViewController.messageInputView.textView && [keyPath isEqualToString:@"contentSize"]) {
//        [self layoutAndAnimateMessageInputTextView:object];
//    }
//}
//
//#pragma mark - Text view delegate
//
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    if([text isEqualToString:@""])
//    {
//        [_chatViewController.inputWithBoardView backspacePressed];
//        return NO;
//    }
//
//    if ([text isEqualToString:@"\n"])
//    {
//        [_chatViewController.inputWithBoardView sendPressed];
//        return NO;
//    }
//    return YES;
//}
//
//- (void)textViewDidBeginEditing:(UITextView *)textView
//{
//    [textView becomeFirstResponder];
//
//    if (!self.previousTextViewContentHeight)
//    {
//        self.previousTextViewContentHeight = textView.contentSize.height;
//    }
//
//    [self scrollToBottomAnimated:YES];
//}
//
//- (void)textViewDidChange:(UITextView *)textView
//{
//    [_chatViewController.inputWithBoardView textChanged];
//}
//
//- (void)textViewDidEndEditing:(UITextView *)textView
//{
//    [textView resignFirstResponder];
//}
//
//
//#pragma mark - Dismissive text view delegate
//- (void)keyboardDidShow
//{
//
//}
//
//- (void)keyboardDidScrollToPoint:(CGPoint)point
//{
//    CGRect inputViewFrame = _chatViewController.inputWithBoardView.frame;
//    CGPoint keyboardOrigin = [_chatViewController.view convertPoint:point fromView:nil];
//    inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height;
//    _chatViewController.inputWithBoardView.frame = inputViewFrame;
//}
//
//- (void)keyboardWillBeDismissed
//{
//    if (!_chatViewController.inputWithBoardView.anyBoardVisible)
//    {
//        CGRect inputViewFrame = _chatViewController.inputWithBoardView.frame;
//        inputViewFrame.origin.y = _chatViewController.view.bounds.size.height - _chatViewController.messageInputView.frame.size.height;
//        _chatViewController.inputWithBoardView.frame = inputViewFrame;
//    }
//}
//
///**
// *  Tells the delegate that the keyboard origin is about to move back to the specified point.
// *
// *  @param point The new origin of the keyboard's frame after it has completed animation.
// */
//- (void)keyboardWillSnapBackToPoint:(CGPoint)point
//{
//
//}

@end