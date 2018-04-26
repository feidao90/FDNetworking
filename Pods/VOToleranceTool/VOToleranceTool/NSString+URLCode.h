//
//  NSString+URLCode.h
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/11.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLCode)

+(NSString*)encodeString:(NSString*)unencodedString;
+ (NSString*)decodeString:(NSString*)encodedString;
@end
