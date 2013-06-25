//
//  ARDrawingManager.h
//  AROverlayExample
//
//  Created by Abdallah Elguindy on 8/17/12.
//  Copyright (c) 2012 Circle. All rights reserved.
//
//
//  This is the main UIView displaying avatars, information
//  and other UI elements, for example, distance lines.

#import <UIKit/UIKit.h>

#import "ARContact.h"
#import "ARUserInfoView.h"

@class AvatarView, ARContact;

@protocol ARDrawingManagerDelegate <NSObject>

- (void)avatarViewTapped:(AvatarView *)view contact:(ARContact *)contact;

@end

@interface ARDrawingManager : NSObject {
@public
    CAShapeLayer *lineLayers_[3];
}

@property (nonatomic, weak) UIView *view;
@property (nonatomic, weak) NSObject<ARDrawingManagerDelegate> *delegate;

- (id)initWithView:(UIView *)view;

//  Updates the lines by adjusting the roll
//  of the phone.
- (void)updateLines:(double)roll;

//  Updates the positions of the avatars by
//  adjusting the heading of the phone.
- (void)updateAvatars: (double)heading;

//  Sets the icons on a circle to the input
//  images.
- (void)setIcons: (NSArray*) ARContacts circle: (int) circle;

@end
