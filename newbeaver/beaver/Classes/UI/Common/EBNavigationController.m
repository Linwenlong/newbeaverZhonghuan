//
// Created by 何 义 on 14-4-16.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBNavigationController.h"
#import "BaseViewController.h"

@interface UINavigationController (EBNavigationController)

- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

@implementation EBNavigationController {
    BOOL _shouldIgnorePushingViewControllers;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    if([self.viewControllers count] < [navigationBar.items count])
    {
        return YES;
    }

    UIViewController* vc = [self topViewController];

    BOOL shouldPop = YES;
    if([vc isKindOfClass:[BaseViewController class]] &&
            [vc respondsToSelector:@selector(shouldPopOnBack)])
    {
        BaseViewController *bv = (BaseViewController *)vc;
        shouldPop = [bv shouldPopOnBack];
    }

    if(shouldPop)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    }
    else
    {
        for(UIView *subview in [navigationBar subviews])
        {
            if(subview.alpha < 1.)
            {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.;
                }];
            }
        }
    }

    return NO;
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!_shouldIgnorePushingViewControllers)
    {
        [super pushViewController:viewController animated:animated];
    }

    _shouldIgnorePushingViewControllers = YES;
}

#pragma mark - Private API

// This is confirmed to be App Store safe.
// If you feel uncomfortable to use Private API, you could also use the delegate method navigationController:didShowViewController:animated:.
- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super didShowViewController:viewController animated:animated];
    _shouldIgnorePushingViewControllers = NO;
}

#pragma mark - ratation
-(BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];
}

@end