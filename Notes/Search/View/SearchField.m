//
//  SearchField.m
//  Notes
//
//  Created by Dany on 6/15/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "SearchField.h"

@implementation SearchField

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if( self ) {
        [self commonInit];
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if( self ) {
        [self commonInit];
    }

    return self;
}

- (void)commonInit {
    for( UIView *subview in self.subviews ) {
        if( [subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")] ) {
            [subview removeFromSuperview];
            break;
        }
    }
}

@end
