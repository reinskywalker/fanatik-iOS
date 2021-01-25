//

//  DatabaseManager.h
//
//
//  Created by Teguh Hidayatullah 13/November/2014
//

#import "DatabaseManager.h"
#import <RestKit/RestKit.h>

@implementation DatabaseManager

SYNTHESIZE_SINGLETON_FOR_CLASS(DatabaseManager)
@synthesize managedObjectStore, managedObjectContext;
@synthesize localDB, databaseName, databasePath, queue;

#pragma mark - Local Database
-(id)init {
    if (self = [super init]) {
        self.queue = [FMDatabaseQueue databaseQueueWithPath:[self databasePath]];
        [self updateLocalDatabase];
    }
    return self;
}

-(NSString *)databasePath{
    [self createEditableCopyOfDatabaseIfNeeded];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return [documentsDirectory stringByAppendingPathComponent:@"LocalDatabase.sqlite"];
}

- (void)createEditableCopyOfDatabaseIfNeeded {
    
    BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"LocalDatabase.sqlite"];
    
    success = [fileManager fileExistsAtPath:writableDBPath];
    NSLog(@"WRITABLE DB PATH: %@",writableDBPath);
    if (success) return;
    
    //The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LocalDatabase.sqlite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

-(void)updateLocalDatabase{
    ApplicationMenuModel *newMenu = [[ApplicationMenuModel alloc] init];
    newMenu.pageCode = @"Page-46";
    newMenu.pageName = @"Contest List";
    newMenu.pageTitle = @"Contest";
    
    ApplicationMenuModel *newMenu2 = [[ApplicationMenuModel alloc] init];
    newMenu2.pageCode = @"Page-47";
    newMenu2.pageName = @"Contest Details";
    newMenu2.pageTitle = @"Contest Details";
    
    ApplicationMenuModel *newMenu3 = [[ApplicationMenuModel alloc] init];
    newMenu3.pageCode = @"Page-48";
    newMenu3.pageName = @"Contest Upload";
    newMenu3.pageTitle = @"Upload";
    
    ApplicationMenuModel *newMenu4 = [[ApplicationMenuModel alloc] init];
    newMenu4.pageCode = @"Page-49";
    newMenu4.pageName = @"Live Chat";
    newMenu4.pageTitle = @"Live Chat";
    
    ApplicationMenuModel *newMenu5 = [[ApplicationMenuModel alloc] init];
    newMenu5.pageCode = @"Page-50";
    newMenu5.pageName = @"Broadcast Detail";
    newMenu5.pageTitle = @"Broadcast Detail";
    
    ApplicationMenuModel *newMenu6 = [[ApplicationMenuModel alloc] init];
    newMenu6.pageID = 24;
    newMenu6.pageCode = @"Page-24";
    newMenu6.pageName = @"My Packages";
    newMenu6.pageTitle = @"My Packages";
    
    ApplicationMenuModel *newMenu7 = [[ApplicationMenuModel alloc] init];
    newMenu7.pageID = 27;
    newMenu7.pageCode = @"Page-27";
    newMenu7.pageName = @"TV Channel";
    newMenu7.pageTitle = @"TV Channel";
    
    ApplicationMenuModel *newMenu8 = [[ApplicationMenuModel alloc] init];
    newMenu8.pageID = 28;
    newMenu8.pageCode = @"Page-28";
    newMenu8.pageName = @"TV Channel";
    newMenu8.pageTitle = @"TV Channel";
    
    ApplicationMenuModel *newMenu9 = [[ApplicationMenuModel alloc] init];
    newMenu9.pageID = 51;
    newMenu9.pageCode = @"Page-51";
    newMenu9.pageName = @"Event";
    newMenu9.pageTitle = @"Event";
    
    ApplicationMenuModel *newMenu10 = [[ApplicationMenuModel alloc] init];
    newMenu10.pageID = 52;
    newMenu10.pageCode = @"Page-52";
    newMenu10.pageName = @"Event Detail";
    newMenu10.pageTitle = @"Event detail";
    
    ApplicationMenuModel *newMenu11 = [[ApplicationMenuModel alloc] init];
    newMenu11.pageID = 53;
    newMenu11.pageCode = @"Page-53";
    newMenu11.pageName = @"Notifications";
    newMenu11.pageTitle = @"Notifications";
    
    [self insertApplicationMenu:newMenu];
    [self insertApplicationMenu:newMenu2];
    [self insertApplicationMenu:newMenu3];
    [self insertApplicationMenu:newMenu4];
    [self insertApplicationMenu:newMenu5];
    [self updateApplicationMenu:newMenu6];
    [self updateApplicationMenu:newMenu7];
    [self updateApplicationMenu:newMenu8];
    [self insertApplicationMenu:newMenu9];
    [self insertApplicationMenu:newMenu10];
    [self insertApplicationMenu:newMenu11];
    
    [self createUserUploadTable];
    [self createNewStickerTable];
}

