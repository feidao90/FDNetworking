//
//  VOJSONModel.m
//  Test
//
//  Created by 何广忠 on 2017/12/13.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "VOJSONModel.h"
#import <objc/runtime.h>
#import "NSArray+VOJSONModel.h"
#import "NSDictionary+VOJSONModel.h"
#import "VOJSONModelKeyMapper.h"
#import "VOJSONModelProperty.h"
#import "VOJSONModelError.h"


NSString * const VOJSONModelBoolStringTrue = @"true";
NSString * const VOJSONModelBoolStringFalse = @"false";



//下面两个静态无需初始化，因为用于关联对象的key的时候只会用到其地址
static const char * kAssociatedMapperKey;
static const char * kAssociatedPropertiesKey;

@interface VOJSONModel(){
    BOOL _treaVOoolAsStringWhenModelToJSON;
}

@end

@implementation VOJSONModel

#pragma mark -
#pragma mark Private
- (void)_setupKeyMapper{
    if (objc_getAssociatedObject(self.class, &kAssociatedMapperKey) == nil) {
        VOJSONModelKeyMapper *keyMapper = [self.class modelKeyMapper];
        if (keyMapper != nil) {
            objc_setAssociatedObject(self.class, &kAssociatedMapperKey, keyMapper, OBJC_ASSOCIATION_RETAIN);
        }
    }
}

- (void)_setupPropertyMap{
    if (objc_getAssociatedObject(self.class, &kAssociatedPropertiesKey) == nil) {
        
        NSMutableDictionary *propertyMap = [NSMutableDictionary dictionary];
        
        Class class = [self class];
        
        NSArray *ignoredNames = [class ignoredPropertyNames];
        NSSet *ignoredNameSet = nil;
        if (ignoredNames) {
            ignoredNameSet = [NSSet setWithArray:ignoredNames];
        }
        
        
        while (class != [VOJSONModel class]) {
            unsigned int propertyCount;
            objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
            for (unsigned int i = 0; i < propertyCount; i++) {
                
                objc_property_t property = properties[i];
                const char *propertyName = property_getName(property);
                if (propertyName) {
                    NSString *name = [NSString stringWithUTF8String:propertyName];
                    if (ignoredNameSet && [ignoredNameSet containsObject:name]) {
                        continue;
                    }
                    
                    //属性的相关属性都在propertyAttrs中，包括其类型，protocol，存取修饰符等信息
                    const char *propertyAttrs = property_getAttributes(property);
                    NSString *typeString = [NSString stringWithUTF8String:propertyAttrs];
                    VOJSONModelProperty *modelProperty = [VOJSONModelProperty propertyWithName:name typeString:typeString];
                    if (!modelProperty->_isReadonly) {
                        [propertyMap setValue:modelProperty forKey:modelProperty->_name];
                    }
                }
            }
            free(properties);
            
            class = [class superclass];
        }
        objc_setAssociatedObject(self.class, &kAssociatedPropertiesKey, propertyMap, OBJC_ASSOCIATION_RETAIN);
    }
}


