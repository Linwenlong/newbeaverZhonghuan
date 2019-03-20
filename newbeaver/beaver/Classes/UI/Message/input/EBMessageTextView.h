//
//  ECMessageTextView.h
//  chowAgent
//
//  Created by LiuLian on 11/6/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const MessageTextViewContentSizeDidChangeNotification;

@interface EBMessageTextView : UITextView

/** The maximum number of lines before enabling scrolling. Default is 0 wich means limitless. */
@property (nonatomic, readwrite) NSUInteger maxNumberOfLines;

/** The current displayed number of lines. */
@property (nonatomic, readonly) NSUInteger numberOfLines;

/** YES if the text view is and can still expand it self, depending if the maximum number of lines are reached. */
@property (nonatomic, readonly) BOOL isExpanding;

@end
