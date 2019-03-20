//
//  ScannerView.m
//  qrcode
//
//  Created by 何 义 on 13-10-20.
//  Copyright (c) 2013年 crazyant. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <sys/ucred.h>
#import "QRScannerView.h"
#import "ZXQRCodeReader.h"
#import "ZXHybridBinarizer.h"
#import "ZXBinaryBitmap.h"
#import "ZXCGImageLuminanceSource.h"
#import "ZXResult.h"

#define HINT_FRAME_GAP 17
#define SCAN_FRAME_SIZE 252
#define CROP_SIZE 256
#define SCAN_VIEW_SIZE 235
#define HINT_LABEL_HEIGHT 21
#define INDICATOR_VIEW_SIZE 40.0f
#define TAG_INDICATOR_VIEW 99
#define SCAN_LINE_HEIGHT 10

@interface QRScannerView()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    UIView *_scanningView;
    UIImageView *_lineView;
    UIView *_loadingView;
    CGFloat _scanFrameOffsetY;
    ZXQRCodeReader *_decoder;
    BOOL _showingHint;
}

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *prevLayer;

@end

@implementation QRScannerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _scanFrameOffsetY = self.frame.size.height > 480 ? 85 : 55;
        [self showLoadingView];
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)start
{
    if (!self.session)
    {
        _decoder = [[ZXQRCodeReader alloc] init];
        [self startCaptureDevice];
    }
    else if (![self.session isRunning])
    {
        [self.session startRunning];
    }

    [self showScanningView];
    [self hideLoadingView];
    [self startLineAnimation];
    _needDecoding = YES;
}

-(void) codeInvalid
{
    [self showHint:NSLocalizedString(@"qr_not_supported", nil) duration:3.0];
}

-(void)showHint:(NSString *)hint duration:(NSTimeInterval)duration
{
    UILabel *label = (UILabel *)[_errorHint viewWithTag:99];
    label.backgroundColor = [UIColor clearColor];
    label.text = hint;

    if (_showingHint)
    {
        return;
    }
    else
    {
        _showingHint = YES;
        _errorHint.layer.opacity = 1;
        [UIView animateWithDuration:duration animations:^
        {
            _errorHint.layer.opacity = 0;
        } completion:^(BOOL finished)
        {
            _showingHint = NO;
        }];
    }
}

- (void)stop
{
    [self showLoadingView];
    [self hideScanningView];
    if ([self.session isRunning])
    {
        [self.session stopRunning];
    }
}

- (void)showLoadingView
{
    if (_loadingView == nil)
    {
        [self buildLoadingView];
    }
    if (_loadingView.superview == nil)
    {
        [self addSubview:_loadingView];
    }

    UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[_loadingView viewWithTag:TAG_INDICATOR_VIEW];
    [indicatorView startAnimating];
    [self bringSubviewToFront:_loadingView];
    [_loadingView setHidden:NO];
}

- (void)hideLoadingView
{
    UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[_loadingView viewWithTag:TAG_INDICATOR_VIEW];
    [indicatorView stopAnimating];

    [_loadingView setHidden:YES];
}

- (void)showScanningView
{
    if (_scanningView == nil)
    {
        [self buildScanningView];
    }
    if (_scanningView.superview == nil)
    {
        [self addSubview:_scanningView];
    }

    [_scanningView setHidden:NO];
    _scanningView.layer.zPosition = 99;
}

- (void)hideScanningView
{
    [_scanningView setHidden:YES];
}

- (void)buildScanningView
{
    CGFloat viewWidth = self.frame.size.width;
    _scanningView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, viewWidth, self.frame.size.height)];
    _scanningView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];

    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _scanFrameOffsetY - HINT_FRAME_GAP -
            HINT_LABEL_HEIGHT, viewWidth, HINT_LABEL_HEIGHT)];
    hintLabel.backgroundColor = [UIColor clearColor];
    hintLabel.font = [UIFont systemFontOfSize:14.0];
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.text = NSLocalizedString(@"scanning_hint", nil);
    hintLabel.textColor = [UIColor whiteColor];
    [_scanningView addSubview:hintLabel];

    UIView *frameView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"scan_frame"] resizableImageWithCapInsets:UIEdgeInsetsMake(34, 34, 34, 34)]];
    frameView.frame = CGRectMake((viewWidth - SCAN_FRAME_SIZE)/2, _scanFrameOffsetY, SCAN_FRAME_SIZE, SCAN_FRAME_SIZE);
    [_scanningView addSubview:frameView];

    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake((viewWidth - SCAN_FRAME_SIZE) / 2,
            _scanFrameOffsetY + SCAN_FRAME_SIZE, SCAN_FRAME_SIZE, 110.0)];
    descLabel.backgroundColor = [UIColor clearColor];
    descLabel.font = [UIFont systemFontOfSize:12.0];
    descLabel.numberOfLines = 0;
    descLabel.text = NSLocalizedString(@"scanning_desc", nil);
    descLabel.textColor = [UIColor grayColor];
    [_scanningView addSubview:descLabel];

    [self addErrorHintView:_scanFrameOffsetY + SCAN_FRAME_SIZE / 2];

    _scanningView.layer.mask = [self buildMaskLayer];

    CGFloat gap = (SCAN_FRAME_SIZE - SCAN_VIEW_SIZE) / 2;
