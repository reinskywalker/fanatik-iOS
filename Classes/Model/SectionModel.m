//
//  SectionModel.m
//  Spaace
//
//  Created by Erick Martin on 12/12/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "SectionModel.h"
@implementation SectionModel

@synthesize sectionId, sectionName, sectionView, cellArray;

-(id)initWithFMResultSet:(FMResultSet *)result{
    if(self = [super init]){
        self.sectionId = [result intForColumn:@"sectionId"];
        self.sectionName = [result stringForColumn:@"sectionName"];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)decoder{
    if(self=[super init]){
        self.sectionId = [decoder decodeIntForKey:@"sectionId"];
        self.sectionName = [decoder decodeObjectForKey:@"sectionName"];
    }
    return self;
}


-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeInt:self.sectionId forKey:@"sectionId"];
    [encoder encodeObject:self.sectionName forKey:@"sectionName"];
}

@end