//根据对应的属性类型，将value进行转换成合适的值
- (id)valueForProperty:(VOJSONModelProperty *)property withJSONValue:(id)value{
    id resultValue = value;
    if (value == nil || [value isKindOfClass:[NSNull class]]) {
        resultValue = nil;
    }else{
        if (property->_valueType != VOClassPropertyTypeObject) {
            /*当属性为原始数据类型而对应的json dict中的value的类型为字符串对象的时候
             则对字符串进行相应的转换*/
            if ([value isKindOfClass:[NSString class]]) {
                if (property->_valueType == VOClassPropertyTypeInt ||
                    property->_valueType == VOClassPropertyTypeUnsignedInt||
                    property->_valueType == VOClassPropertyTypeShort||
                    property->_valueType == VOClassPropertyTypeUnsignedShort) {
                    resultValue = [NSNumber numberWithInt:[(NSString *)value intValue]];
                }
                if (property->_valueType == VOClassPropertyTypeLong ||
                    property->_valueType == VOClassPropertyTypeUnsignedLong ||
                    property->_valueType == VOClassPropertyTypeLongLong ||
                    property->_valueType == VOClassPropertyTypeUnsignedLongLong){
                    resultValue = [NSNumber numberWithLongLong:[(NSString *)value longLongValue]];
                }
                if (property->_valueType == VOClassPropertyTypeFloat) {
                    resultValue = [NSNumber numberWithFloat:[(NSString *)value floatValue]];
                }
                if (property->_valueType == VOClassPropertyTypeDouble) {
                    resultValue = [NSNumber numberWithDouble:[(NSString *)value doubleValue]];
                }
                if (property->_valueType == VOClassPropertyTypeChar) {
                    //对于BOOL而言，@encode(BOOL) 为 c 也就是signed char
                    resultValue = [NSNumber numberWithBool:[(NSString *)value boolValue]];
                }
                if (property->_valueType == VOClassPropertyTypeUnsignedChar) {
                    resultValue = [NSNumber numberWithBool:[(NSString *)value boolValue]];
                }
            }
        }else{
            Class valueClass = property->_objectClass;
            
            if ([valueClass isSubclassOfClass:[VOJSONModel class]] &&
                [value isKindOfClass:[NSDictionary class]]) {
                //当当前属性为VOJSONModel类型
                resultValue = [[valueClass alloc] initWithJSONDictionary:value];
            } else if ([valueClass isSubclassOfClass:[NSString class]] &&
                       ![value isKindOfClass:[NSString class]]) {
                //当当前属性为NSString类型，而对应的json的value为非NSString对象，自动进行转换
                resultValue = [NSString stringWithFormat:@"%@",value];
            } else if ([valueClass isSubclassOfClass:[NSNumber class]] &&
                       [value isKindOfClass:[NSString class]]) {
                //当当前属性为NSNumber类型，而对应的json的value为NSString的时候
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                resultValue = [numberFormatter numberFromString:value];
            } else {
                Class modelContainerElementClass = property->_containerElementClass;
                
                if (!modelContainerElementClass) {
                    NSDictionary *modelContainerClassMap = [[self class] modelContainerClassMapDictioanry];
                    if (modelContainerClassMap) {
                        modelContainerElementClass = modelContainerClassMap[property->_name];
                        property->_containerElementClass = modelContainerElementClass;
                    }
                }
                
                if (modelContainerElementClass && [modelContainerElementClass isSubclassOfClass:[VOJSONModel class]]) {
                    //array of models
                    if ([value isKindOfClass:[NSArray class]]) {
                        resultValue = [(NSArray *)value modelArrayWithClass:modelContainerElementClass];
                    }
                    //dictionary of models
                    if ([value isKindOfClass:[NSDictionary class]]) {
                        resultValue = [(NSDictionary *)value modelDictionaryWithClass:modelContainerElementClass];
                    }
                }
            }
        }
    }
    return resultValue;
}

#pragma mark -
#pragma mark Class Method
+ (id)modelWithJSONDictionary:(NSDictionary *)dict{
    return [self modelWithJSONDictionary:dict error:NULL];
}

+ (id)modelWithJSONDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)error{
    return [[self alloc] initWithJSONDictionary:dict error:error];
}

#pragma mark -
#pragma mark Init
- (id)init{
    self = [super init];
    if (self != nil) {
        [self _setupKeyMapper];
        [self _setupPropertyMap];
    }
    return self;
}

- (id)initWithJSONDictionary:(NSDictionary *)dict{
    return [self initWithJSONDictionary:dict error:NULL];
}

- (id)initWithJSONDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)error{
    
    if (!dict) {
        if (error) {
            *error = [VOJSONModelError errorNilInput];
        }
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        if (error) {
            *error = [VOJSONModelError errorDataInvalidWithDescription:@"输入参数类型数错，应该为NSDictionary"];
        }
        return nil;
    }
    
    self = [self init];
    if (self) {
        [self updateWithJSONDictionary:dict];
    }
    return self;
}

