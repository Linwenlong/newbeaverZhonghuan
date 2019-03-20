//
//  EBInputView.h
//  MyQuickDialog
//
//  Created by LiuLian on 7/22/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#import "EBPrefixView.h"

@class EBInputView;

@protocol EBInputViewDelegate <EBElementViewDelegate>

- (void)inputViewDidBeginEditing:(EBInputView *)inputView;

@end

@interface EBInputView : EBPrefixView

@property (nonatomic, weak) UIToolbar *toolbar;
@property (nonatomic, strong) UITextField *inputTextField;
- (void)setInputView:(UIView *)view;
- (void)showInView:(UIView *)view;
@end
