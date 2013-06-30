//
//  Utility.h
//  Notes
//
//  Created by Dany on 5/31/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

NSURL *ApplicationDocumentsDirectory();
UIColor *ChangeBrightnessOfColorByAmount(UIColor *color, CGFloat amount);
void draw1PxBottomBorder(CGContextRef context, CGRect rect);
void draw1PxBorder(CGContextRef context, CGPoint startPoint, CGPoint endPoint, NSString *color);
