//
//  VOBaseHeader.h
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/6.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#ifndef VOBaseHeader_h
#define VOBaseHeader_h

#pragma mark - 用户信息编辑
#define kUserAvatorTag @"vominepageuseravator"  //头像
#define kUserNameTag @"vominepageusername"      //用户名

#define kUserSkillTag @"vominepageuserskill"        //服务范围 & 技能
#define kUserIntroduceTag @"vominepageuserintroduce"    //个人&企业介绍

#define kUserProjectTag @"userofproject"    //所在项目
#define kUserEmailTag @"userofemial"    //联系邮箱

#define kUserPhoneTag @"userofphone"    //联系电话
#define kUserWebsiteTag @"userofwebsite"    //官方网站

#define kUserWeiboTag @"userofweibo"    //官方微博
#define kUserWechatTag @"userofwechat"    //微信公众号

#define kUserMemberTag @"userofmembers"    //成员

#pragma mark - 我的账号管理

#define kMemberRequestKey @"vomemberrequest"        //申请成员
#define kNewNotificationKey @"vonewnotification"        //消息通知

#define  kEnterpriseTypeKey @"voenterprisetype"         //企业支付协议
#define kMemberBelongKey @"vomemberbelong"           //所属企业

#define kMineAcountManagerKey @"vomineacountmanager"    //账号管理
#define kMineOrderKey @"vomineorder"    //我的订单

#define kMineAboutVoffice @"vomineaboutvoffice" //关于 V Office

#pragma mark - 申请物业服务
#define kServiceApplyTypeInfo @"voserviceapplytypeinfo" //申请服务-类型
#define kServiceApplyContactsInfo @"voserviceapplycontactsinfo" //申请服务-联系人

#define kServiceApplyUploadImageInfo @"voserviceapplyuploadimageinfo" //申请服务-上传图片
#define kServiceApplyDescriptionInfo @"voserviceapplydescriptioninfo" //申请服务-问题描述

#define kServiceApplyPhoneInfo @"voserviceapplyphoneinfo" //申请服务-联系人

#pragma mark - 用户联系人&&手机号存储key
#define kServiceContactsNameKey @"voservicecontactsnameonlykey"
#define kServiceContactsPhoneKey @"voservicecontactsphoneonlykey"

#pragma mark - 个推
#define kPushClientId @"pushclientid"
#define kDeviceTokenData @"devicetokendata"
#define kVOJumpToNotificationCenter @"vojimptonotificationcenter"
#define kVORefreshNotificationCenter @"vorefreshnotificationcenter"

/****************************************iphoneX 适配*******************************************/
#define IS_IPHONE_X (SCREEN_HEIGHT == 812.0f) ? YES : NO
#define Height_NavContentBar 44.0f

#define Height_StatusBar (IS_IPHONE_X) ? 44.0 : 20.0
#define Height_NavBar    (IS_IPHONE_X) ? 88.0 : 64.0

#define Height_TabBar   (IS_IPHONE_X) ? 83.0 : 49.0
/****************************************iphoneX 适配*******************************************/


/*********************************************************环境配置***************************************************************/
#ifdef DEBUG //开发环境

#define kEnviromentType 0

#else //正式环境
#define kEnviromentType 3
#endif

#endif /* VOBaseHeader_h */
