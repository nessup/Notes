//
//  AROverlayExample
//
//  Created by Jason Job on 11-04-11.
//  Copyright 2011 BitCatapult. All rights reserved.
//
//  This class is adapted from https://github.com/jj0b/AROverlayExample

#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>


@interface CaptureSessionManager : NSObject

@property (nonatomic, weak) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoOrientation orientation;

- (void)addVideoInput;

@end
