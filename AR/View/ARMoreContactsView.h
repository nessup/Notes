//
//  ARMoreContactsView.h
//  AROverlayExample
//
//  Created by Abdallah Elguindy on 8/30/12.
//  Copyright (c) 2012 Circle. All rights reserved.
//
//
//  Class that displays the number of ARContacts in
//  certain direction.

@interface ARMoreContactsView : UIView

@property (nonatomic) BOOL animating;

@property (nonatomic) int count;

- (id)initWithFrame:(CGRect)frame left:(BOOL)left;

@end
