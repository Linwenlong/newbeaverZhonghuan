/*
 * Copyright (c) 2012 Mario Negro Martín
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
 */

#import "EBProgressBar.h"

/**
 * Constant that defines indeterminate progress
 */


@implementation EBProgressBar
{
    UIView *_backgroundView;

    /**
     * Progress image view
     */
    UIView *_progressView;

    /**
     * Value of the progress. Takes values between 0.0f and 1.0f.
     * It can also takes ProgressBarViewIndeterminateProgress
     */
    CGFloat _progress;
}

@synthesize progress = _progress;

#pragma mark -
#pragma mark Instance initialization

/*
 * Creates and initializes an instance of EBProgressBar
 */
- (id)initWithFrame:(CGRect)frame
{
    
    if (self = [super initWithFrame:frame])
    {
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];

        _backgroundView.layer.cornerRadius = 2.0f;
        _backgroundView.backgroundColor = [UIColor colorWithRed:225.0f/255.0f green:226.0f/255.0f blue:229.0f/255.0f alpha:1.0];
        [self addSubview:_backgroundView];
        
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, frame.size.height)];
        _progressView.layer.cornerRadius = 2.0f;
        _progressView.backgroundColor = [UIColor colorWithRed:123.0f/255.0f green:204.0f/255.0f blue:71.0f/255.0f alpha:1.0];
        [self addSubview:_progressView];
        
        self.progress = 0.0f;
    }
         
    return self;
}

#pragma mark -
#pragma mark Properties

/**
 * Set the progress of the bar
 *
 * @param progress Value of the current progress
 */
- (void)setProgress:(CGFloat)progress {
    
    if (_progress != progress)
    {
      if (progress >= 0.0f && progress <= 1.0f)
      {
            
            CGRect frame = _progressView.frame;
            frame.origin.x = 0.0f;
            frame.origin.y = 0.0f;
            frame.size.height = CGRectGetHeight(_backgroundView.frame);
            frame.size.width = CGRectGetWidth(_backgroundView.frame) * progress;
            _progressView.frame = frame;
            
//            [UIView animateWithDuration:1.0 animations:^{
//
//                CGRect frame = _progressView.frame;
//                frame.size.width = CGRectGetWidth(_backgroundView.frame) * progress;
//                _progressView.frame = frame;
//            }];
        }
        
        _progress = progress;
    } 
}

@end
