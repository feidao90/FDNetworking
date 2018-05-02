//
//  VOJSONModelKeyMapper.m
//  Test
//
//  Created by 何广忠 on 2017/12/14.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "VOJSONModelKeyMapper.h"

@interface VOJSONModelKeyMapper()
@property(strong,nonatomic) NSMutableDictionary *jsonToModelMap;
@property(strong,nonatomic) NSMutableDictionary *modelToJsonMap;
@end

@implementation VOJSONModelKeyMapper

- (id)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    if (self != nil) {
        self.jsonToModelMap = [[NSMutableDictionary alloc] initWithDictionary:dict];
        self.modelToJsonMap = [[NSMutableDictionary alloc] initWithCapacity:[dict count]];
        for (NSString *key in dict) {
            self.modelToJsonMap[dict[key]] = key;
        }
    }
    return self;
}


- (NSString *)modelKeyMappedFromJsonKey:(NSString *)jsonKey{
    NSString *mapped =  [self.jsonToModelMap objectForKey:jsonKey];
    return mapped ? mapped : jsonKey;
}

- (NSString *)jsonKeyMappedFromModelKey:(NSString *)modelKey{
    NSString *mapped = [self.modelToJsonMap objectForKey:modelKey];
    return mapped ? mapped : modelKey;
}

@end
