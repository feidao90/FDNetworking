//
//  VOMinePasswordManagerView.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/8.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOMinePasswordManagerView.h"
#import "VOCategorySet.h"

@interface VOMinePasswordManagerView()
{
    UIView *_centerView;
    UIImageView *_headImage;
    
    UILabel *_titleLable;
    UIButton *_sureButton;
}
@end

@implementation VOMinePasswordManagerView
-(instancetype)init
{
    if (self = [super init]) {
        [self _initSubViews];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _initSubViews];
    }
    return self;
}

-(instancetype)initWithMangerType:(VOManagerPasswordType)type
{
    if (self = [super init]) {
        self.managerType = type;
        [self _initSubViews];
    }
    return self;
}
#pragma mark - _initSubViews
- (void)_initSubViews
{
    self.backgroundColor = [UIColor hex:@"8D8C8C" alpha:.5];
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    _centerView = [UIView new];
    [self addSubview:_centerView];
    
    _headImage = [UIImageView new];
    [_centerView addSubview:_headImage];
    
    _titleLable = [UILabel new];
    [_centerView addSubview:_titleLable];
    
    _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_centerView addSubview:_sureButton];
}

#pragma mark - layoutSubviews
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _centerView.frame = CGRectMake(SCREEN_WIDTH/2 - 315./2, 100, 315., 305.);
    _centerView.backgroundColor = [UIColor whiteColor];
    //头视图
    UIImage *image = nil;
    _headImage.frame = CGRectMake(0, 0, _centerView.width, 140.);
    switch (self.managerType) {
        case VOManagerMinePassword:
        {
            image = [UIImage imageNamed:@"change_password"];
            _headImage.image = image;
        }
            break;
        case VOManagerMineEmail:
        {
            image = [UIImage imageNamed:@"change_email"];
            _headImage.image = image;
        }
            break;
        case VOManagerMinePhone:
        {
            image = [UIImage imageNamed:@"change_mobile"];
            _headImage.image = image;
        }
            break;

        default:
            break;
    }
    
    //title
    NSString *titleString = @"";
    _titleLable.font = [UIFont systemFontOfSize:17.];
    _titleLable.textColor = [UIColor hex:@"373745"];
    _titleLable.textAlignment = NSTextAlignmentCenter;
    _titleLable.frame = CGRectMake(15., _headImage.bottom + 28., _centerView.width - 15.*2, 20);
    _titleLable.numberOfLines = 0;
    _titleLable.lineBreakMode = NSLineBreakByTruncatingTail;
    
    switch (self.managerType) {
        case VOManagerMinePassword:
        {
            titleString = @"您已成功修改登录密码，下次登录时将使用新密码登录";
            _titleLable.text = titleString;
        }
            break;
        case VOManagerMineEmail:
        {
            titleString = [NSString stringWithFormat:@"您已修改邮箱为  %@，下次登录时将使用该邮箱登录",self.userName];
            _titleLable.text = titleString;
        }
            break;
        case VOManagerMinePhone:
        {
            titleString = [NSString stringWithFormat:@"您已修改手机为  %@，下次登录时将使用该手机号登录",self.userName];
            _titleLable.text = titleString;
        }
            break;
            
        default:
            break;
    }
    CGSize titleSize = [_titleLable.text boundingRectWithSize:CGSizeMake(_titleLable.width, 5000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _titleLable.font} context:nil].size;
    _titleLable.height = titleSize.height;
    
    //确认按钮
    [_sureButton setTitle:@"知道了" forState:UIControlStateNormal];
    [_sureButton setTitleColor:[UIColor hex:@"373745"] forState:UIControlStateNormal];
    _sureButton.layer.backgroundColor = [UIColor clearColor].CGColor;
    _sureButton.layer.cornerRadius = 1.;
    _sureButton.layer.masksToBounds = YES;
    _sureButton.layer.borderColor = [UIColor hex:@"373745"].CGColor;
    _sureButton.layer.borderWidth = 1.;
    _sureButton.titleLabel.font = [UIFont systemFontOfSize:17.];
    [_sureButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    _sureButton.frame = CGRectMake(15., _titleLable.bottom + 30., _centerView.width - 15.*2, 42.);
    
    _centerView.height = _sureButton.bottom + 20.;
}

#pragma mark - closeView
- (void)closeView
{
    if (self.block) {
        self.block();
    }
    [self removeFromSuperview];
}

- (void)showView
{
    [[UIApplication sharedApplication].delegate.window addSubview:self];
}
@end
