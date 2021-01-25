//
//  THMultipartUpload.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 9/7/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "THMultipartUpload.h"
#import "GDataXMLNode.h"


@interface THMultipartUpload(){
    int partCount;
    NSString *mimeType;
    NSString *fileExtension;
    NSString *tempFileName;
    NSString *tempFilePath;
}
@property (nonatomic, retain) NSURL *fileURL;
@property (nonatomic, strong) NSMutableSet *outstandingPartNumbers;
@property (nonatomic, copy) NSString *uploadID;
@property (nonatomic, copy) NSString *s3URL;
@property (nonatomic, copy) NSString *awsPath;
@property (nonatomic, copy) NSString *bucketName;
@property (nonatomic, copy) NSString *fileName;

@end

@implementation THMultipartUpload



const int PART_SIZE = (5 * 1024 * 1024); // 5MB is the smallest part size allowed for a multipart upload. (Only the last part can be smaller.)

@synthesize delegate, currentSession, uploadTask, outstandingPartNumbers, uploadID;

#pragma mark - Upload Notification Handler

- (void)initiateMultipartUploadWithURL:(NSString *)s3URL path:(NSString *)awsPath bucket:(NSString *)bucketName  fileName:(NSString *)awsFileName completion: (void(^) (NSString *uploadID))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{

    self.s3URL = s3URL;
    self.awsPath = awsPath;
    self.bucketName = bucketName;
    self.fileName = awsFileName;
    

    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:s3URL]];
    
    NSDate *ohDate = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"E, dd MMM yyyy HH:mm:ss ZZZZ";
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [df setTimeZone:timeZone];
    NSString *dateString = [df stringFromDate:ohDate];
    
    NSMutableURLRequest *req = [manager requestWithObject:self method:RKRequestMethodPOST path:[NSString stringWithFormat:@"%@%@?uploads",awsPath, awsFileName] parameters:nil];

    [req setValue:[THAWSAuthorization getAuthorizationHeaderForRequestMethod:AWSRequestMethodPOST mimeType:@"" withDate:ohDate bucket:bucketName awsPath:awsPath fileName:awsFileName subresourceDict:@{@"uploads":@""}] forHTTPHeaderField:@"Authorization"];
    [req setValue:dateString forHTTPHeaderField:@"Date"];
    NSLog(@"all header : %@", [req allHTTPHeaderFields]);
    


    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:req];
    [operation start];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [TheAppDelegate writeLog:[operation responseString]];
        NSData *xmlData = [operation responseData];
        NSError *error;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
        if (doc == nil) {
            NSLog(@"parse error :%@",error);
        }

        NSLog(@"doc root emelent : %@", doc.rootElement);
        NSString *xmlString;
        NSArray *results = [doc.rootElement elementsForName:@"UploadId"];
        for (GDataXMLElement *node in results) {
            xmlString = node.stringValue;
        }

        
        
        if(complete){
            complete(xmlString);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [TheAppDelegate writeLog:[error description]];
        if(failure){
            failure(operation, error);
        }
    }];
    
}


- (void)uploadFileAtUrl:(NSURL *)filePathUrl fileExtension:(NSString *)format withUploadID:(NSString *)upID toS3URL:(NSString *)awsURLString{
    self.uploadID = upID;
    fileExtension = format;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kBackgroudSessionUploadIdentifier];
        static NSURLSession *session = nil;
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        self.currentSession = session;
    });
    mimeType = [MimeTypeHelper mimeTypeForFileAtPath:[filePathUrl path]];
    self.fileURL = filePathUrl;
    NSData *fileData = [NSData dataWithContentsOfURL:filePathUrl];
    partCount = [self countParts:fileData];
    NSLog(@"splitted into %d part",partCount);
    if( delegate && [delegate respondsToSelector:@selector(THMultipartUploadDelegate:didStartUploadingFileWithNumberOfParts:)] )
    {
        [delegate THMultipartUploadDelegate:self didStartUploadingFileWithNumberOfParts:partCount];
    }
    [self uploadData:[self getPart:1 fromData:fileData] toURL:awsURLString forPart:1];
}

