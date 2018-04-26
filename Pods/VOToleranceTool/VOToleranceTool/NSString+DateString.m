//
//  NSString+DateString.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/18.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "NSString+DateString.h"

@implementation NSString (DateString)
+ (NSString *)formatterYearTime:(NSString *)createTime
{
    NSDate *changeDate = [NSDate dateWithTimeIntervalSince1970:[createTime integerValue]/1000.];
    NSDateFormatter *changeFormatter = [NSDateFormatter new];
    if ([NSString isToday:changeDate])
    {
        [changeFormatter setDateFormat:@"HH:mm"];
    }else if([NSString isCurrentYear:changeDate])
    {
        [changeFormatter setDateFormat:@"MM-dd"];
    }
    else
    {
        [changeFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    NSString *changeTimeString = [changeFormatter stringFromDate:changeDate];
    return changeTimeString;
}

+ (NSString *)formatterMonthTime:(NSString *)createTime
{
    NSDate *changeDate = [NSDate dateWithTimeIntervalSince1970:[createTime integerValue]/1000.];
    NSDateFormatter *changeFormatter = [NSDateFormatter new];
    if ([NSString isToday:changeDate])
    {
        [changeFormatter setDateFormat:@"HH:mm"];
    }else if([NSString isCurrentYear:changeDate])
    {
        [changeFormatter setDateFormat:@"MM/dd"];
    }else
    {
        [changeFormatter setDateFormat:@"yyyy/MM/dd"];
    }
    NSString *changeTimeString = [changeFormatter stringFromDate:changeDate];
    return changeTimeString;
}

+ (NSString *)formatterAllTime:(NSString *)createTime
{
    NSDate *changeDate = [NSDate dateWithTimeIntervalSince1970:[createTime integerValue]/1000.];
    NSDateFormatter *changeFormatter = [NSDateFormatter new];
    [changeFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *changeTimeString = [changeFormatter stringFromDate:changeDate];
    return changeTimeString;
}

+ (NSString *)formatterChineseTime:(NSString *)createTime
{
    NSMutableString *temp = [NSMutableString stringWithString:createTime];
    [temp insertString:@"年" atIndex:4];
    [temp insertString:@"月" atIndex:7];
    [temp insertString:@"日" atIndex:10];
    return temp;
}

+ (NSString *)formatterAllTimeTT:(NSString *)createTime
{
    NSDate *changeDate = [NSDate dateWithTimeIntervalSince1970:[createTime integerValue]/1000.];
    NSDateFormatter *changeFormatter = [NSDateFormatter new];
    [changeFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSString *changeTimeString = [changeFormatter stringFromDate:changeDate];
    return changeTimeString;
}

+ (NSString *)formatterHanYuTime:(NSString *)createTime
{
    NSDate *changeDate = [NSDate dateWithTimeIntervalSince1970:[createTime integerValue]/1000.];
    NSDateFormatter *changeFormatter = [NSDateFormatter new];
    [changeFormatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *changeTimeString = [changeFormatter stringFromDate:changeDate];
    return changeTimeString;
}

#pragma mark - privite method
//是否为今天
+ (BOOL)isToday:(NSDate *)date
{
    //now: 2015-09-05 11:23:00
    //self 调用这个方法的对象本身
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear ;
    
    //1.获得当前时间的 年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    //2.获得date
    NSDateComponents *selfCmps = [calendar components:unit fromDate:date];
    
    return (selfCmps.year == nowCmps.year) && (selfCmps.month == nowCmps.month) && (selfCmps.day == nowCmps.day);
}
//是否今年
+ (BOOL)isCurrentYear:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear ;
    
    //1.获得当前时间的 年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    //2.获得date
    NSDateComponents *selfCmps = [calendar components:unit fromDate:date];
    
    return (selfCmps.year == nowCmps.year);
}
@end
