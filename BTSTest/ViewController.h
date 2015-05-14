//
//  ViewController.h
//  BTSTest
//
//  Created by Javi on 13/5/15.
//  Copyright (c) 2015 Javier Loucim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTSManager.h"

@interface ViewController : UIViewController  <BTSManagerDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

