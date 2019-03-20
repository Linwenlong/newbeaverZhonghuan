//
//  EBPrefixView.m
//  MyQuickDialog
//
//  Created by LiuLian on 7/24/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#import "EBPrefixView.h"
#import "EBPrefixElement.h"
#import "EBElementStyle.h"

@implementation EBPrefixView
@synthesize preLabel, sufLabel, sufImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)drawView
{
    EBPrefixElement *presufElement;
    EBElementStyle *style;
    if (!self.element) {
        presufElement = [EBPrefixElement new];
    } else {
        presufElement = (EBPrefixElement *)self.element;
    }
    if (!self.style) {
        style = [EBElementStyle new];
        style.fontSize = FontSizeDefault;
        style.font = [UIFont systemFontOfSize:style.fontSize];
        style.fontColor = [UIColor darkTextColor];
        style.prefixFont = style.suffixFont = style.font;
        style.prefixFontColor = style.suffixFontColor = style.fontColor;
        self.style = style;
    } else {
        style = self.style;
    }
    
    [super drawView];
    
    CGFloat dx = self.requiredLabel ? self.requiredLabel.frame.size.width : 0, dy = 0;
    
    CGFloat prefixWidth, suffixImgWidth, suffixWidth;
    prefixWidth = suffixImgWidth = suffixWidth = 0;
    
    if (presufElement.prefix && presufElement.prefix.length > 0) {
        CGSize size = [self actualSize:presufElement.prefix constrainedToSize:CGSizeMake(1000, self.frame.size.height) font:style.prefixFont];
        if (style.padding.left == 0 || size.width > style.padding.left) {
            prefixWidth = size.width + 10;
        } else {
            prefixWidth = style.padding.left;
        }
//        prefixWidth = style.padding.left == 0 ? [self actualSize:presufElement.prefix constrainedToSize:CGSizeMake(1000, self.frame.size.height) font:style.prefixFont].width + 10 : style.padding.left;// 10 point gap
        preLabel = [[UILabel alloc] initWithFrame:CGRectOffset(CGRectMake(0, 0, prefixWidth, self.frame.size.height), dx, dy)];
        preLabel.text = presufElement.prefix;
        preLabel.font = style.prefixFont;
        preLabel.textColor = style.prefixFontColor;
//        preLabel.layer.borderWidth = 1.0;
//        preLabel.layer.borderColor  = [UIColor blueColor].CGColor;
        [self addSubview:preLabel];
    }
    
    if (presufElement.suffixImg) {
        CGFloat imgH = style.font.lineHeight;
        suffixImgWidth = presufElement.suffixImg.size.width*imgH/presufElement.suffixImg.size.height + 10;// 10 point gap
        sufImageView = [[UIImageView alloc] initWithImage:presufElement.suffixImg];
        sufImageView.frame = CGRectMake(self.frame.size.width-suffixImgWidth, self.frame.size.height/2-imgH/2, suffixImgWidth, imgH);
        sufImageView.contentMode = UIViewContentModeLeft;
        [self addSubview:sufImageView];
    }
    
    if (presufElement.suffix) {
        suffixWidth = [self actualSize:presufElement.suffix constrainedToSize:CGSizeMake(1000, self.frame.size.height) font:style.suffixFont].width + 10;// 10 point gap
        sufLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-suffixWidth-suffixImgWidth, 0, suffixWidth, self.frame.size.height)];
        sufLabel.text = presufElement.suffix;
        sufLabel.font = style.suffixFont;
        sufLabel.textColor = style.suffixFontColor;
        sufLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:sufLabel];
    }
    
}

- (CGRect)contentFrame
{
    CGFloat requiredWidth, prefixWidth, suffixImgWidth, suffixWidth;
    requiredWidth = prefixWidth = suffixImgWidth = suffixWidth = 0;
    
    requiredWidth = self.requiredLabel ? self.requiredLabel.frame.size.width : 0;
    prefixWidth = preLabel ? self.preLabel.frame.size.width : 0;
    suffixImgWidth = sufImageView ? sufImageView.frame.size.width : 0;
    suffixWidth = sufLabel ? sufLabel.frame.size.width : 0;
//    CGFloat marginLeft = self.style.padding.left == 0 ? requiredWidth + prefixWidth : self.style.padding.left;
    CGFloat marginLeft = requiredWidth + prefixWidth;
    CGFloat marginRight = self.style.padding.right == 0 ? suffixWidth + suffixImgWidth : self.style.padding.right;
    return CGRectMake(marginLeft, 0, self.frame.size.width-marginLeft-marginRight, self.frame.size.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat left = self.requiredLabel ? self.requiredLabel.frame.size.width : 0;
    if (preLabel) {
        preLabel.frame = CGRectMake(left, 0, preLabel.frame.size.width, self.frame.size.height);
    }
    if (sufImageView) {
        sufImageView.frame = CGRectMake(self.frame.size.width-sufImageView.frame.size.width, 0, sufImageView.frame.size.width, self.frame.size.height);
    }
    CGFloat sufImgWidth = sufImageView ? sufImageView.frame.size.width : 0;
    if (sufLabel) {
        sufLabel.frame = CGRectMake(self.frame.size.width-sufImgWidth-sufLabel.frame.size.width, 0, sufLabel.frame.size.width, self.frame.size.height);
    }
}

- (NSString *)valueOfView
{
    return [[(EBPrefixElement *)self.element text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)setValueOfView:(id)value
{
    
}

- (void)enableView:(BOOL)enable
{
    [super enableView:enable];
}

- (void)onSelect:(id)sender
{
    [super onSelect:sender];
}

@end
