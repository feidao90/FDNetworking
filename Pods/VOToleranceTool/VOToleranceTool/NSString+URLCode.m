//
//  NSString+URLCode.m
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/11.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "NSString+URLCode.h"

@implementation NSString (URLCode)
+(NSString*)encodeString:(NSString*)unencodedString{
    NSString *encodeURL = [unencodedString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return encodeURL;
}

+ (NSString*)decodeString:(NSString*)encodedString
{
    NSString *decodeURL = [encodedString stringByRemovingPercentEncoding];
    return decodeURL;
}
@end
