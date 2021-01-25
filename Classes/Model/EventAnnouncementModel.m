//Copy BaseModel From Spylight


#import "EventAnnouncementModel.h"
@implementation EventAnnouncementModel

-(id)initWithDictionary:(NSDictionary *)jsonDict{
     if(self=[super init]){
            self.announcementId = [self intFromJSONObject:jsonDict[@"id"]];
            self.liveEventId = [self intFromJSONObject:jsonDict[@"live_event_id"]];
            self.announcementContent = [self stringFromJSONObject:jsonDict[@"content"]];
            self.announcementStatus = [self stringFromJSONObject:jsonDict[@"status"]];
     }
     return self;
}


-(id)initWithFMResultSet:(FMResultSet *)result{
    if(self = [super init]){
            self.announcementId = [result intForColumn:@"announcementId"];
            self.liveEventId = [result intForColumn:@"liveEventId"];
            self.announcementContent = [result stringForColumn:@"announcementContent"];
            self.announcementStatus = [result stringForColumn:@"announcementStatus"];
     }
     return self;
}


-(id)initWithCoder:(NSCoder *)decoder{
     if(self=[super init]){
           self.announcementId = [decoder decodeIntForKey:@"announcementId"];
           self.liveEventId = [decoder decodeIntForKey:@"liveEventId"];
           self.announcementContent = [decoder decodeObjectForKey:@"announcementContent"];
           self.announcementStatus = [decoder decodeObjectForKey:@"announcementStatus"];
     }
     return self;
}


-(void)encodeWithCoder:(NSCoder *)encoder{
           [encoder encodeInt:self.announcementId forKey:@"announcementId"];
           [encoder encodeInt:self.liveEventId forKey:@"liveEventId"];
           [encoder encodeObject:self.announcementContent forKey:@"announcementContent"];
           [encoder encodeObject:self.announcementStatus forKey:@"announcementStatus"];
}

@end