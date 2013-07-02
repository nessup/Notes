//
//  Course.m
//  Notes
//
//  Created by Dany on 5/23/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "Notebook.h"

#import "NotebookCell.h"
#import "NotebookIconView.h"

@implementation Notebook

@dynamic name;
@dynamic notes;
@dynamic defaultUserName;
@dynamic color;
@dynamic dateCreated;

- (void)configureNotebookCell:(NotebookCell *)cell {
    cell.title = self.name;
    [self configureNotebookIconView:cell.iconView];
}

- (void)configureNotebookIconView:(NotebookIconView *)notebookIconView {
    notebookIconView.firstLetterLabel.text = self.name.length ? [self.name substringWithRange:NSMakeRange(0, 1)] : @"";
    notebookIconView.color = self.color;
}

@end
