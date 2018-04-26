//
//  NSString+ReplaceSpace.m
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/28.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "NSString+ReplaceSpace.h"

@implementation NSString (ReplaceSpace)

//去除掉首尾的空白字符 && 换行字符替换为 ','
+ (NSString *)replaceSpaceAndReturnString:(NSString *)input
{
    input = [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    input = [input stringByReplacingOccurrencesOfString:@"\r" withString:@","];
    return [input stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

+ (NSString *)replaceSpaceReturnString:(NSString *)input
{
    input = [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [input stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}
@end
