//
// Created by 何 义 on 14-4-1.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "UIImageView+WebCache.h"
#import "AFNetworkReachabilityManager.h"
#import "EBContentImageView.h"
#import "EBIMMessage.h"
#import "EBController.h"
#import "EBStyle.h"
#import "EBBubbleMessageCell.h"

@implementation EBContentImageView

- (id)init
{
    self = [super init];
    if (self)
    {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_imageView];
    }
    return self;
}

+ (CGSize)neededContentSize:(EBIMMessage *)message
{
    NSDictionary *content = message.content;
    NSString *url = content[@"url"];
    if (!url)
    {
        url = content[@"local"];
    }
    if ([[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:url] || [[SDImageCache sharedImageCache] diskImageExistsWithKey:url])
    {
        return [self realContentSize:message];
    }
    else
    {
        return CGSizeMake(65, 48);
    }
}

+ (CGSize)realContentSize:(EBIMMessage *)message
{
    NSDictionary *content = message.content;

    CGFloat width = [content[@"width"] floatValue];
    CGFloat height = [content[@"height"] floatValue];

    CGFloat targetWidth = MIN(114, width);
    targetWidth = MAX(targetWidth, 40);

    CGFloat targetHeight = targetWidth / width  * height;

    targetHeight = MAX(40, targetHeight);

    return CGSizeMake(targetWidth, targetHeight);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.frame = self.bounds;
}

- (void)updateContent:(EBIMMessage*)message
{
   [super updateContent:message];
   NSDictionary *content = message.content;

   NSString *url = content[@"url"];
   if (!url)
   {
       url = content[@"local"];
   }
   if (url)
   {
       __weak UIImageView *weakImageView = _imageView;
       __weak EBContentImageView *weakSelf = self;
       _imageView.contentMode = UIViewContentModeCenter;
       [_imageView sd_setImageWithURL:[[NSURL alloc] initWithString:url] placeholderImage:[UIImage imageNamed:@"im_image_pl"]
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
       {
           if (image == nil && error == nil && cacheType == SDImageCacheTypeNone && [AFNetworkReachabilityManager sharedManager].reachable)
           {
               UILabel *label = (UILabel *)[weakImageView viewWithTag:88];
               if (label == nil)
               {
                   label = [[UILabel alloc] initWithFrame:CGRectMake(0, weakImageView.frame.size.height - 10,
                           weakImageView.frame.size.width, 12)];
                   label.tag = 88;
                   label.textAlignment = NSTextAlignmentCenter;
                   label.font = [UIFont systemFontOfSize:10.0];
                   label.textColor = [EBStyle grayTextColor];
                   label.backgroundColor = [UIColor clearColor];
                   [weakImageView addSubview:label];
                   [weakImageView bringSubviewToFront:label];
               }

               label.text = NSLocalizedString(@"tap_to_download", nil);
           }
           else if (image && !error && weakSelf)
           {
             [weakSelf adjustImageSize];
             weakImageView.clipsToBounds = YES;
             weakImageView.contentMode = UIViewContentModeScaleAspectFill;
             [weakImageView setNeedsLayout];
//              weakImageView.hidden = YES;
           }
           
//           [[SDImageCache sharedImageCache] clearMemory];
       }];
   }
}

- (void)adjustImageSize
{
    CGSize contentSize = [EBContentImageView realContentSize:self.message];
    CGSize nBSize = [EBBubbleView bubbleSizeWithContentSize:contentSize];

    if (self.message.bubbleSize.height != nBSize.height
            || self.message.bubbleSize.width != nBSize.width)
    {
        self.message.bubbleSize = nBSize;
        self.message.contentHeight = [EBBubbleMessageCell contentHeightForMessage:self.message];

        dispatch_main_sync_safe(^(){
           [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_IM_BUBBLE_SIZE_CHANGED object:nil]];
        });
    }
}

- (void)handleTapEvent
{
    UILabel *hintLabel = (UILabel *)[_imageView viewWithTag:88];
    if (hintLabel)
    {
        if ([hintLabel.text isEqualToString:NSLocalizedString(@"tap_to_download", nil)])
        {
            hintLabel.text = NSLocalizedString(@"image_downloading", nil);
            __weak UIImageView *weakImageView = _imageView;
            __weak EBContentImageView *weakSelf = self;
            NSString *imageUrl = self.message.content[@"url"];
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[[NSURL alloc] initWithString:imageUrl]
                                                                  options:nil progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
            {
                if (image && finished)
                {
                    [[SDImageCache sharedImageCache] storeImage:image recalculateFromImage:NO imageData:data forKey:imageUrl toDisk:YES];
                    if (weakImageView && weakSelf)
                    {
                        [hintLabel removeFromSuperview];
                        [weakSelf adjustImageSize];
                    }
                    
//                    [[SDImageCache sharedImageCache] clearMemory];
                }
            }];
        }
    }
    else
    {
        [[EBController sharedInstance] viewImagesFromMsg:self.message.id inConversation:self.message.cvsnId];
    }
}

- (NSString *)toPasteboard
{
    return @"[图片]";
}
@end
