//
// Created by 何 义 on 14-5-31.
// Copyright (c) 2014 eall. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "EBHttpClient.h"

typedef void(^TMapHandlerBlock)(id request, BOOL success, id result);

@interface EBHttpClient (BMapAPI)

- (id)mapRequest:(NSDictionary *)parameters poiSearch:(TMapHandlerBlock)handler;
- (id)mapRequest:(NSDictionary *)parameters reGeocode:(TMapHandlerBlock)handler;

@end