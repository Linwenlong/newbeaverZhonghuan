//
// Created by 何 义 on 14-4-1.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBContentTextView.h"
#import "EBIMMessage.h"
#import "EBStyle.h"
#import "EBCache.h"
#import "NIAttributedLabel.h"
#import "EBController.h"
#import "RegexKitLite.h"
#import "NewHouseWebViewController.h"

#define EB_CONTENT_TEXT_FONT_SIZE  16.0

@interface EBContentTextView()<NIAttributedLabelDelegate>
{
   NIAttributedLabel *_attributedLabel;
}
@end

@implementation EBContentTextView

- (id)init
{
    self = [super init];
    if (self)
    {
       self.backgroundColor = [UIColor clearColor];
       _attributedLabel = [[NIAttributedLabel alloc] init];
       _attributedLabel.font = [UIFont systemFontOfSize:EB_CONTENT_TEXT_FONT_SIZE];
       _attributedLabel.textColor = [EBStyle blackTextColor];
       _attributedLabel.backgroundColor = [UIColor clearColor];
       _attributedLabel.numberOfLines = 0;
        _attributedLabel.lineSpace = 4.0;
       _attributedLabel.autoDetectLinks = YES;
       _attributedLabel.dataDetectorTypes = NSTextCheckingTypePhoneNumber | NSTextCheckingTypeLink;
       _attributedLabel.delegate = self;
       [self addSubview:_attributedLabel];
    }
    return self;
}

+ (CGSize)neededContentSize:(EBIMMessage *)message
{
    NSMutableString *oText = [message.content[@"text"] mutableCopy];
    NSDictionary *emojiDic = [[EBCache sharedInstance] emojiValueMap];
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    NSArray *array_emoji = [oText componentsMatchedByRegex:regex_emoji];

    NIAttributedLabel *attributedLabel = [[NIAttributedLabel alloc] init];
    attributedLabel.font = [UIFont systemFontOfSize:EB_CONTENT_TEXT_FONT_SIZE];
    attributedLabel.numberOfLines = 0;
    attributedLabel.autoDetectLinks = YES;
    attributedLabel.lineSpace = 4.0;
    if ([array_emoji count])
    {
        NSMutableArray *emojiCArray = [[NSMutableArray alloc] init];
        NSRange lastRange = NSMakeRange(0, 0);
        for (NSString *str in array_emoji)
        {
            NSString *emojiValue = [emojiDic objectForKey:str];
            if (emojiValue)
            {
                NSRange range = [oText rangeOfString:str];
                UIImage *emojiImage = [UIImage imageNamed:[NSString stringWithFormat:@"emotion.bundle/%@", emojiValue]];
                if (range.location != lastRange.location && emojiCArray.count)
                {
                    for (UIImage *image in emojiCArray)
                    {
                        [attributedLabel insertImage:image atIndex:lastRange.location];
                    }
                    [emojiCArray removeAllObjects];
                }

                [emojiCArray insertObject:emojiImage atIndex:0];
                lastRange = range;
                [oText deleteCharactersInRange:range];
            }
        }
        for (UIImage *image in emojiCArray)
        {
            [attributedLabel insertImage:image atIndex:lastRange.location];
        }

        message.emojiImagesArray = attributedLabel.images;
        if (oText.length == 0)
        {
            [oText appendString:@" "];
        }
    }

    message.convertedString = oText;
    attributedLabel.text =  message.convertedString;
    attributedLabel.images = message.emojiImagesArray;

    return [attributedLabel sizeThatFits:CGSizeMake(190, CGFLOAT_MAX)];
}

- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point
{
    NSURL *url = result.URL;
    if (result.resultType == NSTextCheckingTypePhoneNumber)
    {
        url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"tel:%@", result.phoneNumber]];
    }
    [[EBController sharedInstance] openURL:url];
}

- (BOOL)attributedLabel:(NIAttributedLabel *)attributedLabel shouldPresentActionSheet:(UIActionSheet *)actionSheet
        withTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point
{
    return NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _attributedLabel.frame = self.bounds;
}

- (void)updateContent:(EBIMMessage*)message
{
    [super updateContent:message];

    _attributedLabel.text = self.message.convertedString;
    _attributedLabel.images = self.message.emojiImagesArray;

    [self setNeedsLayout];
}

- (NSString *)toPasteboard
{
    return self.message.content[@"text"];
}

- (void)handleTapEvent
{
    if (self.message.type == EMessageContentTypeLink)
    {
        NewHouseWebViewController *viewController = [[NewHouseWebViewController alloc] init];
        viewController.requestURL = self.message.content[@"url"];
        [[[EBController sharedInstance] currentNavigationController] pushViewController:viewController animated:YES];
//        [[EBController sharedInstance] openWebViewWithUrl:[[NSURL alloc] initWithString:self.message.content[@"url"]]];
    }
}
@end