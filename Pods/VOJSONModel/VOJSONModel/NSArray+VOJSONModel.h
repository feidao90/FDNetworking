//
//  NSArray+VOJSONModel.h
//  Test
//
//  Created by 何广忠 on 2017/12/14.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (VOJSONModel)

/*!
 将JSON转过来的一个数组转换成相应的model类型的数组，支持多级内嵌的模式
 简单的形式，字典的数组转换成model的数组:
 [{},{},{}] ===> [m1,m2,m3]
 
 也可能是nested的数组
 [[{},{}],[{},{}],[{}]] ===> [[m1,m2],[m3,m4],[m5]]
 
 从上面也可以看出局限性，就是数组或者内嵌数组中的元素转换后的目标model类型必须是同种类型
 */
- (NSArray *)modelArrayWithClass:(Class)modelClass;

- (NSArray *)toJSONArray;
@end
