//
//  EBTextareaView.h
//  MyQuickDialog
//
//  Created by LiuLian on 7/23/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#import "EBElementView.h"

@class EBTextareaView;

@protocol EBTextareaViewDelegate <EBElementViewDelegate>

- (void)textareaViewDidBeginEditing:(EBTextareaView *)textareaView;

@end

@interface EBTextareaView : EBElementView

@property (nonatomic, weak) UIToolbar *toolbar;

- (void)showInView:(UIView *)view;

@end
