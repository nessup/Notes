//
//  ARCaptureVideoPreviewView.m
//  AROverlayExample
//
//  Created by Arnold Noronha on 9/29/12.
//
//

#import "ARCaptureVideoPreviewView.h"

#import <AVFoundation/AVFoundation.h>

@interface AVCaptureVideoPreviewLayer (iOS_5_0_Fix)
@end

@implementation AVCaptureVideoPreviewLayer (iOS_5_0_Fix)
- (id)init {
    return [self initWithSession:nil];
}
@end

@implementation ARCaptureVideoPreviewView

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

@end
