//
//  NotebookTableView.m
//  Notes
//
//  Created by Dany on 6/21/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "NotebookTableView.h"

@interface NotebookTableView ()

@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation NotebookTableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.backgroundView = nil;
        [self addSubview:_tableView];
    }

    return self;
}

@end
