//
//  VOJSONModelKeyMapper.h
//  Test
//
//  Created by 何广忠 on 2017/12/14.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VOJSONModelKeyMapper : NSObject

//映射字典自身的key为json的字段名，value为model的属性名
- (id)initWithDictionary:(NSDictionary *)dict;

- (NSString *)modelKeyMappedFromJsonKey:(NSString *)jsonKey;
- (NSString *)jsonKeyMappedFromModelKey:(NSString *)modelKey;
@end
