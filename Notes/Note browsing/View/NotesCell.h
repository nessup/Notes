//
//  NotesCell.h
//  Notes
//
//  Created by Dany on 6/18/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTTAttributedLabel;

@interface NotesCell : UITableViewCell
@property (nonatomic, strong) TTTAttributedLabel *topRightTextLabel;
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, copy) NSString *highlightText;
- (CALayer *)colorLayer;
- (CGFloat)cellHeightForWidth:(CGFloat)width;
@end