#pragma mark - Local Database Query
-(ApplicationMenuModel *)getApplicationMenudByPageCode:(NSString *)pageCode{
    __block ApplicationMenuModel *obj;
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM ApplicationPage WHERE pageCode = ?",pageCode];
        if ([rs next]) {
            obj = [[ApplicationMenuModel alloc] initWithFMResultSet:rs];
        }
        [rs close];
    }];
    
    return obj;
}

-(void)insertApplicationMenu:(ApplicationMenuModel *)obj{
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        FMResultSet *rs1 = [db executeQuery:@"SELECT * FROM ApplicationPage WHERE pageCode = ?",obj.pageCode];
        if (![rs1 next]) {
            BOOL success = NO;
            success = [db executeUpdate:@"INSERT INTO ApplicationPage (pageCode, pageName, pageTitle) VALUES (?, ?, ?)", obj.pageCode,obj.pageName,obj.pageTitle];
            if(!success){
                NSLog(@"%s: %@", __FUNCTION__, [db lastErrorMessage]);
                
                *rollback = YES;
                return;
            }
        }
    }];
}

-(void)updateApplicationMenu:(ApplicationMenuModel *)obj{
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        FMResultSet *rs1 = [db executeQuery:@"SELECT * FROM ApplicationPage WHERE pageCode = ?",obj.pageCode];
        if ([rs1 next]) {
            BOOL success = NO;
            success = [db executeUpdate:@"UPDATE ApplicationPage SET pageCode=?, pageName=?, pageTitle=? WHERE pageID=?", obj.pageCode,obj.pageName,obj.pageTitle, @(obj.pageID)];
            if(!success){
                NSLog(@"%s: %@", __FUNCTION__, [db lastErrorMessage]);
                
                *rollback = YES;
                return;
            }
        }
        
    }];
}

-(void)createUserUploadTable{
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        BOOL success = NO;
        success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS UserUploadsModel(user_uploads_id TEXT, user_uploads_title TEXT, user_uploads_video_url_local TEXT, user_uploads_status INT, clip_category_string TEXT, user_upload_percentage DOUBLE)"];
        
        if(!success){
            BOOL success2 = NO;
            success2 = [db executeUpdate:@"ALTER TABLE UserUploadsModel ADD user_upload_percentage DOUBLE"];
        }
    }];
}

-(void)createNewStickerTable{
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        BOOL success = NO;
        success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS StickerCategory(stickerCategoryId INT, name TEXT, visible_at DATE, enable_at DATE)"];
        if (success) {
            BOOL success2 = NO;
            success2 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS Sticker(stickerId INT, artist_id INT, name TEXT, code TEXT, visible_at DATE, enable_at DATE, file TEXT, stickerCategoryId INT)"];
            
            if (success2) {
                BOOL success3 = NO;
                success3 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS Pricing(pricingId INT, type TEXT, priced_type TEXT, stickerId INT, price TEXT, duration INT,  volume INT, info TEXT, price_str TEXT, price_int INT)"];
            }
        }
        
    }];

}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    managedObjectContext = [self managedObjectStore].mainQueueManagedObjectContext;
    
    return managedObjectContext;
}

- (RKManagedObjectStore *)managedObjectStore{
    
    if(managedObjectStore != nil){
        return managedObjectStore;
    }
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    NSError *error = nil;
    BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
    if (! success) {
        RKLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
    }
    
    NSString *stringDBName = @"Fanatik.sqlite";
    NSString *dirData = [TheAppDelegate pathCentralData];
    [TheAppDelegate createCentralDataIfDoesntExist];
    
    NSString *path = [dirData stringByAppendingPathComponent:stringDBName];
    
    NSDictionary *option = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                            [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSPersistentStore __unused *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:option error:&error];
    if (error) {
        
        [[NSFileManager defaultManager] removeItemAtPath:path
                                                   error:nil];
        
        NSPersistentStore __unused *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:nil];
        
        
        
        RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
    }
    

    [managedObjectStore createManagedObjectContexts];
    return managedObjectStore;
}

