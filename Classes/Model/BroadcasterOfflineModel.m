//Copy BaseModel From Spylight


#import "BroadcasterOfflineModel.h"
@implementation BroadcasterOfflineModel

-(id)initWithDictionary:(NSDictionary *)jsonDict{
     if(self=[super init]){
            self.broadcasterId = [self intFromJSONObject:jsonDict[@"id"]];
            self.broadcasterUserId = [self intFromJSONObject:jsonDict[@"user_id"]];
            self.broadcasterName = [self stringFromJSONObject:jsonDict[@"name"]];
            self.broadcasterType = [self stringFromJSONObject:jsonDict[@"user"][@"type"]];
            self.broadcasterEmail = [self stringFromJSONObject:jsonDict[@"user"][@"email"]];
            self.broadcasterTester = [self boolFromJSONObject:jsonDict[@"user"][@"tester"]];
            self.broadcasterThumbnail = [self stringFromJSONObject:jsonDict[@"user"][@"avatar"][@"thumbnail"]];
     }
     return self;
}


-(id)initWithFMResultSet:(FMResultSet *)result{
    if(self = [super init]){
            self.broadcasterId = [result intForColumn:@"broadcasterId"];
            self.broadcasterUserId = [result intForColumn:@"broadcasterUserId"];
            self.broadcasterName = [result stringForColumn:@"broadcasterName"];
            self.broadcasterType = [result stringForColumn:@"broadcasterType"];
            self.broadcasterEmail = [result stringForColumn:@"broadcasterEmail"];
            self.broadcasterTester = [result boolForColumn:@"broadcasterTester"];
            self.broadcasterThumbnail = [result stringForColumn:@"broadcasterThumbnail"];
     }
     return self;
}


-(id)initWithCoder:(NSCoder *)decoder{
     if(self=[super init]){
           self.broadcasterId = [decoder decodeIntForKey:@"broadcasterId"];
           self.broadcasterUserId = [decoder decodeIntForKey:@"broadcasterUserId"];
           self.broadcasterName = [decoder decodeObjectForKey:@"broadcasterName"];
           self.broadcasterType = [decoder decodeObjectForKey:@"broadcasterType"];
           self.broadcasterEmail = [decoder decodeObjectForKey:@"broadcasterEmail"];
           self.broadcasterTester = [decoder decodeBoolForKey:@"broadcasterTester"];
           self.broadcasterThumbnail = [decoder decodeObjectForKey:@"broadcasterThumbnail"];
     }
     return self;
}


-(void)encodeWithCoder:(NSCoder *)encoder{
           [encoder encodeInt:self.broadcasterId forKey:@"broadcasterId"];
           [encoder encodeInt:self.broadcasterUserId forKey:@"broadcasterUserId"];
           [encoder encodeObject:self.broadcasterName forKey:@"broadcasterName"];
           [encoder encodeObject:self.broadcasterType forKey:@"broadcasterType"];
           [encoder encodeObject:self.broadcasterEmail forKey:@"broadcasterEmail"];
           [encoder encodeBool:self.broadcasterTester forKey:@"broadcasterTester"];
           [encoder encodeObject:self.broadcasterThumbnail forKey:@"broadcasterThumbnail"];
}

@end