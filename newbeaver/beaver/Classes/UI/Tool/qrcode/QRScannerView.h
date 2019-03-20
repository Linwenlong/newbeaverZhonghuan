//
//  ScannerView.h
//  qrcode
//
//  Created by 何 义 on 13-10-20.
//  Copyright (c) 2013年 crazyant. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ScanResultBlock)(NSString *code);
//typedef void(^PickPhotoBlock)(void);

@interface QRScannerView : UIView

@property(nonatomic, copy) ScanResultBlock resultBlock;
@property(nonatomic, copy) UIView *errorHint;
@property(nonatomic, assign) BOOL needDecoding;

//@property(nonatomic, copy) PickPhotoBlock pickPhotoBlock;

-(void) start;
-(void) stop;
-(void) codeInvalid;
-(void) showHint:(NSString *)hint duration:(NSTimeInterval)duration;


//- (void) scanImage:(UIImage*)image completion:(void (^)(BOOL hasCode))completion;

@end
