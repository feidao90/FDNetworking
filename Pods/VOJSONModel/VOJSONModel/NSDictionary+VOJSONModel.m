//
//  NSDictionary+VOJSONModel.m
//  Test
//
//  Created by 何广忠 on 2017/12/14.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "NSDictionary+VOJSONModel.h"
#import "VOJSONModel.h"
#import "NSArray+VOJSONModel.h"

@implementation NSDictionary (VOJSONModel)

- (NSDictionary *)modelDictionaryWithClass:(Class)modelClass{
    NSMutableDictionary *modelDictionary = [NSMutableDictionary dictionary];
    for (NSString *key in self) {
        id object = [self objectForKey:key];
        
        if (object) {
            if ([object isKindOfClass:[NSDictionary class]]) {
                [modelDictionary setObject:[[modelClass alloc] initWithJSONDictionary:object] forKey:key];
            }else if ([object isKindOfClass:[NSArray class]]){
                [modelDictionary setObject:[object modelArrayWithClass:modelClass] forKey:key];
            }else{
                [modelDictionary setObject:object forKey:key];
            }
        }
    }
    return modelDictionary;
}

- (NSDictionary *)toJSONDictionary{
    NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionary];
    for (NSString *key in self) {
        id object = [self objectForKey:key];
        
        if (object) {
            if ([object isKindOfClass:[VOJSONModel class]]) {
                [jsonDictionary setObject:[(VOJSONModel *)object toJSONDictionary] forKey:key];
            }else if ([object isKindOfClass:[NSArray class]]){
                [jsonDictionary setObject:[(NSArray *)object toJSONArray] forKey:key];
            }else{
                [jsonDictionary setObject:object forKey:key];
            }
        }
    }
    return jsonDictionary;
}

@end
