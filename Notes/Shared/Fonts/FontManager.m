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
    static UIFont *_helveticaNeueFont;
    
    if( !_helveticaNeueFont ) {
        _helveticaNeueFont = [UIFont fontWithName:@"HelveticaNeue" size:size];
    }
    return [_helveticaNeueFont fontWithSize:size];
}

@end
