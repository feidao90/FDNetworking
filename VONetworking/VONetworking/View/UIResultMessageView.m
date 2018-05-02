//
//  UIResultMessageView.m
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/18.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "UIResultMessageView.h"
#import "VOCategorySet.h"

@interface UIResultMessageView ()
{
    UIView *_superView;
    BOOL isSuccess;
}
@end

@implementation UIResultMessageView
- (instancetype)initWithFrame:(CGRect)frame withIsSuccess:(BOOL)isSuccess withSuperView:(UIView *)superView
{
    if (self = [super initWithFrame:frame])
    {
        isSuccess = isSuccess;
        self.backgroundColor = isSuccess ? [UIColor hex:@"58A5F7"] : [UIColor hex:@"FF5A60"];
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont systemFontOfSize:14.];
        self.alpha = 0;
        self.textAlignment = NSTextAlignmentCenter;
        _superView = superView;
    }
    return self;
}

//显示动画
- (void)showMessageViewWithMessage:(NSString *)message
{
    [_superView addSubview:self];
    if (message.length) {
        self.text = message;
    }else
    {
        if (!isSuccess) {
            self.text = @"服务器错误";
        }else
        {
            return;
        }
    }
    [UIView animateWithDuration:.5 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:2.];
    }];
}

- (void)showMessageViewWithMessage:(NSString *)message completeBlock:(MessageCompleteBlock)block
{
    [_superView addSubview:self];
    self.text = message;
    [UIView animateWithDuration:.5 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(DelayRemoveView:) withObject:block afterDelay:2.];
    }];
}

- (void)DelayRemoveView:(MessageCompleteBlock)block
{
    [self removeFromSuperview];
    if (block) {        
        block();
    }
}
@end
