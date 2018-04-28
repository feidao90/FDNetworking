#import "VOJSONModel.h"
#import "VOContractTimesModel.h"


@interface VOProjectsModel : VOJSONModel

@property (nonatomic,copy) NSString *cityCode;
@property (nonatomic,copy) NSString *projectId;

@property (nonatomic,assign) NSInteger status;
@property (nonatomic,strong) NSArray<VOContractTimesModel> *contractTimes;

@property (nonatomic) NSInteger inSettledPeriod;
@property (nonatomic) NSInteger isExpired;

@property (nonatomic,copy) NSString *cityName;
@property (nonatomic,copy) NSString *name;

@property (nonatomic,assign) BOOL isSelected;
@end

@protocol VOProjectsModel
@end;
