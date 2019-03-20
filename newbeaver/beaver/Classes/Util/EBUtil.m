//
//  EBUtil.m
//  beaver
//
//  Created by ChenYing on 15/11/13.
//  Copyright © 2015年 eall. All rights reserved.
//

#import "EBUtil.h"

@implementation EBUtil

+ (CLLocationCoordinate2D)bd_encrypt:(CLLocationCoordinate2D)coordinate
{
    double x = coordinate.longitude, y = coordinate.latitude;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * M_PI);
    double theta = atan2(y, x) + 0.000003 * cos(x * M_PI);
    
    CLLocationCoordinate2D tempCoordinate = CLLocationCoordinate2DMake(z * sin(theta) + 0.006, z * cos(theta) + 0.0065);
    
    return tempCoordinate;
}

@end
