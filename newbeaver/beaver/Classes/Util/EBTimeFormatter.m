//
// Created by 何 义 on 14-4-15.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBTimeFormatter.h"
#import "NSDate-Utilities.h"


@implementation EBTimeFormatter

+ (NSString *) formatMessageTime:(NSInteger)time
{
    static NSDateFormatter *formatter = nil;
    if (formatter == nil)
    {
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    }

   NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
   if ([date isToday])
   {
       formatter.dateFormat = @"a hh:mm";
   }
   else if ([date isYesterday])
   {
       formatter.dateFormat = [NSString stringWithFormat:@"%@ a hh:mm", NSLocalizedString(@"Yesterday", nil)];
   }
   else if ([date daysBeforeDate:NSDate.date] < 7)
   {
       formatter.dateFormat = @"EEEE";
       NSString *currentWeek = [formatter stringFromDate:NSDate.date];
       if ([[formatter stringFromDate:date] isEqualToString:currentWeek]) {
           formatter.dateFormat = @"yyyy-MM-dd a hh:mm:ss";
       }
       else{
           formatter.dateFormat = @"EEEE a hh:mm";
       }
   }
   else
   {
      formatter.dateFormat = @"yyyy-MM-dd a hh:mm:ss";
   }

   return [formatter stringFromDate:date];
}

+ (NSString *) formatAppointmentTime:(NSInteger)time
{
    static NSDateFormatter *formatter = nil;
    if (formatter == nil)
    {
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    }

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    formatter.dateFormat = NSLocalizedString(@"appointment_time_format", nil);

    return [formatter stringFromDate:date];
}

+ (NSString *) formatAppointmentTimeToClient:(NSInteger)time
{
    static NSDateFormatter *formatter = nil;
    if (formatter == nil)
    {
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    }

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    formatter.dateFormat = time % 3600 ? NSLocalizedString(@"appointment_time_format_to_client_1", nil)
            : NSLocalizedString(@"appointment_time_format_to_client_2", nil);

    return [formatter stringFromDate:date];
}

+ (NSString *) formatConversationTime:(NSInteger)time
{
    static NSDateFormatter *formatter = nil;
    if (formatter == nil)
    {
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    }

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    if ([date isToday])
    {
        formatter.dateFormat = @"a hh:mm";
    }
    else if ([date isYesterday])
    {
        return NSLocalizedString(@"Yesterday", nil);
    }
    else if ([date daysBeforeDate:NSDate.date] < 7)
    {
        formatter.dateFormat = @"EEEE";
        NSString *currentWeek = [formatter stringFromDate:NSDate.date];
        if ([[formatter stringFromDate:date] isEqualToString:currentWeek]) {
            formatter.dateFormat = @"yy-M-d";
        }
    }
    else
    {
        formatter.dateFormat = @"yy-M-d";
    }

    return [formatter stringFromDate:date];
}

+ (NSString *) formatRentExpirationTime:(NSInteger)time
{
    static NSDateFormatter *formatter = nil;
    if (formatter == nil)
    {
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    formatter.dateFormat = NSLocalizedString(@"rent_expiration_time_format", nil);
    
    return [formatter stringFromDate:date];
}

@end