//
// Created by 何 义 on 14-3-26.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBCrypt.h"
#import "EBHouse.h"
#import "EBClient.h"
#import "EBFilter.h"
#import "Base64.h"

#define ENCRYPT_KEY  @"45CAFB28"
#define CODE_LENGTH  96
#define PAIR_LENGTH  48


@implementation EBCrypt

+(NSString *)encryptHouse:(EBHouse *)house
{
    NSString *toEncode = [NSString stringWithFormat:@"house#%@#%@", [EBFilter typeString:house.rentalState], house.id];
    toEncode = [self string:toEncode growToLength:PAIR_LENGTH];
    toEncode = [self stringToHex:toEncode];

    NSString *encrypted = [NSString stringWithFormat:@"%@%@",
                    [self encode:[toEncode substringToIndex:PAIR_LENGTH]],
                    [self encode:[toEncode substringFromIndex:PAIR_LENGTH]]];

    return encrypted;
}

+(NSString *)encryptClient:(EBClient *)client
{
    NSString *toEncode = [NSString stringWithFormat:@"client#%@#%@", [EBFilter typeString:client.rentalState], client.id];
    toEncode = [self string:toEncode growToLength:PAIR_LENGTH];
    toEncode = [self stringToHex:toEncode];
    NSString *encrypted = [NSString stringWithFormat:@"%@%@",
                    [self encode:[toEncode substringToIndex:PAIR_LENGTH]],
                    [self encode:[toEncode substringFromIndex:PAIR_LENGTH]]];

   return encrypted;
}

+(NSString *)string:(NSString*)source growToLength:(NSInteger)length
{
    static NSString *pool = @"#1uirlfhjfd3p4a5s6d7f8HnfdlNljkfdLklfDlfdpasjk";

    if (source.length >= length)
    {
        return source;
    }

    NSInteger lengthToAdd = length - source.length;
    for (NSInteger i = 0; i < lengthToAdd; i++)
    {
        source = [source stringByAppendingString:[pool substringWithRange:NSMakeRange(i, 1)]];
    }

    return source;
}

+(NSString *)encryptText:(NSString *)code
{
    NSString *toEncode = [self string:code growToLength:PAIR_LENGTH];
    toEncode = [self stringToHex:toEncode];

    NSString *encrypted = [NSString stringWithFormat:@"%@%@",
                                                     [self encode:[toEncode substringToIndex:PAIR_LENGTH]],
                                                     [self encode:[toEncode substringFromIndex:PAIR_LENGTH]]];

    return encrypted;
}

+(NSString *)decryptText:(NSString *)text
{
    NSString *decrypted = [NSString stringWithFormat:@"%@%@", [self decode:[text substringToIndex:48]],
                                                     [self decode:[text substringFromIndex:48]]];
    return [self stringFromHex:decrypted];
}

+ (NSArray *)decrypt:(NSString *)code
{
   if ([self isValidCode:code])
   {
       NSString *decrypted = [NSString stringWithFormat:@"%@%@", [self decode:[code substringToIndex:48]],
                                                        [self decode:[code substringFromIndex:48]]];
       decrypted = [self stringFromHex:decrypted];
       NSArray *results = [decrypted componentsSeparatedByString:@"#"];
       if (results.count >= 3)
       {
           return results;
       }
       return nil;
   }

   return nil;
}

+ (BOOL)isValidCode:(NSString *)code
{
    NSString *regex = @"^[0-9A-Fa-f]{96,96}$";
    NSError *error=nil;
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:&error];

    return [pattern numberOfMatchesInString:code options:0 range:NSMakeRange(0, code.length)] == 1;
}

