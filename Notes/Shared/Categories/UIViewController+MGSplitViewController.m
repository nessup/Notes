//
//  UIViewController+MGSplitViewController.m
//  Notes
//
//  Created by Dany on 5/31/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "UIViewController+MGSplitViewController.h"

#import "MGSplitViewController.h"

@implementation UIViewController (MGSplitViewController)

- (MGSplitViewController *)MGSplitViewController {
    UIViewController *parentViewController = self.parentViewController;

    while (parentViewController != nil) {
        if ([parentViewController isKindOfClass:[MGSplitViewController class]]) return (MGSplitViewController *)parentViewController;

        parentViewController = parentViewController.parentViewController;
    }

    return nil;
}

@end