-(void)uploadData:(NSData *)fileData toURL:(NSString *)awsURLString forPart:(int)part {
    NSDate *ohDate = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"E, dd MMM yyyy HH:mm:ss ZZZZ";
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [df setTimeZone:timeZone];
    NSString *dateString = [df stringFromDate:ohDate];
    
    
    
    NSString *authorizationString = [THAWSAuthorization getAuthorizationHeaderForRequestMethod:AWSRequestMethodPUT mimeType:mimeType withDate:ohDate bucket:self.bucketName awsPath:self.awsPath fileName:self.fileName subresourceDict:@{@"partNumber":[NSString stringWithFormat:@"%d",part], @"uploadId":self.uploadID}];
    
    //save part to disk
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths lastObject];
    tempFileName = [NSString stringWithFormat:@"part%dof%d.%@",part,partCount,fileExtension];

    tempFilePath= [docPath stringByAppendingPathComponent:tempFileName];
    

    [fileData writeToFile:tempFilePath atomically:YES];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:tempFilePath]) {
        NSLog(@"gak ada bos");
        return;
    }

    
    @try
    {
        
        self.uploadURL = [NSString stringWithFormat:@"%@/%@/%@?partNumber=%d&uploadId=%@",self.s3URL, self.awsPath, self.fileName, part, self.uploadID];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.uploadURL]];
        request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        [request setHTTPMethod:@"PUT"];
        [request setValue:authorizationString forHTTPHeaderField:@"Authorization"];
        [request setValue:@"video/quicktime" forHTTPHeaderField:@"Content-Type"];
        [request setValue:dateString forHTTPHeaderField:@"Date"];
        NSLog(@"all header : %@", [request allHTTPHeaderFields]);
        NSString *path = [[NSBundle mainBundle] pathForResource:tempFileName ofType:fileExtension];

        self.uploadTask = [self.currentSession uploadTaskWithRequest:request fromFile:[NSURL URLWithString:path]];
        [self.uploadTask resume];
    }
    @catch ( NSException *exception)
    {
        NSLog( @"General fail: %@", exception );
    }
}

#pragma mark - Convenience Method
-(NSData*)getPart:(int)part fromData:(NSData*)fullData
{
    NSRange range;
    range.length = PART_SIZE;
    range.location = (part - 1) * PART_SIZE;
    
    int maxByte = part * PART_SIZE;
    if ( [fullData length] < maxByte ) {
        range.length = [fullData length] - range.location;
    }
    
    return [fullData subdataWithRange:range];
}

-(int)countParts:(NSData*)fullData
{
    int q = (int)([fullData length] / PART_SIZE);
    int r = (int)([fullData length] % PART_SIZE);
    
    return ( r == 0 ) ? q : q + 1;
}

- (NSString *)fileKeyOnS3:(NSString *)filePath
{
    return [@"direct_uploads" stringByAppendingPathComponent:filePath];
}

- (void)abortUpload
{

}





#pragma mark - NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    
    double progress = (double)totalBytesSent / (double)totalBytesExpectedToSend;
    
    NSLog(@"UploadTask progress: %lf", progress);
    if ([delegate respondsToSelector:@selector(THMultipartUploadDelegate:URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:)]) {
        [delegate THMultipartUploadDelegate:self URLSession:session task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
    }
}



- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if([delegate respondsToSelector:@selector(THMultipartUploadDelegate:URLSession:task:didCompleteWithError:)]){
        [delegate THMultipartUploadDelegate:self URLSession:session task:task didCompleteWithError:error];
    }
    
    self.uploadTask = nil;
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundUploadSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundUploadSessionCompletionHandler;
        appDelegate.backgroundUploadSessionCompletionHandler = nil;
        completionHandler();
    }
    if([delegate respondsToSelector:@selector(THMultipartUploadDelegate:URLSessionDidFinishEventsForBackgroundURLSession:)]){
        [delegate THMultipartUploadDelegate:self URLSessionDidFinishEventsForBackgroundURLSession:session];
    }
}

@end
