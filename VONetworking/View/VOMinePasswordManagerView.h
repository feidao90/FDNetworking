//
//  VOMinePasswordManagerView.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/8.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, VOManagerPasswordType){
    VOManagerMinePassword                 =  1,
    VOManagerMineEmail                        = 2,
    VOManagerMinePhone                       = 3,
};

typedef void(^MineAccountBlock)(void);

@interface VOMinePasswordManagerView : UIView

@property (nonatomic,assign) VOManagerPasswordType managerType;
@property (nonatomic,copy) NSString *userName;

@property (nonatomic,copy) MineAccountBlock block;

-(instancetype)initWithMangerType:(VOManagerPasswordType)type;
- (void)showView;
@end
