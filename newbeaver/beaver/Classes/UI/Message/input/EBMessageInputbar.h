//
//  ECMessageInputbar.h
//  chowAgent
//
//  Created by LiuLian on 11/6/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EBMessageTextView, EBRecordingButton;

@interface EBMessageInputbar : UIToolbar

@property (nonatomic, strong) EBMessageTextView *textView;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *faceButton;
@property (nonatomic, strong) UIButton *audioButton;
@property (nonatomic, strong) EBRecordingButton *recordingButton;

@property (nonatomic) UIEdgeInsets contentInset;

@end