- (void)updateWithJSONDictionary:(NSDictionary *)dict{
    NSDictionary *propertyMap = objc_getAssociatedObject(self.class, &kAssociatedPropertiesKey);
    VOJSONModelKeyMapper *keyMapper = objc_getAssociatedObject(self.class, &kAssociatedMapperKey);
    
    //对JSON所有字段进行遍历，到 keyMapper 中查看是否有映射的属性名，然后再对属性进行设置
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *jsonKey, id jsonValue, BOOL *stop) {
        NSString *propertyKey = keyMapper ? [keyMapper modelKeyMappedFromJsonKey:jsonKey] : jsonKey;
        VOJSONModelProperty *modelProperty = [propertyMap valueForKey:propertyKey];
        if (modelProperty) {
            id propertyValue = [self valueForProperty:modelProperty withJSONValue:jsonValue];
            if (propertyValue != nil) {
                [self setValue:propertyValue forKey:modelProperty->_name];
            }
        }
    }];
}

- (NSDictionary *)toJSONDictionary{
    NSDictionary *propertyMap = objc_getAssociatedObject(self.class, &kAssociatedPropertiesKey);
    if (propertyMap!= nil && [propertyMap count] > 0) {
        NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionaryWithCapacity:[propertyMap count]];
        VOJSONModelKeyMapper *keyMapper = objc_getAssociatedObject(self.class, &kAssociatedMapperKey);
        
        for (VOJSONModelProperty *property in [propertyMap allValues]) {
            NSString *dictKey = property->_name;
            
            if (!dictKey) {
                //如果在异常情况下发现dictKey为nil，则忽略此属性
                continue;
            }
            
            id val = [self valueForKeyPath:dictKey];
            
            if ([val isKindOfClass:[VOJSONModel class]]) {
                val = [(VOJSONModel *)val toJSONDictionary];
            }else if([val isKindOfClass:[NSArray class]]){
                val = [(NSArray *)val toJSONArray];
            }else if([val isKindOfClass:[NSDictionary class]]){
                val = [(NSDictionary *)val toJSONDictionary];
            }
            
            if (keyMapper != nil) {
                NSString *mappedKey = [keyMapper jsonKeyMappedFromModelKey:dictKey];
                if (mappedKey != nil) {
                    dictKey = mappedKey;
                }
            }
            
            if (val != nil && dictKey != nil) {
                if (property->_valueType == VOClassPropertyTypeChar) {
                    if (_treaVOoolAsStringWhenModelToJSON &&
                        [val isKindOfClass:[NSNumber class]]) {
                        NSString *booleanString = nil;
                        if ([val boolValue]) {
                            booleanString = VOJSONModelBoolStringTrue;
                        }else{
                            booleanString = VOJSONModelBoolStringFalse;
                        }
                        [jsonDictionary setObject:booleanString forKey:dictKey];
                    }else{
                        [jsonDictionary setObject:val forKey:dictKey];
                    }
                }else{
                    [jsonDictionary setObject:val forKey:dictKey];
                }
            }
        }
        return jsonDictionary;
    }
    return nil;
}

- (void)setTreatBoolAsStringWhenModelToJSON:(BOOL)treaVOoolAsStringWhenModelToJSON{
    _treaVOoolAsStringWhenModelToJSON = treaVOoolAsStringWhenModelToJSON;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[self.class allocWithZone:zone] initWithJSONDictionary:[self toJSONDictionary] error:NULL];
}

#pragma mark -
#pragma mark Key-Value Coding

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"WARNING: [%@] Set value:%@ for undefiend key: %@",NSStringFromClass(self.class) ,value, key);
}

- (id)valueForUndefinedKey:(NSString *)key {
    NSLog(@"WARNING: [%@] Get value for undefiend key %@", self, key);
    return nil;
}

- (void)setNilValueForKey:(NSString *)key{
    NSLog(@"WARNING: set nil value for key %@", key);
}

+ (VOJSONModelKeyMapper *)modelKeyMapper{
    NSDictionary *modelKeyMap = [self jsonToModelKeyMapDictionary];
    if (modelKeyMap) {
        return [[VOJSONModelKeyMapper alloc] initWithDictionary:modelKeyMap];
    } else {
        return nil;
    }
}

+ (NSDictionary *)jsonToModelKeyMapDictionary{
    return nil;
}

+ (NSDictionary *)modelContainerClassMapDictioanry{
    return nil;
}

+ (NSArray *)ignoredPropertyNames{
    return nil;
}
@end
