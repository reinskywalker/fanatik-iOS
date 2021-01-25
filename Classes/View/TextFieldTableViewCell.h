//
//  TextFieldTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/29/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TextFieldTableViewCell;
@protocol TextFieldTableViewCellDelegate <NSObject>

@optional
-(BOOL)textFieldTableViewCell:(TextFieldTableViewCell *)cell shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
-(void)textFieldTableViewCell:(TextFieldTableViewCell *)cell textFieldDidBeginEditing:(UITextField *)textField;
-(void)textFieldTableViewCell:(TextFieldTableViewCell *)cell textFieldDidEndEditing:(UITextField *)textField;
-(BOOL)textFieldTableViewCell:(TextFieldTableViewCell *)cell textFieldShouldClear:(UITextField *)textField;
-(BOOL)textFieldTableViewCell:(TextFieldTableViewCell *)cell textFieldShouldEndEditing:(UITextField *)textField;
-(BOOL)textFieldTableViewCell:(TextFieldTableViewCell *)cell textFieldShouldReturn:(UITextField *)textField;
@end



@interface TextFieldTableViewCell : UITableViewCell<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet CustomMediumTextField *myTextField;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *textLabel;
@property (nonatomic, assign) BOOL isSecure;
@property (nonatomic, copy) NSString *placeHolder;
@property (nonatomic, copy) NSString *myID;

@property (nonatomic, weak) id <TextFieldTableViewCellDelegate> delegate;

+(NSString *)reuseIdentifier;
@end
