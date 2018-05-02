//
//  VOJSONModelProperty.h
//  Test
//
//  Created by 何广忠 on 2017/12/14.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VOJSONModelPropertyValueType) {
    VOClassPropertyValueTypeNone = 0,
    VOClassPropertyTypeChar,
    VOClassPropertyTypeInt,
    VOClassPropertyTypeShort,
    VOClassPropertyTypeLong,
    VOClassPropertyTypeLongLong,
    VOClassPropertyTypeUnsignedChar,
    VOClassPropertyTypeUnsignedInt,
    VOClassPropertyTypeUnsignedShort,
    VOClassPropertyTypeUnsignedLong,
    VOClassPropertyTypeUnsignedLongLong,
    VOClassPropertyTypeFloat,
    VOClassPropertyTypeDouble,
    VOClassPropertyTypeBool,
    VOClassPropertyTypeVoid,
    VOClassPropertyTypeCharString,
    VOClassPropertyTypeObject,
    VOClassPropertyTypeClassObject,
    VOClassPropertyTypeSelector,
    VOClassPropertyTypeArray,
    VOClassPropertyTypeStruct,
    VOClassPropertyTypeUnion,
    VOClassPropertyTypeBitField,
    VOClassPropertyTypePointer,
    VOClassPropertyTypeUnknow
};
@interface VOJSONModelProperty : NSObject{
@public
    NSString *_name;
    VOJSONModelPropertyValueType _valueType;
    NSString *_typeName;
    Class _objectClass;
    NSArray *_objectProtocols;
    Class _containerElementClass;
    BOOL _isReadonly;
}

+ (instancetype)propertyWithName:(NSString *)name typeString:(NSString *)typeString;

@end
