//
//  TableView.m
//  Notes
//
//  Created by Dany on 6/28/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "TableView.h"

@implementation TableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.separatorColor = nil;
    }
    return self;
}

- (void)layoutSubviews {
    self.overlayView.frame = [self overlayViewRectForBounds:self.bounds];
}

- (CGRect)overlayViewRectForBounds:(CGRect)bounds {
    return (CGRect) {
        0.f,
        self.tableHeaderView.frame.size.height,
        self.frame.size.width,
        self.frame.size.height - self.tableHeaderView.frame.size.height
    };
}

- (void)setOverlayView:(UIView *)overlayView {
    [_overlayView removeFromSuperview];
    _overlayView = overlayView;
    [self addSubview:_overlayView];
    _overlayView.layer.zPosition = 1000.f;
    self.scrollEnabled = !_overlayView;
}

//- (void)setTableHeaderView:(UIView *)tableHeaderView {
//    [super setTableHeaderView:tableHeaderView];
//    [self setNeedsLayout];
//}

@end