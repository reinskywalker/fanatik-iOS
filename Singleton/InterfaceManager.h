//
//  InterfaceManager.h
//  Fanatik
//
//  Created by Teguh Hidayatullah 
//  Copyright (c) 2014 Domikado.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"


#define TheInterfaceManager ([InterfaceManager sharedInstance])
#define InterfaceStr(strID) ([TheInterfaceManager getStringProperty:strID])
#define InterfaceFloat(strID) ([TheInterfaceManager getFloatProperty:strID])
#define InterfaceColor(strID) ([TheInterfaceManager getColorProperty:strID])

@interface InterfaceManager : NSObject {

}


SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(InterfaceManager)
@property (nonatomic, retain) NSDictionary *plist;

- (void) setFile:(NSString*)file;
- (NSString*)getStringProperty:(NSString*)property;
- (float)getFloatProperty:(NSString *)property;
- (UIColor*)getColorProperty:(NSString*)property;
- (BOOL)hasProperty:(NSString*)property;

-(UIColor *)headerBGColor;
-(UIColor *)headerTextColor;
-(UIColor *)headerShadowColor;
-(UIColor *)mainBGColor;
-(UIColor *)borderColor;
-(UIColor *)backgroundYellowColor;
-(UIColor *)backgroundBlackColor;
-(UIColor *)greenFontColor;
-(UIColor *)buttonTextColor;

-(void)configHeaderView:(UIView *)hView andBgView:(UIView *)bgView;

- (NSString*)boldStringFor:(NSString*)theString;
-(void)addBorderViewForImageView:(UIImageView *)img withBorderWidth:(float)bWidth andBorderColor:(UIColor *)bColor;
-(NSString*)getFontStyleWithText:(NSString *)theText andColor:(NSString*)theColor;

-(void)addShadowToLayer:(CALayer *)layer;
-(void)addShadowToLayerForEventDetails:(CALayer *)layer;
- (NSString*)boldStringFor:(NSString*)theString WithSize:(float)theSize;

#define GET_ATTRIBUTED_STRING(str, fsz) ([TheInterfaceManager processedHTMLString:str andFontSize:fsz])
-(NSAttributedString *)processedHTMLString:(NSString *)str andFontSize:(int) fontSize;
-(NSAttributedString *)processedOHHTMLString:(NSString *)str andFontSize:(int)fontSize;
- (unsigned int)getHexaDecimal:(NSString *)decimal;
-(UIColor *)convertColorStrToColor:(NSString *)colorStr isBackground:(BOOL)isBg;
@end
