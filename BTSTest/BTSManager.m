//
//  BTSManager.m
//  BTSTest
//
//  Created by Javi on 13/5/15.
//  Copyright (c) 2015 Javier Loucim. All rights reserved.
//

#import "BTSManager.h"

@implementation BTSManager

NSString * const BTSdidFinishDownloadEvent = @"BTSdidFinishDownloadEvent";
NSString * const BTSdownloadProgressUpdatedEvent = @"BTSdownloadProgressUpdatedEvent";

- (id) initWithUrlString: (NSString *) urlString {
    
    if (self) {
        self.urlString = urlString;
        if (!self.session) {
            self.session = [self getBackgroundSession];
            
            self.task = [[NSURLSessionDownloadTask alloc] init];
            
            if (self.task) {
                self.progress = 0;
                [self dispatchProgressUpdateEvent];
                
                [self startDownload];
                
            }
        }
    }
    return self;
}
#pragma mark - Delegates
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
    NSLog(@"BTSManager task is finished (progress was: %f)",self.progress);
    
    if (self.progress < 1) {
        NSLog(@"BTSManager resuming...");
        [self startDownload];
//        [self.task resume];
    }
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
//    if (downloadTask == self.task) {
        if (self.progress >= 1) {
            self.savedURL = [self saveFile:location];

            [self dispatchdidFinishDownloadEvent];
        }
//    } else {
//        NSLog(@"BTSManager something else has been completed! %@ vs %@", downloadTask, self.task);
//    }

    
    //TODO: decide what to do with data downloaded
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
//    if (downloadTask == self.task) {
        self.progress = (float) totalBytesWritten/totalBytesExpectedToWrite;
        NSLog(@"BTSManager DownloadTask: %@ totalBytesWritten: %lld totalBytesExpectedToWrite: %lld / progress: %f", downloadTask, totalBytesExpectedToWrite,totalBytesWritten,self.progress);
        [self dispatchProgressUpdateEvent];
//    } else {
//        NSLog(@"BTSManager DownloadTask is something different than me");
//    }
    
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
    //TODO: decide if continue if its configured to use onlyWifi
    NSLog(@"BTSManager resumeAtOffset %lld",fileOffset);
}

#pragma mark - Helpers

- (NSURL *) saveFile: (NSURL*) downloadURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [URLs objectAtIndex:0];
    
    NSURL *originalURL = [[self.task originalRequest] URL];
    NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
    NSError *errorCopy;
    
    // For the purposes of testing, remove any esisting file at the destination.
    [fileManager removeItemAtURL:destinationURL error:NULL];
    [fileManager copyItemAtURL:downloadURL toURL:destinationURL error:&errorCopy];
    
    if (errorCopy) {
        NSLog(@"BTSManager saveFile error: %@",[errorCopy localizedDescription]);
    }
    
    return destinationURL;
}

- (void) startDownload {
    NSURL *requestURL = [NSURL URLWithString:self.urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    
    if (self.task) self.task = nil;
    
    self.task = [self.session downloadTaskWithRequest:request];
    [self.task resume];
    NSLog(@"BTSManager url:%@",self.urlString);
    
}

- (void) dispatchdidFinishDownloadEvent {
    NSLog(@"BTSManager Download completed!");
    if ([self.delegate respondsToSelector:@selector(didFinishDownload)]) {
        [self.delegate didFinishDownload];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BTSdidFinishDownloadEvent object:self];

}

- (void) dispatchProgressUpdateEvent {
    if ([self.delegate respondsToSelector:@selector(downloadProgressUpdated)]) {
        [self.delegate downloadProgressUpdated];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BTSdownloadProgressUpdatedEvent object:self];
    
}
- (NSURLSession *) getBackgroundSession {
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSLog(@"BTSManager init");
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier: [[NSBundle mainBundle] bundleIdentifier]];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue new]];
    });
    return session;
}


@end
