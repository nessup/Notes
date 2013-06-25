//
//  NotebookView.h
//  Notes
//
//  Created by Dany on 6/23/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "PSTCollectionView.h"
#import "PSTCollectionViewCell.h"

#define NotebookCellLength      200.f

@class NotebookIconView;

@interface NotebookCell : PSUICollectionViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NotebookIconView *iconView;
@end
