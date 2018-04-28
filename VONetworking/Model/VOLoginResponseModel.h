#import "VOJSONModel.h"
#import "VOUserModel.h"

@interface VOLoginResponseModel : VOJSONModel

@property (nonatomic) NSString *sid;
@property (nonatomic) VOUserModel *user;

@end