- (void)deleteAllObjectsFrom:(NSString*)entity
                   inContext:(NSManagedObjectContext*)context {
    
    NSFetchRequest *request;
    request = [NSFetchRequest fetchRequestWithEntityName:entity];
    request.entity = [NSEntityDescription entityForName:entity
                                 inManagedObjectContext:context];
    
    NSError *error = nil;
    NSArray *entityObjects = [context executeFetchRequest:request
                                                    error:&error];
    
    for (NSManagedObject *object in entityObjects) {
        [context deleteObject:object];
        NSLog(@"\n\nDeleted: \n\n%@.", object);
    }
    
    NSError *saveError = nil;
    [context save:&saveError];
//    [context saveToPersistentStore:nil];
}

#pragma mark - UserUploadsModel

-(BOOL)updateUserUploadsModel:(UserUploadsModel *)obj{
    __block BOOL success = NO;
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        [db executeUpdate:@"DELETE FROM 'UserUploadsModel' WHERE user_uploads_id=?",obj.user_uploads_id];
        success = [db executeUpdate:@"INSERT INTO UserUploadsModel(user_uploads_id,user_uploads_title,user_uploads_video_url_local,user_uploads_status, clip_category_string, user_upload_percentage) values(?,?,?,?,?,?)", obj.user_uploads_id,obj.user_uploads_title,obj.user_uploads_video_url_local, @(obj.user_uploads_status), obj.clip_category_string, @(obj.user_upload_percentage)];
    }];
    return success;
}


-(NSArray *)getAllUserUploadsModels{
    __block NSMutableArray *result = [NSMutableArray array];
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM UserUploadsModel"];
        
        FMResultSet *rs = [db executeQuery:queryString];
        while([rs next]) {
            UserUploadsModel *useruploadsmodel = [[UserUploadsModel alloc] initWithFMResultSet:rs];
            [result addObject:useruploadsmodel];
        }
    }];
    
    return result;
}

-(NSArray *)getUserUploadsModelsInProgress{
    __block NSMutableArray *result = [NSMutableArray array];
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM UserUploadsModel WHERE user_uploads_status = %d", UseruploadStatusOnProgress];
        
        FMResultSet *rs = [db executeQuery:queryString];
        while([rs next]) {
            UserUploadsModel *useruploadsmodel = [[UserUploadsModel alloc] initWithFMResultSet:rs];
            [result addObject:useruploadsmodel];
        }
    }];
    
    return result;
}

-(NSArray *)getUserUploadsModelsSuccess{
    __block NSMutableArray *result = [NSMutableArray array];
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM UserUploadsModel WHERE user_uploads_status = %d", UserUploadStatusSuccess];
        
        FMResultSet *rs = [db executeQuery:queryString];
        while([rs next]) {
            UserUploadsModel *useruploadsmodel = [[UserUploadsModel alloc] initWithFMResultSet:rs];
            [result addObject:useruploadsmodel];
        }
    }];
    
    return result;
}

-(void)deleteAllUserUploadsModels{
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"DELETE FROM UserUploadsModel"];
    }];
}

-(BOOL)deleteUserUploadsModel:(UserUploadsModel *)obj{
    __block BOOL success = NO;
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        success = [db executeUpdate:@"DELETE FROM 'UserUploadsModel' WHERE user_uploads_id=?",obj.user_uploads_id];
    }];
    return success;
}

-(UserUploadsModel *)getUserUploadsModelById:(NSString *)primaryId{
    __block UserUploadsModel *result = nil;
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM UserUploadsModel WHERE user_uploads_id='%@'", primaryId];
        FMResultSet *rs = [db executeQuery:queryString];
        if([rs next]) {
            result = [[UserUploadsModel alloc] initWithFMResultSet:rs];
        }
    }];
    
    return result;
}

#pragma mark - StickerCategory


-(BOOL)updateStickerCategory:(StickerCategory *)obj{
    __block BOOL success = NO;
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        [db executeUpdate:@"DELETE FROM 'StickerCategory' WHERE stickerCategoryId=?",@(obj.stickerCategoryId)];
        success = [db executeUpdate:@"INSERT INTO StickerCategory(stickerCategoryId,name,visible_at,enable_at) values(?,?,?,?)", @(obj.stickerCategoryId),obj.name,obj.visible_at,obj.enable_at];
    }];
    return success;
}


