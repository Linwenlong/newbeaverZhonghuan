//
// Created by 何 义 on 14-4-30.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "RDLabel.h"
#define kNumberOfLines 4
#define ellipsis @"..."

@implementation RDLabel {
    NSString *string;
}

#pragma Public Methods

- (void)setTruncatingText:(NSString *) txt
{
    [self setTruncatingText:txt forNumberOfLines:kNumberOfLines];
}

- (void)setTruncatingText:(NSString *) txt forNumberOfLines:(int) lines
{
    string = txt;
    self.numberOfLines = 0;
    NSMutableString *truncatedString = [txt mutableCopy];
    if ([self numberOfLinesNeeded:truncatedString] > lines)
    {
        [truncatedString appendString:ellipsis];
        NSRange range = NSMakeRange(truncatedString.length - (ellipsis.length + 1), 1);
        while ([self numberOfLinesNeeded:truncatedString] > lines)
        {
            [truncatedString deleteCharactersInRange:range];
            range.location--;
        }
        [truncatedString deleteCharactersInRange:range];  //need to delete one more to make it fit
        CGRect labelFrame = self.frame;
        labelFrame.size.height = [@"A" sizeWithFont:self.font].height * lines;
        self.frame = labelFrame;
        self.text = truncatedString;
//        self.userInteractionEnabled = YES;
//        UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expand:)];
//        [self addGestureRecognizer:tapper];
    }
    else
    {
        CGRect labelFrame = self.frame;
        labelFrame.size.height = [@"A" sizeWithFont:self.font].height * lines;
        self.frame = labelFrame;
        self.text = txt;
    }
}

#pragma Private Methods

-(int)numberOfLinesNeeded:(NSString *) s
{
    float oneLineHeight = [@"A" sizeWithFont:self.font].height;
    float totalHeight = [s sizeWithFont:self.font constrainedToSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
    return nearbyint(totalHeight/oneLineHeight);
}

-(void)expand:(UITapGestureRecognizer *) tapper
{
    int linesNeeded = [self numberOfLinesNeeded:string];
    CGRect labelFrame = self.frame;
    labelFrame.size.height = [@"A" sizeWithFont:self.font].height * linesNeeded;
    self.frame = labelFrame;
    self.text = string;
}

@end