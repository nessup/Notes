//
//  AROverlayExample
//
//  Created by Jason Job on 11-04-11.
//  Copyright 2011 BitCatapult. All rights reserved.
//
//  This class is adapted from https://github.com/jj0b/AROverlayExample
//
//
//  Modified by Abdallah Elguindy on 8/17/12.
//
//  This is the main UIView displaying avatars, information
//  and other UI elements, for example, distance lines.
//


#import <UIKit/UIKit.h>

#import "CaptureSessionManager.h"
#import <CoreLocation/CoreLocation.h>
#import "ARDrawingManager.h"


@interface AROverlayViewController : UIViewController <
    CLLocationManagerDelegate,
    ARDrawingManagerDelegate>

//  Diplaying the camera preview in the background.
@property (nonatomic, strong) CaptureSessionManager *captureManager;

- (void)handleData:(NSMutableArray *)data;

@end
