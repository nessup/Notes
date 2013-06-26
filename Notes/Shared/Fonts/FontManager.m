//
//  FontManager.m
//  Notes
//
//  Created by Dany on 5/25/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "FontManager.h"

@implementation FontManager

+ (UIFont *)helveticaNeueWithSize:(CGFloat)size {
    static UIFont *font;

    if (!font) {
        font = [UIFont fontWithName:@"HelveticaNeue" size:size];
    }

    return [font fontWithSize:size];
}

+ (UIFont *)boldHelveticaNeueWithSize:(CGFloat)size {
    static UIFont *font;

    if (!font) {
        font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
    }

    return [font fontWithSize:size];
}

+ (UIFont *)boldAmericanTypewriter:(CGFloat)size {
    static UIFont *font;

    if (!font) {
        font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:size];
    }

    return [font fontWithSize:size];
}

@end
