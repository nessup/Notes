//
//  NotebookListViewController.h
//  Notes
//
//  Created by Dany on 5/25/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditNoteViewController;

@interface NotebookListViewController : UITableViewController

@property (nonatomic, strong) EditNoteViewController *editNoteViewController;

@end
