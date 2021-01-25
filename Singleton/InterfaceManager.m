//
//  InterfaceManager.m
//  Fanatik
//
//  Created by Teguh Hidayatullah
//  Copyright (c) 2014 Domikado All rights reserved.
//

#import "InterfaceManager.h"
//#import "DatabaseManager.h"

@implementation InterfaceManager

@synthesize plist;
SYNTHESIZE_SINGLETON_FOR_CLASS(InterfaceManager)


-(id)init {
	if (self = [super init]) {
		[self setFile:@"InterfaceManager.plist"];
        [self configureDefaultAppearances];
	}
	return self;
}

-(void)configureDefaultAppearances{
    [[UISearchBar appearance] setTintColor:[UIColor clearColor]];
}


-(void) setFile:(NSString*) file {
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

-(float)getFloatProperty:(NSString *)property{
	return [[plist objectForKey:property] floatValue];
}

- (UIColor*)getColorProperty:(NSString*)property {
	return COLOR_HEX([self getStringProperty:property]);
}

- (unsigned int)getHexaProperty:(NSString *)property {
    unsigned int outVal;
    NSScanner* scanner = [NSScanner scannerWithString:[@"0x" stringByAppendingString:[self getStringProperty:property]]];
    [scanner scanHexInt:&outVal];
    
    return outVal;
    
}

- (unsigned int)getHexaDecimal:(NSString *)decimal {
    unsigned int outVal;
    NSScanner* scanner = [NSScanner scannerWithString:[@"0x" stringByAppendingString:decimal]];
    [scanner scanHexInt:&outVal];
    
    return outVal;
}

-(UIColor *)convertColorStrToColor:(NSString *)colorStr isBackground:(BOOL)isBg{

    NSCharacterSet *trim = [NSCharacterSet characterSetWithCharactersInString:@"#"];
    NSString *textColorResultStr = [[colorStr componentsSeparatedByCharactersInSet:trim] componentsJoinedByString:@""];
    textColorResultStr = [textColorResultStr stringByAppendingString:@"FF"];
    
    UIColor *returnColor = nil;
    if(![colorStr isEqualToString:@""] && colorStr){
        returnColor = HEXCOLOR([TheInterfaceManager getHexaDecimal:textColorResultStr]);
    }else{
        returnColor = isBg?HEXCOLOR(0xFFCC00FF):[UIColor whiteColor];
    }
                                                                                                                     
    return isBg?[returnColor colorWithAlphaComponent:0.8]:returnColor;
}

-(UIColor *)headerBGColor{
    return HEXCOLOR([self getHexaProperty:@"header_bg_color"]);
}

-(UIColor *)headerTextColor{
    return HEXCOLOR([self getHexaProperty:@"header_text_color"]);
}

-(UIColor *)headerShadowColor{
    return HEXCOLOR([self getHexaProperty:@"header_shadow_color"]);
}

-(UIColor *)mainBGColor{
    return HEXCOLOR([self getHexaProperty:@"main_bg_color"]);
}

-(UIColor *)buttonTextColor{
    return HEXCOLOR([self getHexaProperty:@"btn_text_color"]);
}

-(UIFont *)buttonFontWithSize:(float)theSize{
    return [UIFont fontWithName:[self getStringProperty:@"btn_font"] size:theSize];
}

-(UIColor *)backgroundYellowColor{
    return HEXCOLOR([self getHexaProperty:@"background_yellow_color"]);
}

-(UIColor *)borderColor{
    return HEXCOLOR([self getHexaProperty:@"border_color"]);
}


-(UIColor *)backgroundBlackColor{
    return HEXCOLOR([self getHexaProperty:@"background_black_color"]);
}

-(UIColor *)greenFontColor{
    return HEXCOLOR([self getHexaProperty:@"green_font_color"]);
}


-(void)configHeaderView:(UIView *)hView andBgView:(UIView *)bgView{
    
//    [bgView setBackgroundColor:[self headerBGColor]];
//    hView.layer.masksToBounds = NO;
//    hView.layer.shadowOffset = CGSizeMake(0, 2);
//    hView.layer.shadowRadius = 0;
//    hView.layer.shadowColor = [[self headerShadowColor] CGColor];
//    hView.layer.shadowOpacity = 1;
//    hView.layer.shadowPath = [UIBezierPath bezierPathWithRect:hView.bounds].CGPath;
    
//    UIButton *leftButton = (UIButton *)[bgView viewWithTag:1];
//    [leftButton setBackgroundColor:[UIColor clearColor]];
//    [leftButton setTitleColor:[self buttonTextColor] forState:UIControlStateNormal];
//    leftButton.titleLabel.font = [self buttonFontWithSize:14.0];
//    
//    UIButton *rightButton = (UIButton *)[bgView viewWithTag:3];
//    [rightButton setBackgroundColor:[UIColor clearColor]];
//    [rightButton setTitleColor:[self buttonTextColor] forState:UIControlStateNormal];
//    rightButton.titleLabel.font = [self buttonFontWithSize:14.0];
//    
//    UILabel *midLabel = (UILabel *)[bgView viewWithTag:2];
//    midLabel.backgroundColor = [UIColor clearColor];
//    midLabel.textColor = [self headerTextColor];
//    midLabel.font = [self buttonFontWithSize:24.0];
    
    
}

- (NSString*)boldStringFor:(NSString*)theString {
	return [NSString stringWithFormat:@"<font name='%@' size='12.0'>%@</font>", InterfaceStr(@"default_font_bold"),theString];
}

- (NSString*)boldStringFor:(NSString*)theString WithSize:(float)theSize{
	return [NSString stringWithFormat:@"<font name='%@' size='%f'>%@</font>", InterfaceStr(@"default_font_bold"),theSize, theString];
}

-(void)addBorderViewForImageView:(UIImageView *)img withBorderWidth:(float)bWidth andBorderColor:(UIColor *)bColor {
    if(!bWidth || bWidth==0){
        bWidth = 5.0;
    }
    
    if(!bColor){
        bColor = [TheInterfaceManager getColorProperty:@"header_bg_color"];

    }
    UIView *borderView = [[UIView alloc] initWithFrame:img.frame];
    borderView.backgroundColor = bColor;
    borderView.tag = 2702;
    [borderView.layer setMasksToBounds:YES];
    
    borderView.translatesAutoresizingMaskIntoConstraints = NO;
    [img.superview insertSubview:borderView belowSubview:img];
    CGSize borderSize = CGSizeMake(img.frame.size.width+bWidth, img.frame.size.height+bWidth);
    [borderView sdc_pinSize:borderSize];
    [borderView sdc_alignHorizontalCenterWithView:img];
    [borderView sdc_alignVerticalCenterWithView:img];
    borderView.layer.cornerRadius = borderSize.width / 2;
}

-(NSString*)getFontStyleWithText:(NSString *)theText andColor:(NSString*)theColor{
    return [NSString stringWithFormat:@"<font name='%@' color='%@'>%@</font>", InterfaceStr(@"default_font_medium"), theColor, theText];

}

-(BOOL)shadowUsedForAllLabels{
    return YES;
}

-(void)addShadowToLayer:(CALayer *)layer{
    if([self shadowUsedForAllLabels]){
        layer.shadowColor = InterfaceColor(@"label_shadow_color").CGColor;
        layer.shadowOpacity = InterfaceFloat(@"label_shadow_opacity");
        layer.shadowRadius = InterfaceFloat(@"label_shadow_radius");
        layer.shadowOffset = CGSizeMake(0.0, 1.0);
        layer.masksToBounds = NO;
        layer.shouldRasterize = YES;
    }
}

-(void)addShadowToLayerForEventDetails:(CALayer *)layer{
    if([self shadowUsedForAllLabels]){
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOpacity = 0.4;
        layer.shadowRadius = 1;
        layer.shadowOffset = CGSizeMake(0.0, 1.0);
        layer.masksToBounds = NO;
        layer.shouldRasterize = YES;
    }
}

-(NSAttributedString *)processedHTMLString:(NSString *)str andFontSize:(int)fontSize{
    NSNumber *fSize = fontSize ? @(fontSize) : @(12);
    NSAttributedString *as = [[[DTHTMLAttributedStringBuilder alloc]
                               initWithHTML:[str dataUsingEncoding:NSUnicodeStringEncoding]
                               options:@{
                                         DTDefaultFontSize: fSize,
                                         DTDefaultFontFamily: InterfaceStr(@"default_font_regular"),
                                         }
                               documentAttributes:NULL] generatedAttributedString];
    return as;
}

-(NSAttributedString *)processedOHHTMLString:(NSString *)str andFontSize:(int)fontSize{

    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:InterfaceStr(@"default_font_regular") size:fontSize], NSForegroundColorAttributeName : [UIColor blackColor],
                                 NSParagraphStyleAttributeName:style};
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str attributes:attributes];
    return attributedString;
}



@end
