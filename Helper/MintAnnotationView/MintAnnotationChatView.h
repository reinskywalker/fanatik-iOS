//
//  MintAnnotationView.h
//  MintAnnotationView
//
//  Created by soleaf on 13. 8. 26..
//  Mintcode.org
//  http://www.mintcode.org/
//  Repository : https://github.com/soleaf/MintAnnotationView
//

#import <UIKit/UIKit.h>
#import "MintAnnotation.h"

@interface MintAnnotationChatView : UITextView <UITextViewDelegate>

@property (nonatomic, retain) UIColor      *nameTagColor;
@property (nonatomic, retain) UIColor        *nameTagLineColor;
@property (nonatomic, retain) NSMutableArray *annotationList;
@property (nonatomic, retain) UIImage        *nameTagImage;

// Add new Anotation
// info should include 'MintAnnotationInfoID', 'MintAnnotationInfoName'
//              MintAnnotationInfoID   = Unique Identifier to disturb dobule inserting same info.
//              MintAnnotationInfoName = Appeared name in view.
- (void) addAnnotation:(MintAnnotation*)annoatin;

/*
 With taggedText like "<u uid=22>Sally</u> hello sally?!"
 , This appeared "hello sally?!" include annoatation informations.(annoationList)
 */
- (NSString *)setTextWithTageedString:(NSString *)memo;


// Should Use on textViewDelegate on viewController
/* EX)
     - (void)textViewDidChange:(UITextView *)textView
     {
        [self.annotationView checkTagDeleting];
     }
 */
- (BOOL) shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;


/*
 Make string with tag information
 ex ) hi <u id="1">Sally</u> good morning.
 tagIdKey = id
 */
- (NSString*) makeStringWithTag;


/*
 Make s tring without tag strign
 ex ) hi good mornig.  (removed 'Sally' annotation tag text)
 */
- (NSString*) makeStringWithoutTagString;


/*
 remove text and attributes and annotationList
 */
- (void) clearAll;

@end
