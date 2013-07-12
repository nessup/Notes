//
//  UIViewController+KeyboardNotifications.m
//  Circle
//
//  Created by Quentin Fasquel on 10/12/12.
//  Copyright (c) 2012 Circle. All rights reserved.
//

#import "UIViewController+KeyboardNotifications.h"

@implementation UIViewController (KeyboardNotifications)



- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidDisappear:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)unregisterFromKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardWillAppear:(NSNotification *)notification {
}

- (void)keyboardDidAppear:(NSNotification *)notification {
}

- (void)keyboardWillDisappear:(NSNotification *)notification {
}

- (void)keyboardDidDisappear:(NSNotification *)notification {
}

@end


@implementation NSNotification (KeyboardNotifications)

- (KeyboardNotificationUserInfo)keyboardUserInfo {
    KeyboardNotificationUserInfo userInfo = (KeyboardNotificationUserInfo) {
        [[self.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue],
        [[self.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue],
        [[self.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue],
        [[self.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue],
    };

    userInfo.animationOptions = animationOptionsWithCurve(userInfo.animationCurve);

    return userInfo;
}

@end