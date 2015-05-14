//
//  ViewController.m
//  BTSTest
//
//  Created by Javi on 13/5/15.
//  Copyright (c) 2015 Javier Loucim. All rights reserved.
//

#import "ViewController.h"
#import "BTSManager.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize progress,label;

BTSManager *downloadManager;

NSString *fileToDownload;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.progress.progress = 0;
    self.progress.hidden = YES;
  
//    fileToDownload = @"http://www.nhc.noaa.gov/tafb_latest/USA_latest.pdf";
    fileToDownload = @"https://archive.org/details/1mbFile";
//    fileToDownload = @"https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/ObjC_classic/FoundationObjC.pdf";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startButton:(id)sender {

    if (!downloadManager) {
        downloadManager = [[BTSManager alloc] initWithUrlString:fileToDownload];
        downloadManager.delegate = self;
    }
    [downloadManager.task resume];
    progress.hidden = NO;
    
    label.text = @"Downloading";
}

- (void) downloadProgressUpdated {
    NSLog(@"ViewController downloadProgressUpdated %f", downloadManager.progress);
    progress.progress = downloadManager.progress;
    label.text = [NSString stringWithFormat:@"%g%%",downloadManager.progress*100];
}

- (void) didFinishDownload {
    NSLog(@"ViewController didFinishDownload");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *attributesError = nil;
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:[downloadManager.savedURL path] error:&attributesError];
    
    if (attributesError) {
        NSLog(@"error: %@",[attributesError localizedDescription]);
    }
    
    NSLog(@"file saved at: %@",[[downloadManager.savedURL absoluteString] lastPathComponent] );
    progress.progress = 1;
    label.text = [NSString stringWithFormat:@"file has %llu bytes",[attributes fileSize]];
}

@end
