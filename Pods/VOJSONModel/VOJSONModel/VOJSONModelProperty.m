//
//  VOJSONModelProperty.m
//  Test
//
//  Created by 何广忠 on 2017/12/14.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "VOJSONModelProperty.h"

#define TypeIndicator @"T"
#define ReadonlyIndicator @"R"

static NSDictionary *encodedTypesMap = nil;

@implementation VOJSONModelProperty

+ (NSDictionary *)encodedTypesMap{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        encodedTypesMap = @{@"c":@1, @"i":@2, @"s":@3, @"l":@4, @"q":@5,
                            @"C":@6, @"I":@7, @"S":@8, @"L":@9, @"Q":@10,
                            @"f":@11,@"d":@12,@"B":@13,@"v":@14,@"*":@15,
                            @"@":@16,@"#":@17,@":":@18,@"[":@19,@"{":@20,
                            @"(":@21,@"b":@22,@"^":@23,@"?":@24};
    });
    return encodedTypesMap;
}

+ (instancetype)propertyWithName:(NSString *)name typeString:(NSString *)typeString{
    VOJSONModelProperty *property = [self new];
    property->_name = name;
    
    NSArray *typeStringComponents = [typeString componentsSeparatedByString:@","];
    //解析类型信息
    if ([typeStringComponents count] > 0) {
        //类型信息肯定是放在最前面的且以“T”打头
        NSString *typeInfo = [typeStringComponents objectAtIndex:0];
        
        NSScanner *scanner = [NSScanner scannerWithString:typeInfo];
        [scanner scanUpToString:TypeIndicator intoString:NULL];
        [scanner scanString:TypeIndicator intoString:NULL];
        NSUInteger scanLocation = scanner.scanLocation;
        if ([typeInfo length] > scanLocation) {
            NSString *typeCode = [typeInfo substringWithRange:NSMakeRange(scanLocation, 1)];
            NSNumber *indexNumber = [[self encodedTypesMap] objectForKey:typeCode];
            property->_valueType = (VOJSONModelPropertyValueType)[indexNumber integerValue];
            
            //当当前的类型为对象的时候，解析出对象对应的类型的相关信息
            //T@"NSArray<VOMyModel>"
            if (property->_valueType == VOClassPropertyTypeObject) {
                scanner.scanLocation += 1;
                if ([scanner scanString:@"\"" intoString:NULL]) {
                    NSString *objectClassName = nil;
                    [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet]
                                        intoString:&objectClassName];
                    property->_typeName = objectClassName;
                    property->_objectClass = NSClassFromString(objectClassName);
                    
                    NSMutableArray *protocols = [NSMutableArray array];
                    while ([scanner scanString:@"<" intoString:NULL]) {
                        NSString* protocolName = nil;
                        [scanner scanUpToString:@">" intoString: &protocolName];
                        if (protocolName != nil) {
                            [protocols addObject:protocolName];
                        }
                        [scanner scanString:@">" intoString:NULL];
                    }
                    if ([protocols count] > 0) {
                        property->_objectProtocols = protocols;
                        id lastProtocol = [protocols lastObject];
                        if ([lastProtocol isKindOfClass:[NSString class]]) {
                            property->_containerElementClass = NSClassFromString(lastProtocol);
                        }
                    }
                }
            }
        }
        
        //检查是否包含只读属性
        if ([typeStringComponents containsObject:ReadonlyIndicator]) {
            property->_isReadonly = YES;
        }
    }
    return property;
}
@end
