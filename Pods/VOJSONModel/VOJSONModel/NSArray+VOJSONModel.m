//
//  NSArray+VOJSONModel.m
//  Test
//
//  Created by 何广忠 on 2017/12/14.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "NSArray+VOJSONModel.h"
#import "VOJSONModel.h"

@implementation NSArray (VOJSONModel)

- (NSArray *)modelArrayWithClass:(Class)modelClass{
    NSMutableArray *modelArray = [NSMutableArray array];
    for (id object in self) {
        if ([object isKindOfClass:[NSArray class]]) {
            NSArray *subModelArray = [object modelArrayWithClass:modelClass];
            if (subModelArray) {
                [modelArray addObject:subModelArray];
            }
        }else if ([object isKindOfClass:[NSDictionary class]]){
            id model = [[modelClass alloc] initWithJSONDictionary:object];
            if (model) {
                [modelArray addObject:model];
            }
        }else{
            [modelArray addObject:object];
        }
    }
    return modelArray;
}


- (NSArray *)toJSONArray{
    NSMutableArray *jsonArray = [NSMutableArray array];
    
    for (id object in self) {
        if ([object isKindOfClass:[VOJSONModel class]]) {
            NSDictionary *objectDict = [(VOJSONModel *)object toJSONDictionary];
            if (objectDict) {
                [jsonArray addObject:objectDict];
            }
        }else if ([object isKindOfClass:[NSArray class]]){
            NSArray *subJSONArray = [object toJSONArray];
            if (subJSONArray) {
                [jsonArray addObject:subJSONArray];
            }
        }else{
            [jsonArray addObject:object];
        }
    }
    
    return jsonArray;
}
@end
