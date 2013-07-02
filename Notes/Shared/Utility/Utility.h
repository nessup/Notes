//
//  Utility.h
//  Notes
//
//  Created by Dany on 5/31/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

NSURL *ApplicationDocumentsDirectory();
CGFloat CenterCoordinateHorizontallyInView(UIView *parentView, CGFloat width);
CGFloat CenterCoordinateVerticallyInView(UIView *parentView, CGFloat length);
UIColor *ChangeBrightnessOfColorByAmount(UIColor *color, CGFloat amount);
void draw1PxBottomBorder(CGContextRef context, CGRect rect);
void draw1PxBorder(CGContextRef context, CGPoint startPoint, CGPoint endPoint, NSString *color);
