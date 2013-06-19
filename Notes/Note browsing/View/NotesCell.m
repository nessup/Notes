//
//  NotesCell.m
//  Notes
//
//  Created by Dany on 6/18/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "NotesCell.h"

#define ColorLayerWidth             5.f

@interface NotesCell ()
@property (nonatomic, strong) CALayer *colorLayer;
@end

@implementation NotesCell
//@synthesize textLabel = __textLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _colorLayer = [CALayer new];
        [self.layer addSublayer:_colorLayer];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectOffset(self.textLabel.frame, ColorLayerWidth, 0.f);
    self.detailTextLabel.frame = CGRectOffset(self.detailTextLabel.frame, ColorLayerWidth, 0.f);
    
    self.colorLayer.frame = (CGRect) {
        CGPointZero,
        ColorLayerWidth,
        self.frame.size.height
    };
}

#pragma mark - Properties

//- (UILabel *)textLabel
//{
//    if( __textLabel )
//        return __textLabel;
//    
//    
//    
//    return __textLabel;
//}

@end
