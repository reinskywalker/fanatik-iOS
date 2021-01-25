//
//  SectionModel.h
//  Spaace
//
//  Created by Erick Martin on 12/12/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SectionModel : BaseModel

-(id)initWithFMResultSet:(FMResultSet *)result;
-(id)initWithCoder:(NSCoder *)decoder;
-(void)encodeWithCoder:(NSCoder *)encoder;

@property (nonatomic, assign) int sectionId;
@property (nonatomic, copy) NSString *sectionName;
@property (nonatomic, retain) UIView *sectionView;
@property (nonatomic, retain) NSArray *cellArray;

@end