//        _lineView = [[UIView alloc] initWithFrame:CGRectMake((viewWidth - SCAN_FRAME_SIZE)/2 + gap, _lineCenter, SCAN_VIEW_SIZE, SCAN_LINE_HEIGHT)];
    _lineView = [[UIImageView alloc] initWithFrame:CGRectMake((viewWidth - SCAN_VIEW_SIZE) / 2, _scanFrameOffsetY + gap, SCAN_VIEW_SIZE, SCAN_LINE_HEIGHT)];
    _lineView.image = [[UIImage imageNamed:@"qr_scan_line"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 69, 0, 69)
                                                                           resizingMode:UIImageResizingModeTile];
    _lineView.hidden = YES;
    _lineView.layer.zPosition = 100;
    [self addSubview:_lineView];
}

- (void)addErrorHintView:(CGFloat)yOffset
{
    _errorHint = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"bg_note"]
            stretchableImageWithLeftCapWidth:7 topCapHeight:20]];
    _errorHint.contentMode = UIViewContentModeScaleToFill;
    _errorHint.frame = CGRectMake(60, yOffset, [UIScreen mainScreen].bounds.size.width -120, 22);
    _errorHint.layer.zPosition = 99;
    [self addSubview:_errorHint];

    UILabel *label = [[UILabel alloc] initWithFrame:_errorHint.bounds];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = 99;
    label.textColor = [UIColor colorWithRed:155/255.0 green:140/255.0 blue:55/255.0 alpha:1.0];
    [_errorHint addSubview:label];

    _errorHint.layer.opacity = 0;
}

- (void)startLineAnimation
{
    _lineView.hidden = NO;

    [UIView animateWithDuration:2.0 animations:^
    {
        _lineView.frame = CGRectMake(_lineView.frame.origin.x, _scanFrameOffsetY + (SCAN_FRAME_SIZE - SCAN_VIEW_SIZE) / 2 + 225,
                _lineView.frame.size.width, _lineView.frame.size.height);
    } completion:^(BOOL finished){
        if (finished)
        {
            _lineView.frame = CGRectMake(_lineView.frame.origin.x,
                    _scanFrameOffsetY + (SCAN_FRAME_SIZE - SCAN_VIEW_SIZE) / 2,
                    _lineView.frame.size.width, _lineView.frame.size.height);
            [self startLineAnimation];
        }
    }];
}

- (CALayer *)buildMaskLayer
{
    CGFloat viewWidth = self.frame.size.width;
    CGFloat viewHeight = self.frame.size.height;
    CGFloat xMargin =  (viewWidth - SCAN_VIEW_SIZE) / 2;
    CGFloat gap = (SCAN_FRAME_SIZE - SCAN_VIEW_SIZE) / 2;

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;

    CGMutablePathRef rectPath = CGPathCreateMutable();

    CGRect* rects = malloc(sizeof(CGRect) * 4);
    rects[0] = CGRectMake(0.0, 0.0, xMargin, viewHeight);
    rects[1] = CGRectMake(xMargin, 0.0, SCAN_VIEW_SIZE, _scanFrameOffsetY + gap);
    rects[2] = CGRectMake(xMargin, _scanFrameOffsetY + gap + SCAN_VIEW_SIZE, SCAN_VIEW_SIZE,
            viewHeight - (_scanFrameOffsetY + gap + SCAN_VIEW_SIZE));
    rects[3] = CGRectMake(xMargin + SCAN_VIEW_SIZE, 0.0, xMargin, viewHeight);

    CGPathAddRects(rectPath, NULL, rects, 4);

    free(rects);

    maskLayer.path = rectPath;
    CGPathRelease(rectPath);

    return maskLayer;
}

- (void)buildLoadingView
{
    CGFloat viewWidth = self.frame.size.width;
    _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, viewWidth, self.frame.size.height)];
    _loadingView.backgroundColor = [UIColor blackColor];

    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicatorView.frame = CGRectMake((viewWidth - INDICATOR_VIEW_SIZE)/2, _scanFrameOffsetY, INDICATOR_VIEW_SIZE, INDICATOR_VIEW_SIZE);
    indicatorView.tag = TAG_INDICATOR_VIEW;
    [_loadingView addSubview:indicatorView];

    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _scanFrameOffsetY + INDICATOR_VIEW_SIZE + 10, viewWidth, HINT_LABEL_HEIGHT)];
    hintLabel.font = [UIFont systemFontOfSize:14.0];
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.text = NSLocalizedString(@"scanning_loading", nil);
    hintLabel.textColor = [UIColor whiteColor];
    hintLabel.backgroundColor = [UIColor clearColor];
    [_loadingView addSubview:hintLabel];
}

