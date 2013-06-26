//
//  Utility.m
//  Notes
//
//  Created by Dany on 5/31/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "Utility.h"

NSURL *
ApplicationDocumentsDirectory() {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Utility

UIColor *
ChangeBrightnessOfColorByAmount(UIColor *color, CGFloat amount) {
    CGFloat hue, saturation, brightness, alpha;

    if( [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha] ) {
        brightness += (amount - 1.0);
        brightness = MAX(MIN(brightness, 1.0), 0.0);
        return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    }

    CGFloat white;

    if( [color getWhite:&white alpha:&alpha] ) {
        white += (amount - 1.0);
        white = MAX(MIN(white, 1.0), 0.0);
        return [UIColor colorWithWhite:white alpha:alpha];
    }

    return nil;
}