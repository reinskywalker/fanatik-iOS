//
//  DatabaseManager.h
//
//
//  Created by Teguh Hidayatullah 13/November/2014
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseQueue.h>
#import "ApplicationMenuModel.h"
#import "UserUploadsModel.h"
#import "Sticker.h"
#import "StickerCategory.h"
#import "Pricing.h"

@class RKManagedObjectStore;

#define TheDatabaseManager ([DatabaseManager sharedInstance])

@interface DatabaseManager : NSObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(DatabaseManager)

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) RKManagedObjectStore *managedObjectStore;
@property(nonatomic, retain) FMDatabase *localDB;
@property(nonatomic, copy) NSString *databasePath;
@property(nonatomic, copy) NSString *databaseName;
@property (nonatomic, retain) FMDatabaseQueue *queue;

-(ApplicationMenuModel *)getApplicationMenudByPageCode:(NSString *)pageCode;

- (void)deleteAllObjectsFrom:(NSString*)entity
                   inContext:(NSManagedObjectContext*)context;

-(BOOL)updateUserUploadsModel:(UserUploadsModel *)obj;
-(NSArray *)getAllUserUploadsModels;
-(NSArray *)getUserUploadsModelsInProgress;
-(NSArray *)getUserUploadsModelsSuccess;
-(void)deleteAllUserUploadsModels;
-(BOOL)deleteUserUploadsModel:(UserUploadsModel *)obj;
-(UserUploadsModel *)getUserUploadsModelById:(NSString *)primaryId;


-(BOOL)updateStickerCategory:(StickerCategory *)obj;
-(NSArray *)getAllStickerCategorys;
-(void)deleteAllStickerCategorys;
-(StickerCategory *)getStickerCategoryById:(int)primaryId;
-(BOOL)updateSticker:(Sticker *)obj;
-(NSArray *)getAllStickersByStickerCategoryId:(int)catId;
-(void)deleteAllStickers;
-(Sticker *)getStickerById:(int)primaryId;
-(BOOL)updatePricing:(Pricing *)obj;
-(NSArray *)getAllPricings;
-(void)deleteAllPricings;
-(Pricing *)getPricingById:(int)primaryId;
@end
