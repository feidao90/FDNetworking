//
//  NSString+ReplaceSpace.h
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/28.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ReplaceSpace)

//去除掉首尾的空白字符 && 换行字符替换为 ','
+ (NSString *)replaceSpaceAndReturnString:(NSString *)input;

//去除掉首尾的空白字符
+ (NSString *)replaceSpaceReturnString:(NSString *)input;
@end
