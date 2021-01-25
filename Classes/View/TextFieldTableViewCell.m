//
//  TextFieldTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/29/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "TextFieldTableViewCell.h"

@implementation TextFieldTableViewCell

@synthesize delegate;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];   
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.myTextField.secureTextEntry = self.isSecure;
    self.myTextField.placeholder = self.placeHolder;
    self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if([delegate respondsToSelector:@selector(textFieldTableViewCell:shouldChangeCharactersInRange:replacementString:)]){
        [delegate textFieldTableViewCell:self shouldChangeCharactersInRange:range replacementString:string];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if([delegate respondsToSelector:@selector(textFieldTableViewCell:textFieldDidBeginEditing:)]){
        [delegate textFieldTableViewCell:self textFieldDidBeginEditing:textField];
        
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if([delegate respondsToSelector:@selector(textFieldTableViewCell:textFieldDidEndEditing:)]){
        [delegate textFieldTableViewCell:self textFieldDidEndEditing:textField];
    }
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    if([delegate respondsToSelector:@selector(textFieldTableViewCell:textFieldShouldClear:)]){
        [delegate textFieldTableViewCell:self textFieldShouldClear:textField];
    }
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if([delegate respondsToSelector:@selector(textFieldTableViewCell:textFieldShouldEndEditing:)]){
        [delegate textFieldTableViewCell:self textFieldShouldEndEditing:textField];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([delegate respondsToSelector:@selector(textFieldTableViewCell:textFieldShouldReturn:)]){
        [delegate textFieldTableViewCell:self textFieldShouldReturn:textField];
        
    }
    return YES;
}


@end
