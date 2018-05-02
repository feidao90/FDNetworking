#import "VOJSONModel.h"
#import "VOMembersModel.h"

#import "VOProjectsModel.h"
#import "VOAvatarModel.h"

@class VOUserProcessingApplicationModel;
@class VOUserAssociatorEnterpriseModel;
@interface VOUserModel : VOJSONModel

@property (nonatomic) NSString *wechat;
@property (nonatomic) NSString *serviceScope;

@property (nonatomic) NSString *contactEmail;
@property (nonatomic) NSInteger gmtModified;

@property (nonatomic) NSString *contactPhone;
@property (nonatomic,strong) VOUserProcessingApplicationModel *processingApplication;

@property (nonatomic) NSInteger gmtCreate;
@property (nonatomic) NSString *industry;

@property (nonatomic) NSInteger paymentAuthorizeType;
@property (nonatomic) NSString *mobilePhone;

@property (nonatomic) NSString *name;
@property (nonatomic,copy) NSString *type;

@property (nonatomic) NSArray<VOMembersModel> *members;
@property (nonatomic) NSInteger loginForbidden;

@property (nonatomic,copy) NSString *memberTotal;
@property (nonatomic) NSString *email;

@property (nonatomic) NSString *website;
@property (nonatomic) NSInteger hasPrinter;

@property (nonatomic) VOProjectsModel *currentProject;
@property (nonatomic) NSArray<VOProjectsModel> *projects;

@property (nonatomic) VOAvatarModel *avatar;
@property (nonatomic) NSInteger currentProjectExpired;

@property (nonatomic) NSString *introduction;
@property (nonatomic) NSString *weibo;

@property (nonatomic,strong) VOUserAssociatorEnterpriseModel *enterprise;
@property (nonatomic,copy) NSString *userId;
@end

@class VOUserEnterPriseOfProcessModel;
@interface VOUserProcessingApplicationModel : VOJSONModel

@property (nonatomic,copy) NSString *enterEnterpriseApplicationId;
@property (nonatomic,strong) VOUserEnterPriseOfProcessModel *enterprise;

@property (nonatomic,copy) NSString *gmtCreate;
@property (nonatomic,copy) NSString *status;
@end

@interface VOUserEnterPriseOfProcessModel : VOJSONModel

@property (nonatomic,strong) VOAvatarModel *avatar;
@property (nonatomic,copy) NSString *name;

@property (nonatomic,copy) NSString *serviceScope;
@property (nonatomic,copy) NSString *userId;
@end

@interface VOUserAssociatorEnterpriseModel : VOJSONModel

@property (nonatomic,strong) VOAvatarModel *avatar;
@property (nonatomic,copy) NSString *name;

@property (nonatomic,copy) NSString *serviceScope;
@property (nonatomic,copy) NSString *userId;
@end
