//
//  NSString+DateString.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/18.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DateString)
/*
 一天以内：HH:mm
 超过一天：MM-dd
 超过一年：yyyy-MM-dd
 */
+ (NSString *)formatterYearTime:(NSString *)createTime;
/*
 一天以内：HH:mm
 超过一天：MM/dd
 超过一年：yyyy/MM/dd
 */
+ (NSString *)formatterMonthTime:(NSString *)createTime;
/*
 yyyy-MM-dd HH:mm
 */
+ (NSString *)formatterAllTime:(NSString *)createTime;
/*
 input : 20180202
 yyyy年MM月dd号
 */
+ (NSString *)formatterChineseTime:(NSString *)createTime;

/*
 exa：yyyy/MM/dd HH:mm
 */
+ (NSString *)formatterAllTimeTT:(NSString *)createTime;

/*
 yyyy年MM月dd号
 */
+ (NSString *)formatterHanYuTime:(NSString *)createTime;
@end
