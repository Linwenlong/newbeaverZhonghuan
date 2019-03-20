//
//  main.m
//  beaver
//
//  Created by 何 义 on 14-2-17.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "AppDelegate.h"
#import "NSNumber+AvoidMTLModelCrash.h"
#import "NSString+AvoidMTLModelCrash.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        [NSNumber avoidMTLModelCrash];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

