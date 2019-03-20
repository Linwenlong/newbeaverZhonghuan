//
// Created by 何 义 on 14-4-30.
// Copyright (c) 2014 eall. All rights reserved.
//


@interface RDLabel : UILabel

- (void)setTruncatingText:(NSString *) txt;
- (void)setTruncatingText:(NSString *) txt forNumberOfLines:(int) lines;

@end