//
//  VOBaseNavViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/6.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "VOBaseNavViewController.h"
#import "VOCategorySet.h"

@interface VOBaseNavViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

@end

@implementation VOBaseNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //title 样式设置
    [self setTitleAttribute];
    
    //delegate
    self.delegate = self;
    
    //导航栏颜色
    [self setNavigationBackGroundColor];
}

#pragma mark - title样式
- (void)setTitleAttribute
{
    //title 样式设置
    UIFont *font = [UIFont boldSystemFontOfSize:17.];
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationBar.titleTextAttributes =dic;
}

#pragma mark - 导航栏颜色
- (void)setNavigationBackGroundColor
{
    [self.navigationBar setBackgroundImage:[self createImageWithColor:[UIColor hex:@"45536F"] ] forBarMetrics:UIBarMetricsDefault];
}

//color -> image
- (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0,0, SCREEN_WIDTH, 64.);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - iPhoneX 适配
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    // 修改tabBra的frame
    CGRect frame = self.tabBarController.tabBar.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
    self.tabBarController.tabBar.frame = frame;
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
