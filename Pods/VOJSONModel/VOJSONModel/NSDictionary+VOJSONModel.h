//
//  NSDictionary+VOJSONModel.h
//  Test
//
//  Created by 何广忠 on 2017/12/14.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (VOJSONModel)

/*!
 将JSON转过来的一个字典中的每一个key都转换成相应类型的model对象，不支持嵌套
 转换过程为:
 {key1:{},key2:{}} ===> {key1:m1,key2:m2}
 
 当然每一个key所对应的value转换后的model类型须为同一个类型
 */
- (NSDictionary *)modelDictionaryWithClass:(Class)modelClass;

- (NSDictionary *)toJSONDictionary;
@end
