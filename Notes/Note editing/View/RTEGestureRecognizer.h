//
//  UIGestureRecognizer+RTEGestureRecognizer.h
//  Notes
//
//  Created by Dany on 5/28/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TouchEventBlock)(NSSet * touches, UIEvent * event);

@interface RTEGestureRecognizer : UIGestureRecognizer {
    TouchEventBlock touchesBeganCallback;
    TouchEventBlock touchesEndedCallback;
}
@property(copy) TouchEventBlock touchesBeganCallback;
@property(copy) TouchEventBlock touchesEndedCallback;
@end