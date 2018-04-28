//
//  BaseViewController.h
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/6.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (nonatomic,assign) BOOL hiddenLeftItem;
@property (nonatomic,strong) UIButton *leftButton;

@property (nonatomic,strong) UIButton *rightButton;
@property (nonatomic,assign) BOOL hiddenRightItem;

- (void)disEnableRightItem:(BOOL)disEnable;
/**
 *创建image-leftitem
 *
 **/
- (void)createLeftItemWithImage:(UIImage *)image target:(id)target action:(SEL)selector;

/**
 *创建 title-leftitem-default
 *
 **/
- (void)createLeftItemWithTitle:(NSString *)title target:(id)target action:(SEL)selector;

/**
 *创建 title-leftitem
 *
 **/
- (void)createLeftItemWithTitle:(NSString *)title titleColor:(UIColor *)color  backGroundColor:(UIColor *)backGroundColor titleFont:(UIFont *)font target:(id)target action:(SEL)selector;

/**
 *创建 image-rightitem
 *
 **/
- (void)createRightItemWithImage:(UIImage *)image target:(id)target action:(SEL)selector;

/**
 *创建 title-rightitem-default
 *
 **/
- (void)createRightItemWithTitle:(NSString *)title target:(id)target action:(SEL)selector;

/**
 *创建 title-rightitem
 *
 **/
- (void)createRightItemWithTitle:(NSString *)title titleColor:(UIColor *)color  backGroundColor:(UIColor *)backGroundColor titleFont:(UIFont *)font target:(id)target action:(SEL)selector;

#pragma mark - left item action
- (void)backActionItem;
@end