+ (NSString *)encode:(NSString *)code
{
    NSString *key = ENCRYPT_KEY;
    NSInteger i = 0;
    NSString *src1=@"", *src2=@"", *src3=@"", *source=@"";
    for (i = 0; i <= 15; i++)
    {
        src1 = [src1 stringByAppendingString:[code substringWithRange:NSMakeRange(i * 3, 1)]];
        src2 = [src2 stringByAppendingString:[code substringWithRange:NSMakeRange(i * 3 + 1, 1)]];
        src3 = [src3 stringByAppendingString:[code substringWithRange:NSMakeRange(i * 3 + 2, 1)]];
    }

    source = [NSString stringWithFormat:@"%@%@%@", src1, src2, src3];

    unichar *tmpByte = [self stringToByte:source];
    unichar *tmpKey = [self stringToByte:key];

    unichar *tmpDes = [self allocMemory:PAIR_LENGTH / 2];

    for (i = 0; i < PAIR_LENGTH / 2; i++)
    {
        if ((tmpByte[i] + tmpKey[i % 4]) > 255)
        {
            tmpDes[i] = tmpByte[i] - 256 + tmpKey[i % 4];
        }
        else
        {
            tmpDes[i] = tmpByte[i] + tmpKey[i % 4];
        }
    }

    NSString *retStr = [self byteToStr:tmpDes length:PAIR_LENGTH / 2];

    free(tmpDes);
    free(tmpKey);
    free(tmpByte);

    return retStr;
}

+ (NSString *)decode:(NSString *)code
{
    NSString *key = ENCRYPT_KEY;

    unichar *tmpKey = [self stringToByte:key];
    unichar *tmpCode = [self stringToByte:code];
    unichar *tmpDes = [self allocMemory:PAIR_LENGTH / 2];

    NSInteger tmpCodeLength = code.length / 2;
    for (int i = 0; i < tmpCodeLength; i++)
    {
        if (tmpCode[i] - tmpKey[i % 4] < 0)
        {
            tmpDes[i] = tmpCode[i] + 256 - tmpKey[i % 4];
        }
        else
        {
            tmpDes[i] = tmpCode[i] - tmpKey[i % 4];
        }
    }

    NSString *des = [self byteToStr:tmpDes length:tmpCodeLength];
    NSString *des1 = [des substringWithRange:NSMakeRange(0, 16)];
    NSString *des2 = [des substringWithRange:NSMakeRange(16, 16)];
    NSString *des3 = [des substringWithRange:NSMakeRange(32, 16)];

    des = @"";
    for (int i = 0; i < 16; i++)
    {
        des = [des stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",
                        [des1 substringWithRange:NSMakeRange(i, 1)],
                        [des2 substringWithRange:NSMakeRange(i, 1)],
                        [des3 substringWithRange:NSMakeRange(i, 1)]]];
    }

    free(tmpKey);
    free(tmpCode);
    free(tmpDes);

    return des;
}
//
+ (NSString *) stringFromHex:(NSString *)str
{
    NSMutableData *stringData = [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [str length] / 2; i++)
    {
        byte_chars[0] = (char)[str characterAtIndex:i*2];
        byte_chars[1] = (char)[str characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [stringData appendBytes:&whole_byte length:1];
    }

    return [[NSString alloc] initWithData:stringData encoding:NSASCIIStringEncoding];
}

+ (NSString *) stringToHex:(NSString *)str
{
    NSMutableString *result = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < str.length; i++)
    {
        unichar chr = [str characterAtIndex:i];
        [result appendFormat:@"%02X", chr];
    }

    return result;
}

+ (unichar *)stringToByte:(NSString *)str
{
    NSInteger length = str.length / 2;
    unichar *result = [self allocMemory:length];

    for (NSInteger i = 0; i < length; i++)
    {
        NSString *part = [str substringWithRange:NSMakeRange(i * 2, 2)];
        result[i] = (unichar) strtoul([part UTF8String], 0, 16) & 0xFF;
    }

    return result;
}

+ (NSString *)byteToStr:(unichar *)unichars length:(NSInteger)length
{
    NSMutableString *result = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < length; i++)
    {
        unichar chr = unichars[i];
        [result appendFormat:@"%02X", chr];
    }

    return result;
}

+ (unichar*)allocMemory:(NSInteger)length
{
    unichar *pMem = malloc((length + 1) * sizeof(unichar));
    memset(pMem, 0, length * sizeof(unichar));
    return pMem;
}
//+(NSString *)encryptByTranslate:(NSString *)str
//{
//
//}

@end