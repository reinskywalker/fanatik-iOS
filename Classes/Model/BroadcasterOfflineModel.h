#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BroadcasterOfflineModel : BaseModel

-(id)initWithDictionary:(NSDictionary *)jsonDict;
-(id)initWithFMResultSet:(FMResultSet *)result;
-(id)initWithCoder:(NSCoder *)decoder;
-(void)encodeWithCoder:(NSCoder *)encoder;

@property (nonatomic, assign) int broadcasterId;
@property (nonatomic, assign) int broadcasterUserId;
@property (nonatomic, copy) NSString *broadcasterName;
@property (nonatomic, copy) NSString *broadcasterType;
@property (nonatomic, copy) NSString *broadcasterEmail;
@property (nonatomic, assign) bool broadcasterTester;
@property (nonatomic, copy) NSString *broadcasterThumbnail;

@end