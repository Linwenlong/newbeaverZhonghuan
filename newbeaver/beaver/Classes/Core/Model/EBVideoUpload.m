//
//  EBVideoUpload.m
//  beaver
//
//  Created by LiuLian on 8/13/15.
//  Copyright (c) 2015 eall. All rights reserved.
//

#import "EBVideoUpload.h"
#import "EBVideoUtil.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation EBVideoUpload

- (NSString *)name
{
    if (!_name) {
        NSURL *videoURL = self.tmpURL;
        _name = [EBVideoUtil fileNameWithURL:videoURL];
    }
    return _name;
}

- (NSUInteger)size
{
    if (_size == 0) {
        NSURL *videoURL = self.tmpURL;
        _size = [EBVideoUtil fileSizeWithURL:videoURL];
    }
    return _size;
}

- (NSString *)type
{
    if (!_type) {
        NSURL *videoURL = self.tmpURL;
        _type = [EBVideoUtil fileTypeWithURL:videoURL];
    }
    return _type;
}

- (NSString *)sha1
{
    if (!_sha1) {
        NSURL *videoURL = self.tmpURL;
        _sha1 = [EBVideoUtil sha1WithURL:videoURL];
    }
    return _sha1;
}

- (CGFloat)progress
{
    return _offset / (CGFloat)self.size;
}

- (NSURL *)tmpURL
{
    if (!_tmpURL) {
        if (_asset) {
            _tmpURL = [NSURL URLWithString:[EBVideoUtil saveToDocument:_asset]];
        }
    }
    return _tmpURL;
}

@end
