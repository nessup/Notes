//
//  ARCaptureVideoPreviewView.h
//  AROverlayExample
//
//  Created by Arnold Noronha on 9/29/12.
//
//

#import <UIKit/UIKit.h>

@class AVCaptureVideoPreviewLayer;

@interface ARCaptureVideoPreviewView : UIView

@property (nonatomic, retain) AVCaptureVideoPreviewLayer * layer;

@end
