//
// Created by 何 义 on 14-4-23.
// Copyright (c) 2014 eall. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface EBCompatibility : NSObject

+ (void)setupGlobalAppearance;
+ (void)configAppearanceForSearchBar:(UISearchBar *)searchBar;
+ (BOOL)isIOS7Higher;

@end