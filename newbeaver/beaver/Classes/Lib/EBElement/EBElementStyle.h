//
//  EBElementStyle.h
//  MyQuickDialog
//
//  Created by LiuLian on 7/22/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#define FontSizeDefault 12

@interface EBElementStyle : NSObject <NSCopying>

//Element style attrs
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *fontColor;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) BOOL underline;
@property (nonatomic) BOOL merge;
@property (nonatomic) BOOL newline;

//InputElement style attrs
@property (nonatomic, strong) UIFont *prefixFont;
@property (nonatomic, strong) UIColor *prefixFontColor;
@property (nonatomic, strong) UIFont *suffixFont;
@property (nonatomic, strong) UIColor *suffixFontColor;

@property (nonatomic) UIEdgeInsets padding;

+ (EBElementStyle *)defaultStyle;
@end
