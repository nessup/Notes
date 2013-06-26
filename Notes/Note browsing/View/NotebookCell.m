//
//  NotebookView.m
//  Notes
//
//  Created by Dany on 6/23/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "NotebookCell.h"

#import "NotebookIconView.h"

#define VerticalMargin 10.f

@interface NotebookCell ()
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIView *containerView;
@end

@implementation NotebookCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        self.backgroundColor = [UIColor clearColor];

        _containerView = [UIView new];
        [self addSubview:_containerView];

        _titleLabel = [UILabel new];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [FontManager helveticaNeueWithSize:16.f];
        _titleLabel.shadowColor = [UIColor colorWithWhite:0.f alpha:0.4f];
        _titleLabel.shadowOffset = (CGSize) {0.f, 1.f };
        _titleLabel.numberOfLines = 0;
        [_containerView addSubview:_titleLabel];

        _iconView = [NotebookIconView new];
        [_containerView addSubview:_iconView];
    }

    return self;
}

#pragma mark - Layout

- (CGSize)sizeThatFits:(CGSize)size {
    return (CGSize) {
               NotebookCellLength,
               NotebookCellLength
    };
}

- (void)layoutSubviews {
    [self.iconView sizeToFit];
    self.containerView.frame = (CGRect) {
        CGPointZero,
        MAX(self.iconView.frame.size.width, self.titleLabel.frame.size.width),
        self.iconView.frame.size.height + self.titleLabel.frame.size.height
    };
    self.titleLabel.frame = (CGRect) {
        0.f,
        CGRectGetMaxY(self.iconView.frame) + VerticalMargin,
        [self.titleLabel sizeThatFits:(CGSize) {NotebookCellLength, CGFLOAT_MAX }]
    };
    [self.iconView centerHorizontally];
    [self.titleLabel centerHorizontally];
    [self.containerView centerMiddle];
}

@end
