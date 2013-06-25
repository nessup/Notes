//
//  AROverlayExample
//
//  Created by Jason Job on 11-04-11.
//  Copyright 2011 BitCatapult. All rights reserved.
//
//  This class is adapted from https://github.com/jj0b/AROverlayExample

#import "CaptureSessionManager.h"


@implementation CaptureSessionManager


#pragma mark Capture Session Configuration

- (id)init {
	if ((self = [super init])) {
		[self setCaptureSession:[[AVCaptureSession alloc] init]];
	}
	return self;
}

- (void)addVideoInput {
	AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if (videoDevice) {
		NSError *error;
		AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
		if (!error) {
			if ([self.captureSession canAddInput:videoIn])
				[self.captureSession addInput:videoIn];
			else
				NSLog(@"Couldn't add video input");
            
		}
		else
			NSLog(@"Couldn't create video input");
	}
	else
		NSLog(@"Couldn't create video capture device");
}

- (void)setOrientation:(AVCaptureVideoOrientation)orientation
{
    if( [[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0 ) {
        self.previewLayer.connection.videoOrientation = orientation;
    }
    else {
        self.previewLayer.orientation = orientation;
    }
}

- (void)setPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer
{
    _previewLayer = previewLayer;
    
    _previewLayer.session = self.captureSession;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.opaque = YES;
}

- (void)dealloc
{
	[self.captureSession stopRunning];
    self.previewLayer.session = nil;
    self.previewLayer = nil;
}

@end
