#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSArray+VOJSONModel.h"
#import "NSDictionary+VOJSONModel.h"
#import "VOJSONModel.h"
#import "VOJSONModelError.h"
#import "VOJSONModelKeyMapper.h"
#import "VOJSONModelProperty.h"

FOUNDATION_EXPORT double VOJSONModelVersionNumber;
FOUNDATION_EXPORT const unsigned char VOJSONModelVersionString[];

