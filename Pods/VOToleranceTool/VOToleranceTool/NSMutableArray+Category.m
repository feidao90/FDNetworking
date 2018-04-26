//
//  NSMutableArray+Category.m
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/7.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "NSMutableArray+Category.h"

@implementation NSMutableArray (Category)
- (void)safeSetObject:(id)obj atIndexedSubscript:(NSUInteger)idx
{
    if (obj == nil) {
        return ;
    }
    
    if (self.count < idx) {
        return ;
    }
    
    if (idx == self.count) {
        [self addObject:obj];
    } else {
        [self replaceObjectAtIndex:idx withObject:obj];
    }
}

- (void)safeAddObject:(id)object
{
    if (object == nil) {
        return;
    } else {
        [self addObject:object];
    }
}

- (void)safeInsertObject:(id)object atIndex:(NSUInteger)index
{
    if (object == nil) {
        return;
    } else if (index > self.count) {
        return;
    } else {
        [self insertObject:object atIndex:index];
    }
}

- (void)safeInsertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexs
{
    NSUInteger firstIndex = indexs.firstIndex;
    if (indexs == nil) {
        return;
    } else if (indexs.count!=objects.count || firstIndex>objects.count) {
        return;
    } else {
        [self insertObjects:objects atIndexes:indexs];
    }
}

- (void)safeRemoveObjectAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
        return;
    } else {
        [self removeObjectAtIndex:index];
    }
}

- (void)safeRemoveObjectsInRange:(NSRange)range
{
    NSUInteger location = range.location;
    NSUInteger length = range.length;
    if (location + length > self.count) {
        return;
    } else {
        [self removeObjectsInRange:range];
    }
}
@end