- (void)processZXResult:(ZXResult*)result
{
    self.resultBlock(result.text);
}

- (void)dealloc
{
}

#pragma capture device

- (void)startCaptureDevice
{
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (captureDevice)
    {
        NSError *error = nil;
        AVCaptureDeviceInput *captureInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
        if (!error)
        {
            _session = [[AVCaptureSession alloc] init];
            if ([_session canAddInput:captureInput])
            {
                [_session addInput:captureInput];

                AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
                output.alwaysDiscardsLateVideoFrames = YES;
                [output setVideoSettings:@{(NSString*)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)}];
//                [output setVideoSettings:@{(NSString*)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_16Gray)}];
                [output setSampleBufferDelegate:self queue:dispatch_queue_create("com.eall.captureQueue", NULL)];
                if ([_session canAddOutput:output])
                {
                    [_session addOutput:output];
                    _prevLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
                    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                    _prevLayer.frame = self.bounds;

                    [self.layer addSublayer:_prevLayer];

                    NSError *error;
                    if ([captureDevice lockForConfiguration:&error])
                    {
                        if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
                        {
                            captureDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
                        }
                        else if ([captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus])
                        {
                            captureDevice.focusMode = AVCaptureFocusModeAutoFocus;
                        }
                        [captureDevice unlockForConfiguration];
                    }

                    _session.sessionPreset = AVCaptureSessionPresetMedium;
                    [_session startRunning];
                }
            }
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool {
        if (_needDecoding)
        {
            CVImageBufferRef videoFrame = CMSampleBufferGetImageBuffer(sampleBuffer);

//            size_t width = CVPixelBufferGetWidth(videoFrame);
            size_t height = CVPixelBufferGetHeight(videoFrame);

            size_t top = (320 - CROP_SIZE) / 2 * height / 320;
            size_t left = _scanFrameOffsetY / 320 * height;

            size_t imageWidth = CROP_SIZE * height / 320;

            CGImageRef videoFrameImage = [ZXCGImageLuminanceSource createImageFromBuffer:videoFrame left:left top:top width:imageWidth height:imageWidth];
//            CGImageRef videoFrameImage = [ZXCGImageLuminanceSource createImageFromBuffer:videoFrame];

//            _needDecoding = NO;
//            UIImage *image = [[UIImage alloc] initWithCGImage:videoFrameImage];
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

//            return;

            CGImageRef rotatedImage = [self createRotatedImage:videoFrameImage degrees:90.0];
            CGImageRelease(videoFrameImage);

            ZXCGImageLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:rotatedImage];
            CGImageRelease(rotatedImage);

            ZXHybridBinarizer *binarizer = [[ZXHybridBinarizer alloc] initWithSource:source];
            ZXBinaryBitmap *bitmap = [[ZXBinaryBitmap alloc] initWithBinarizer:binarizer];

//            ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
//            ZXDecodeHints *hints = [ZXDecodeHints hints];
            NSError *error;
            ZXResult *result = [_decoder decode:bitmap error:&error];
            if (result)
            {
                dispatch_async(dispatch_get_main_queue(),
                ^{
                    [self processZXResult:result];
                });
            }
        }
    }
}

- (CGImageRef)createRotatedImage:(CGImageRef)original degrees:(float)degrees CF_RETURNS_RETAINED
{
    if (degrees == 0.0f)
    {
        CGImageRetain(original);
        return original;
    }
    else
    {
        double radians = degrees * M_PI / 180;

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
        radians = -1 * radians;
#endif

        size_t _width = CGImageGetWidth(original);
        size_t _height = CGImageGetHeight(original);

        CGRect imgRect = CGRectMake(0, 0, _width, _height);
        CGAffineTransform __transform = CGAffineTransformMakeRotation(radians);
        CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, __transform);

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL,
                rotatedRect.size.width,
                rotatedRect.size.height,
                CGImageGetBitsPerComponent(original),
                0,
                colorSpace,
                kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst);
        CGContextSetAllowsAntialiasing(context, FALSE);
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        CGColorSpaceRelease(colorSpace);

        CGContextTranslateCTM(context,
                +(rotatedRect.size.width/2),
                +(rotatedRect.size.height/2));
        CGContextRotateCTM(context, radians);

        CGContextDrawImage(context, CGRectMake(-imgRect.size.width/2,
                -imgRect.size.height/2,
                imgRect.size.width,
                imgRect.size.height),
                original);

        CGImageRef rotatedImage = CGBitmapContextCreateImage(context);
        CFRelease(context);

        return rotatedImage;
    }
}

@end
