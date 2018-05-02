#import "VOJSONModel.h"

@interface VOAvatarModel : VOJSONModel

@property (nonatomic) NSInteger attachmentId;
@property (nonatomic) NSString *sourceName;
@property (nonatomic) NSInteger height;
@property (nonatomic) NSString *url;

@property (nonatomic) NSInteger width;

@end
