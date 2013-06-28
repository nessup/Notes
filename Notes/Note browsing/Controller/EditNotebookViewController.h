//
//  EditNotebookViewController.h
//  Notes
//
//  Created by Dany on 5/25/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditNotebookViewController;

@protocol EditNotebookViewControllerDelegate <NSObject>
- (void)editNotebookViewControllerDidFinishEditing:(EditNotebookViewController *)editNotebookViewController;
@end

@class Notebook;

@interface EditNotebookViewController : UIViewController
@property (nonatomic, strong) Notebook *notebook;
@property (nonatomic, weak) id<EditNotebookViewControllerDelegate> delegate;
@property (nonatomic, readonly) BOOL madeChanges;
@property (nonatomic) BOOL creatingNotebook;
@property (nonatomic, strong) UIBarButtonItem *editButtonItem;
@end
