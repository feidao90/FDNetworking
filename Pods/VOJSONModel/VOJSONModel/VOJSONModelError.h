//
//  VOJSONModelError.h
//  Test
//
//  Created by 何广忠 on 2017/12/14.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const VOJSONModelErrorDomain;

typedef NS_ENUM(int, VOJSONModelErrorCode) {
    VOJSONModelErrorCodeNilInput = 1,
    VOJSONModelErrorCodeDataInvalid = 2
};

@interface VOJSONModelError : NSError

+ (id)errorNilInput;
+ (id)errorDataInvalidWithDescription:(NSString *)description;
@end
