//
//  BTSManager.h
//  BTSTest
//
//  Created by Javi on 13/5/15.
//  Copyright (c) 2015 Javier Loucim. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const BTSdidFinishDownloadEvent;
extern NSString * const BTSdownloadProgressUpdatedEvent;

@protocol BTSManagerDelegate <NSObject>

@optional

-(void) downloadProgressUpdated;
-(void) didFinishDownload;

@end


@interface BTSManager : NSObject <NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate, NSURLSessionDelegate>


@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;

@property (nonatomic, strong) NSURL *savedURL;

@property (nonatomic) float progress;
@property (nonatomic, weak) id delegate;


- (id) initWithUrlString: (NSString *) urlString ;

@end
