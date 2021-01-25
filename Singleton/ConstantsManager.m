//
//  ConstantsManager.m
//  Guestbook
//
//  Created by Teguh Hidayatullah on 12/17/2014.
//  Copyright 2014 Domikado. All rights reserved.
//

#import "ConstantsManager.h"


@implementation ConstantsManager

@synthesize plist;
SYNTHESIZE_SINGLETON_FOR_CLASS(ConstantsManager)

-(id)init {
	if (self = [super init]) {
#ifdef DEBUG
        [self setFile:@"Constants_dev.plist"];
#else
		[self setFile:@"Constants.plist"];
#endif
	}
	return self;
}

-(void)setFile:(NSString*) file {
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSString *finalPath = [path stringByAppendingPathComponent:file];
	self.plist = [NSDictionary dictionaryWithContentsOfFile:finalPath];
}

-(BOOL)hasProperty:(NSString*)property {
	return ([plist objectForKey:property]!=nil);
}

- (NSString*)getStringProperty:(NSString*)property {
	return [plist objectForKey:property];
}

-(int)getIntegerProperty:(NSString *)property{
	return [[plist objectForKey:property] intValue];
}

- (UIColor*)getColorProperty:(NSString*)property {
	NSString* color = [plist objectForKey:property];
	NSArray *values = [color componentsSeparatedByString: @","];
	float red = [[values objectAtIndex:0] floatValue] / 255.0;
	float green = [[values objectAtIndex:1] floatValue] / 255.0;
	float blue = [[values objectAtIndex:2] floatValue] / 255.0;
	float alpha = [[values objectAtIndex:3] floatValue] / 255.0;
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

-(NSString *)facebookApiKey{
	NSLog(@"FACEBOOK API %@",[self getStringProperty:@"facebook_api"] );
	return [self getStringProperty:@"facebook_api"];
}

-(NSString *)baseAPI{
    return [self getStringProperty:@"server_url"];
}

-(NSString *)chatURL{
    return [self getStringProperty:@"chat_url"];
}

-(NSString *)stickerURL{
    return [self getStringProperty:@"sticker_url"];
}

-(NSString *)serverURL{
    NSString *baseAPI = [self getStringProperty:@"server_url"];
    if(TheSettingsManager.debugServerURL && ![[TheSettingsManager debugServerURL] isEqualToString:@""]){
        baseAPI = TheSettingsManager.debugServerURL;
    }
    return [NSString stringWithFormat:@"%@/%@/%@/",baseAPI, [self partnerName], [self apiVersion]];
}

-(NSString *)fayeServerURL{
    return [self getStringProperty:@"faye_server_url"];
}

-(NSString *)iosAppId   {
    return [self getStringProperty:@"ios_app_id"];
}

-(int)timeInterval   {
    return [self getIntegerProperty:@"time_interval"];
}

-(NSString *)defaultDateFormatMonthAndDateOnly{
    return [self getStringProperty:@"default_date_format_month_date"];
}

-(NSString *)defaultDateTimeFormat{
    return [self getStringProperty:@"default_date_time_format"];
}

-(NSString *)defaultDateFormat{
    return [self getStringProperty:@"default_date_format"];
}

-(NSString *)defaultTimeFormat{
    return [self getStringProperty:@"default_time_format"];
}

-(NSString *)parseClientKey{
    //return @"91XJOdqQ3ogWsn02q7wQemocunwADp285w1Qlr2a";
    return [self getStringProperty:@"parse_client_key"];
}

-(NSString *)parseApplicationID{
    //return @"wgqqgRYJe5fEtkV93diyLBgBRGdU6iJPgULkBkN8";
    return [self getStringProperty:@"parse_application_id"];
}

-(NSString *)twitterCustomerKey {
    return [self getStringProperty:@"TWITTER_CONSUMER_KEY"];
}

-(NSString *)twitterCustomerSecret  {
    return [self getStringProperty:@"TWITTER_CONSUMER_SECRET"];
}

-(NSString *)wundergroundKey    {
    return [self getStringProperty:@"wunderground_key"];
}

-(NSString *)foursquareClientID{
    return [self getStringProperty:@"foursquare_id"];
}


-(int)maxCloudRetryCount{
    return 6;
}

-(float)searchMiles {
    return [self getIntegerProperty:@"search_miles"];
}

-(NSString *)partnerName{
    return [self getStringProperty:@"partner_name"];
}
-(NSString *)apiVersion{
    return [self getStringProperty:@"api_version"];
}

-(NSString *)googleClientID{
    return [self getStringProperty:@"google_plus_client_id"];
}

-(NSString *)buildNumber{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
}

@end