#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define AnnouncementStatusShow @"show"
#define AnnouncementStatusHide @"hide"

@interface EventAnnouncementModel : BaseModel

-(id)initWithDictionary:(NSDictionary *)jsonDict;
-(id)initWithFMResultSet:(FMResultSet *)result;
-(id)initWithCoder:(NSCoder *)decoder;
-(void)encodeWithCoder:(NSCoder *)encoder;

@property (nonatomic, assign) int announcementId;
@property (nonatomic, assign) int liveEventId;
@property (nonatomic, copy) NSString *announcementContent;
@property (nonatomic, copy) NSString *announcementStatus;

@end