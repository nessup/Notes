//
//  UIViewController+KeyboardNotifications.h
//  Circle
//
//  Created by Quentin Fasquel on 10/12/12.
//  Copyright (c) 2012 Circle. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct {
    UIViewAnimationCurve animationCurve;
    NSTimeInterval animationDuration;
    CGRect frameBegin;
    CGRect frameEnd;
    // Additional
    UIViewAnimationOptions animationOptions;
} KeyboardNotificationUserInfo;

static inline UIViewAnimationOptions animationOptionsWithCurve(UIViewAnimationCurve curve){
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
    }
}

@interface UIViewController (KeyboardNotifications)
- (void)registerForKeyboardNotifications;
- (void)unregisterFromKeyboardNotifications;
- (void)keyboardWillAppear:(NSNotification *)notification;
- (void)keyboardDidAppear:(NSNotification *)notification;
- (void)keyboardWillDisappear:(NSNotification *)notification;
- (void)keyboardDidDisappear:(NSNotification *)notification;
@end

@interface NSNotification (KeyboardNotifications)
- (KeyboardNotificationUserInfo)keyboardUserInfo;
@end