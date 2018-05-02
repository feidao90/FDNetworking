//
//  UIResultMessageView.h
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/18.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^MessageCompleteBlock) (void);
@interface UIResultMessageView : UILabel

//init method with error message & success message
- (instancetype)initWithFrame:(CGRect)frame withIsSuccess:(BOOL)isSuccess withSuperView:(UIView *)superView;

//message显示动画
- (void)showMessageViewWithMessage:(NSString *)message;
//message with block
- (void)showMessageViewWithMessage:(NSString *)message completeBlock:(MessageCompleteBlock)block;
@end
