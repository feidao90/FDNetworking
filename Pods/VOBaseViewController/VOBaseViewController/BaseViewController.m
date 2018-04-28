//
//  BaseViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/6.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "BaseViewController.h"
#import "VOCategorySet.h"

@interface BaseViewController ()<UIGestureRecognizerDelegate>
{
    NSArray *_lastRightItems;
    UIPanGestureRecognizer *currentPan;
}
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor hex:@"F2F3F8"];
    self.navigationItem.leftBarButtonItems = [self getDefaultLeftItems];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}
#pragma mark - enable - item
- (void)disEnableRightItem:(BOOL)disEnable
{
    self.rightButton.enabled = !disEnable;
    if (disEnable)
    {
        [self.rightButton setTitleColor:[UIColor hex:@"FFFFFF" alpha:.5] forState:UIControlStateNormal];
    }else
    {
        [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}
#pragma mark - left item action
- (void)backActionItem
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - getDefaultLeftItems
- (NSArray *)getDefaultLeftItems
{
    //left item
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton addTarget:self action:@selector(backActionItem) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 44., 44.);
    
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44./2 - 24./2, 24., 24.)];
    backImageView.image = [UIImage imageNamed:@"qrcode_scan_titlebar_back_nor"];
    backImageView.contentMode = UIViewContentModeScaleAspectFit;
    [backButton addSubview:backImageView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    return @[self.navigationItem.leftBarButtonItem];
}

#pragma mark - setter method
-(void)setHiddenLeftItem:(BOOL)hiddenLeftItem
{
    _hiddenLeftItem = hiddenLeftItem;
    self.navigationItem.leftBarButtonItems = _hiddenLeftItem ? [NSArray array] : [self getDefaultLeftItems];
}

-(void)setHiddenRightItem:(BOOL)hiddenRightItem
{
    _hiddenRightItem = hiddenRightItem;
    self.navigationItem.rightBarButtonItems = _hiddenRightItem ? [NSArray array] : _lastRightItems;
}
#pragma mark - public method
//创建image-leftitem
- (void)createLeftItemWithImage:(UIImage *)image target:(id)target action:(SEL)selector
{
    //left item
    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftButton.backgroundColor = [UIColor clearColor];
    self.leftButton.frame = CGRectMake(0, 0, 44., 44.);
    [self.leftButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44./2 - image.size.height/2, image.size.width, image.size.height)];
    backImageView.image = image;
    backImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.leftButton addSubview:backImageView];
    
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.leftButton]];
}

//创建 title-leftitem-default
- (void)createLeftItemWithTitle:(NSString *)title target:(id)target action:(SEL)selector
{
    //left item
    self.leftButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.leftButton  setTitle:title forState:UIControlStateNormal];
    [self.leftButton  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.leftButton.backgroundColor =[UIColor clearColor];
    self.leftButton.titleLabel.font = [UIFont systemFontOfSize:17.];
    self.leftButton.frame = CGRectMake(0, 0, 44, 44);
    [self.leftButton  addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.leftButton]];
}


//创建 title-leftitem
- (void)createLeftItemWithTitle:(NSString *)title titleColor:(UIColor *)color  backGroundColor:(UIColor *)backGroundColor titleFont:(UIFont *)font target:(id)target action:(SEL)selector
{
    //left item
    self.leftButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.leftButton  setTitle:title forState:UIControlStateNormal];
    [self.leftButton  setTitleColor:color forState:UIControlStateNormal];
    self.leftButton.backgroundColor =backGroundColor;
    self.leftButton.titleLabel.font = font;
    self.leftButton.frame = CGRectMake(0, 0, 44, 44);
    [self.leftButton  addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.leftButton]];
}



//创建 image-rightitem
- (void)createRightItemWithImage:(UIImage *)image target:(id)target action:(SEL)selector
{
    //left item
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightButton setImage:image forState:UIControlStateNormal];
    self.rightButton.backgroundColor = [UIColor clearColor];
    [self.rightButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    self.rightButton.frame = CGRectMake(0, 0, 44, 44);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = 0;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,self.navigationItem.rightBarButtonItem];
    _lastRightItems = self.navigationItem.rightBarButtonItems;
}

//创建 title-rightitem-default
- (void)createRightItemWithTitle:(NSString *)title target:(id)target action:(SEL)selector
{
    //left item
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightButton setTitle:title forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.rightButton.backgroundColor =[UIColor clearColor];
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:17.];
    [self.rightButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    CGSize size = [self.rightButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : self.rightButton.titleLabel.font}];
    self.rightButton.frame = CGRectMake(0, 0, size.width, 24);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = 0;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,self.navigationItem.rightBarButtonItem];
    _lastRightItems = self.navigationItem.rightBarButtonItems;
}

//创建 title-rightitem
- (void)createRightItemWithTitle:(NSString *)title titleColor:(UIColor *)color  backGroundColor:(UIColor *)backGroundColor titleFont:(UIFont *)font target:(id)target action:(SEL)selector
{
    //left item
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightButton setTitle:title forState:UIControlStateNormal];
    [self.rightButton setTitleColor:color forState:UIControlStateNormal];
    self.rightButton.backgroundColor =backGroundColor;
    self.rightButton.titleLabel.font = font;
    [self.rightButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    CGSize size = [self.rightButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : self.rightButton.titleLabel.font}];
    self.rightButton.frame = CGRectMake(0, 0, size.width, 24);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = 0;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,self.navigationItem.rightBarButtonItem];
    _lastRightItems = self.navigationItem.rightBarButtonItems;
}

// 返回状态栏的样式
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
// 控制状态栏的现实与隐藏
- (BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
