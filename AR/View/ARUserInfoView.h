//
//  ARUserInfoView.h
//  AROverlayExample
//
//  Created by Abdallah Elguindy on 8/28/12.
//  Copyright (c) 2012 Circle. All rights reserved.
//
//
//  UIView to show the ARContact information at the top
//  of the screen.

#import <UIKit/UIKit.h>
#import "ARContact.h"


@interface ARUserInfoView : UIView {
    UILabel *nameLabel_;
    UILabel *distanceLabel_;
    UILabel *relationshipLabel_;
    UILabel *circlesLabel_;
    
    // ImageView for the background image.
    UIImageView *infoBoxImageView_;
}

//  Sets the information to the information of
//  the input ARContact. If the input is nil, the
//  box becomes hidden.
- (void)set: (ARContact *) contact;

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;


@end
