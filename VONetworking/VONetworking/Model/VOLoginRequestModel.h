//
//  VOLoginRequestModel.h
//  VofficeSDKTest
//
//  Created by much on 2017/12/14.
//  Copyright © 2017年 maqu. All rights reserved.
//

#import "VOJSONModel.h"

//  登录
@interface VOLoginRequestModel : VOJSONModel

@property (nonatomic) NSString *loginId;
@property (nonatomic) NSString *password;

@end
