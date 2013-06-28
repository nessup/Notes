//
//  OverlayView.m
//  Notes
//
//  Created by Dany on 6/28/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "OverlayView.h"

#define ActionButtonWidth       300.f
#define ActionButtonHeight      36.f
#define VerticalMargin          20.f

@implementation OverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [FontManager boldHelveticaNeueWithSize:16.f];
        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
        _actionButton = [UIButton new];
        [_actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _actionButton.titleLabel.font = [FontManager helveticaNeueWithSize:16.f];
        [_actionButton setBackgroundColor:[UIColor grayColor]];
        _actionButton.layer.cornerRadius = ActionButtonHeight/2.f;
        [self addSubview:_actionButton];
    }
    return self;
}

- (void)layoutSubviews {
    CGSize titleSize = [self.titleLabel sizeThatFits:(CGSize) {
        ActionButtonWidth,
        CGFLOAT_MAX
    }];
    CGSize totalSize = (CGSize) {
        MAX(self.titleLabel.frame.size.width, self.actionButton.frame.size.width),
        self.titleLabel.frame.size.height + VerticalMargin + ActionButtonHeight
    };
    CGFloat yOffset = roundf(self.frame.size.height/2.f - totalSize.height/2.f);
    self.titleLabel.frame = (CGRect) {
        roundf(self.frame.size.width/2.f - self.titleLabel.frame.size.width/2.f),
        yOffset,
        titleSize
    };
    self.actionButton.frame = (CGRect) {
        roundf(self.frame.size.width/2.f - ActionButtonWidth/2.f),
        yOffset + titleSize.height + VerticalMargin,
        ActionButtonWidth,
        ActionButtonHeight
    };
}

@end
