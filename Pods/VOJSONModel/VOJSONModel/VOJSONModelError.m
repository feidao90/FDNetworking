//
//  VOJSONModelError.m
//  Test
//
//  Created by 何广忠 on 2017/12/14.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "VOJSONModelError.h"

NSString * const VOJSONModelErrorDomain = @"TBJSONModelErrorDomain";
@implementation VOJSONModelError

+ (VOJSONModelError *)errorNilInput{
    return [VOJSONModelError errorWithDomain:VOJSONModelErrorDomain code:VOJSONModelErrorCodeNilInput userInfo:@{NSLocalizedDescriptionKey: @"用于创建TBJSONModel的参数为nil"}];
}

+ (VOJSONModelError *)errorDataInvalidWithDescription:(NSString *)description{
    return [VOJSONModelError errorWithDomain:VOJSONModelErrorDomain code:VOJSONModelErrorCodeDataInvalid userInfo:@{NSLocalizedDescriptionKey: description}];
}
@end
