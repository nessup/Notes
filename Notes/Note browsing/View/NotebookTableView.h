//
//  NotebookTableView.h
//  Notes
//
//  Created by Dany on 6/21/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotebookTableView : UIView
@property (nonatomic, strong) UIColor *notebookColor;
@property (nonatomic, copy) NSString *notebookName;
@property (nonatomic, strong) UITableView *tableView;
@end