-(NSArray *)getAllStickerCategorys{
    __block NSMutableArray *result = [NSMutableArray array];
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM StickerCategory"];
        
        while([rs next]) {
            StickerCategory *stickercategory = [[StickerCategory alloc] initWithFMResultSet:rs];
            
            
            FMResultSet *rs2 = [db executeQuery:@"SELECT * FROM Sticker WHERE stickerCategoryId=?", @(stickercategory.stickerCategoryId)];
            
            NSMutableArray *stickerResult = [NSMutableArray array];
            while([rs2 next]) {
                Sticker *sticker = [[Sticker alloc] initWithFMResultSet:rs2];
                
                
                FMResultSet *rs3 = [db executeQuery:@"SELECT * FROM Pricing WHERE stickerId=?", @(sticker.stickerId)];
                
                NSMutableArray *pricingResult = [NSMutableArray array];
                while([rs3 next]) {
                    Pricing *pricing = [[Pricing alloc] initWithFMResultSet:rs3];
                    [pricingResult addObject:pricing];
                }
                
                sticker.pricingArray = [NSMutableArray arrayWithArray:pricingResult];
                
                [stickerResult addObject:sticker];
            }
            
            stickercategory.stickerArray = [NSMutableArray arrayWithArray:stickerResult];
            
            [result addObject:stickercategory];
        }
    }];
    
    return result;
}


-(void)deleteAllStickerCategorys{
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"DELETE FROM StickerCategory"];
    }];
}


-(StickerCategory *)getStickerCategoryById:(int)primaryId{
    __block StickerCategory *result = nil;
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM StickerCategory WHERE stickerCategoryId=%@", @(primaryId)];
        FMResultSet *rs = [db executeQuery:queryString];
        if([rs next]) {
            result = [[StickerCategory alloc] initWithFMResultSet:rs];
        }
    }];
    
    return result;
}

#pragma mark - Sticker


-(BOOL)updateSticker:(Sticker *)obj{
    __block BOOL success = NO;
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        [db executeUpdate:@"DELETE FROM 'Sticker' WHERE stickerId=? AND stickerCategoryId=?", @(obj.stickerId), @(obj.stickerCategoryId)];
        
        success = [db executeUpdate:@"INSERT INTO Sticker(stickerId,artist_id,code,name,visible_at,enable_at,file,stickerCategoryId) values(?,?,?,?,?,?,?,?)", @(obj.stickerId),@(obj.artist_id),obj.code,obj.name,obj.visible_at,obj.enable_at,obj.file,@(obj.stickerCategoryId)];
    }];
    return success;
}


-(NSArray *)getAllStickersByStickerCategoryId:(int)catId{
    __block NSMutableArray *result = [NSMutableArray array];
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM Sticker WHERE stickerCategoryId=?", @(catId)];
        
        while([rs next]) {
            Sticker *sticker = [[Sticker alloc] initWithFMResultSet:rs];
            [result addObject:sticker];
        }
    }];
    
    return result;
}


-(void)deleteAllStickers{
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"DELETE FROM Sticker"];
    }];
}


-(Sticker *)getStickerById:(int)primaryId{
    __block Sticker *result = nil;
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM Sticker WHERE stickerId=%@", @(primaryId)];
        FMResultSet *rs = [db executeQuery:queryString];
        if([rs next]) {
            result = [[Sticker alloc] initWithFMResultSet:rs];
        }
    }];
    
    return result;
}

#pragma mark - Pricing
-(BOOL)updatePricing:(Pricing *)obj{
    __block BOOL success = NO;
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        [db executeUpdate:@"DELETE FROM 'Pricing' WHERE pricingId=? AND stickerId=?", @(obj.pricingId), @(obj.stickerId)];
        success = [db executeUpdate:@"INSERT INTO Pricing(pricingId,type,priced_type,stickerId,price,duration,volume,info,price_str,price_int) values(?,?,?,?,?,?,?,?,?,?)", @(obj.pricingId),obj.type,obj.priced_type,@(obj.stickerId),obj.price,@(obj.duration),@(obj.volume),obj.info,obj.price_str,@(obj.price_int)];
    }];
    return success;
}


-(NSArray *)getAllPricings{
    __block NSMutableArray *result = [NSMutableArray array];
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM Pricing"];
        
        while([rs next]) {
            Pricing *pricing = [[Pricing alloc] initWithFMResultSet:rs];
            [result addObject:pricing];
        }
    }];
    
    return result;
}


-(void)deleteAllPricings{
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"DELETE FROM Pricing"];
    }];
}


-(Pricing *)getPricingById:(int)primaryId{
    __block Pricing *result = nil;
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM Pricing WHERE pricingId=%@", @(primaryId)];
        FMResultSet *rs = [db executeQuery:queryString];
        if([rs next]) {
            result = [[Pricing alloc] initWithFMResultSet:rs];
        }
    }];
    
    return result;
}

@end

