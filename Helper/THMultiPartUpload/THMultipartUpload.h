//
//  THMultipartUpload.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 9/7/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THAWSAuthorization.h"
@class THMultipartUpload;
@protocol THMultipartUploadDelegate <NSObject>

-(void)THMultipartUploadDelegate:(THMultipartUpload *)uploader URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session;

-(void)THMultipartUploadDelegate:(THMultipartUpload *)uploader URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;

-(void)THMultipartUploadDelegate:(THMultipartUpload *)uploader URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;

-(void)THMultipartUploadDelegate:(THMultipartUpload *)uploader didStartUploadingFileWithNumberOfParts:(NSInteger)numberOfParts;

-(void)THMultipartUploadDelegate:(THMultipartUpload *)uploader didUploadPartNumber:(NSInteger)partNumber etag:(NSString *)etag;

@end
@interface THMultipartUpload : NSObject<NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (strong, nonatomic) NSURLSession *currentSession;
@property (strong, nonatomic) NSURLSessionUploadTask *uploadTask;
@property (nonatomic, weak) id <THMultipartUploadDelegate> delegate;
@property (nonatomic, copy) NSString *uploadURL;


- (void)initiateMultipartUploadWithURL:(NSString *)s3URL path:(NSString *)awsPath bucket:(NSString *)bucketName  fileName:(NSString *)awsFileName completion: (void(^) (NSString *uploadID))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)uploadFileAtUrl:(NSURL *)filePathUrl fileExtension:(NSString *)format withUploadID:(NSString *)upID toS3URL:(NSString *)awsURLString;
@end
