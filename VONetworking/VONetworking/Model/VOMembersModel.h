#import "VOJSONModel.h"
#import "VOAvatarModel.h"

@interface VOMembersModel : VOJSONModel

@property (nonatomic) NSInteger loginForbidden;
@property (nonatomic) NSString *name;
@property (nonatomic,copy) NSString *userId;
@property (nonatomic) VOAvatarModel *avatar;
@end

@protocol VOMembersModel
@end
